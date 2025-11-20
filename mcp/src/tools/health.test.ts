/**
 * @layer Test
 * @role Health tool integration test suite
 * @deps vitest, @modelcontextprotocol/sdk, ../server, dayjs
 * @notes Tests actual MCP server communication with health tool
 */

import { describe, it, expect, beforeAll, afterAll } from "vitest";
import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { InMemoryTransport } from "@modelcontextprotocol/sdk/inMemory.js";
import { createMcpServer } from "../server";
import dayjs from "dayjs";

describe("Health Tool - Integration Test", () => {
  let client: Client;
  let serverTransport: InMemoryTransport;
  let clientTransport: InMemoryTransport;

  beforeAll(async () => {
    // Create in-memory transport pair for testing
    [serverTransport, clientTransport] = InMemoryTransport.createLinkedPair();

    // Create and connect server
    const server = createMcpServer();
    await server.connect(serverTransport);

    // Create and connect client
    client = new Client(
      {
        name: "test-client",
        version: "1.0.0"
      },
      {
        capabilities: {}
      }
    );
    await client.connect(clientTransport);
  });

  afterAll(async () => {
    await client.close();
    await serverTransport.close();
    await clientTransport.close();
  });

  it("should list health tool in available tools", async () => {
    const tools = await client.listTools();

    expect(tools.tools).toBeDefined();
    expect(Array.isArray(tools.tools)).toBe(true);

    const healthTool = tools.tools.find((tool) => tool.name === "health");
    expect(healthTool).toBeDefined();
    expect(healthTool?.description).toBe(
      "MCP サーバーのヘルスチェックを行い、稼働状態とタイムスタンプを返します。"
    );
  });

  it("should call health tool and return valid response", async () => {
    const result = await client.callTool({
      name: "health",
      arguments: {}
    });

    expect(result).toBeDefined();
    expect(result.content).toBeDefined();
    expect(Array.isArray(result.content)).toBe(true);

    const content = result.content as Array<{ type: string; text?: string }>;
    expect(content.length).toBeGreaterThan(0);

    const firstContent = content[0];
    expect(firstContent.type).toBe("text");

    if (firstContent.type === "text" && firstContent.text) {
      const responseData = JSON.parse(firstContent.text);
      expect(responseData.status).toBe("ok");
      expect(responseData.timestamp).toBeDefined();
      expect(responseData.uptime).toBeDefined();
      expect(responseData.message).toBe("MCP server is running");

      // Verify timestamp is valid ISO format
      const timestamp = dayjs(responseData.timestamp);
      expect(timestamp.toISOString()).toBe(responseData.timestamp);

      // Verify uptime format
      expect(responseData.uptime).toMatch(/^\d+\.\d{2}s$/);
    }
  });

  it("should return different timestamps on multiple calls", async () => {
    const result1 = await client.callTool({
      name: "health",
      arguments: {}
    });

    // Wait a small amount of time
    await new Promise((resolve) => setTimeout(resolve, 10));

    const result2 = await client.callTool({
      name: "health",
      arguments: {}
    });

    const content1 = (result1.content as Array<{ type: string; text?: string }>)[0];
    const content2 = (result2.content as Array<{ type: string; text?: string }>)[0];

    if (content1.type === "text" && content1.text && content2.type === "text" && content2.text) {
      const data1 = JSON.parse(content1.text);
      const data2 = JSON.parse(content2.text);

      // Timestamps should be different (though very close)
      expect(data1.timestamp).not.toBe(data2.timestamp);
    }
  });

  it("should have all required fields in response", async () => {
    const result = await client.callTool({
      name: "health",
      arguments: {}
    });

    const content = (result.content as Array<{ type: string; text?: string }>)[0];

    if (content.type === "text" && content.text) {
      const responseData = JSON.parse(content.text);

      expect(responseData).toHaveProperty("status");
      expect(responseData).toHaveProperty("timestamp");
      expect(responseData).toHaveProperty("uptime");
      expect(responseData).toHaveProperty("message");

      expect(typeof responseData.status).toBe("string");
      expect(typeof responseData.timestamp).toBe("string");
      expect(typeof responseData.uptime).toBe("string");
      expect(typeof responseData.message).toBe("string");
    }
  });
});

/**
 * @layer Application
 * @role Health check tool for MCP server
 * @deps @modelcontextprotocol/sdk, ../domain/utils, dayjs
 * @exports registerHealthTool
 * @invariants
 *   - Always returns OK status with current timestamp
 *   - No external dependencies required
 * @notes Simple health check endpoint for testing server availability
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { ResponseFormatter } from "../domain/utils";
import dayjs from "dayjs";

/**
 * registerHealthTool
 * @role Register health check tool to MCP server
 * @input server: McpServer instance
 * @returns void
 * @invariants
 *   - Registers tool with name "health"
 *   - Returns current server status and timestamp
 * @notes Used for testing MCP server connectivity and basic functionality
 */
export function registerHealthTool(server: McpServer): void {
  server.registerTool(
    "health",
    {
      description: "MCP サーバーのヘルスチェックを行い、稼働状態とタイムスタンプを返します。"
    },
    // eslint-disable-next-line @typescript-eslint/require-await
    async () => {
      try {
        const timestamp = dayjs().toISOString();
        const uptime = process.uptime();

        const healthData = {
          status: "ok",
          timestamp,
          uptime: `${uptime.toFixed(2)}s`,
          message: "MCP server is running"
        };

        return ResponseFormatter.formatModelResponse(JSON.stringify(healthData, null, 2), false);
      } catch (error: unknown) {
        return ResponseFormatter.formatError(error);
      }
    }
  );
}

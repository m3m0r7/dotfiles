/**
 * @layer Application
 * @role MCP tool for Playwright browser automation
 * @deps ../infrastructure/system, ../domain/schemas, @modelcontextprotocol/sdk
 * @exports registerPlaywrightAgentTool
 * @invariants
 *   - Browser instance properly cleaned up after execution
 *   - Screenshots saved to specified path or default location
 * @notes Provides browser automation capabilities via natural language
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import {
  playwrightAgentInputSchema,
  type PlaywrightAgentInput
} from "../domain/schemas/index";
import {
  executePlaywrightTask,
  type PlaywrightTaskResult
} from "../infrastructure/system/index";

/**
 * registerPlaywrightAgentTool
 * @role Register playwright_agent MCP tool on server
 * @input server: McpServer instance
 * @effect Registers playwright_agent tool with schema validation
 */
export function registerPlaywrightAgentTool(server: McpServer): void {
  server.registerTool<typeof playwrightAgentInputSchema, never>(
    "playwright_agent",
    {
      description:
        "Playwright を使用してブラウザ自動化タスクを実行します。URL へのナビゲート、要素のクリック、テキスト入力、スクリーンショット撮影などが可能です。",
      inputSchema: playwrightAgentInputSchema
    },
    async (input: PlaywrightAgentInput) => {
      const result = await executePlaywrightTask(
        input.task,
        input.url,
        input.headless ?? true,
        input.screenshot ?? false,
        input.screenshot_path ?? "./screenshot.png"
      );

      const text = formatResult(result, input);

      return {
        content: [
          {
            type: "text",
            text
          } satisfies { type: "text"; text: string }
        ]
      };
    }
  );
}

/**
 * formatResult
 * @role Format PlaywrightTaskResult for display
 * @input result: execution result from Playwright
 * @input input: original user input
 * @output formatted text string
 */
function formatResult(
  result: PlaywrightTaskResult,
  input: PlaywrightAgentInput
): string {
  const lines: string[] = [];

  lines.push("Playwright Browser Automation Result");
  lines.push("=".repeat(40));
  lines.push("");

  lines.push(`Task: ${input.task}`);
  if (input.url) {
    lines.push(`URL: ${input.url}`);
  }
  lines.push(`Headless Mode: ${input.headless ?? true}`);
  lines.push("");

  lines.push(`Status: ${result.success ? "✓ Success" : "✗ Failed"}`);
  lines.push(`Message: ${result.message}`);
  lines.push("");

  if (result.screenshotPath) {
    lines.push(`Screenshot saved to: ${result.screenshotPath}`);
    lines.push("");
  }

  if (result.error) {
    lines.push("Error Details:");
    lines.push(result.error);
    lines.push("");
  }

  if (result.pageContent) {
    lines.push("Page Content (first 1000 chars):");
    lines.push("-".repeat(40));
    lines.push(result.pageContent.substring(0, 1000));
    if (result.pageContent.length > 1000) {
      lines.push("...(truncated)");
    }
  }

  return lines.join("\n");
}

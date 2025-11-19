/**
 * @layer Application
 * @role MCP server initialization and tool registration
 * @deps @modelcontextprotocol/sdk, ./tools/listModels, ./tools/callOpenaiModel
 * @exports createMcpServer
 * @invariants
 *   - Server name: "claude-openai-bridge"
 *   - Server version: "0.1.0"
 *   - Registers all tools on creation
 * @notes Central place for server setup and tool registration
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerListModelsTool } from "./tools/listModels";
import { registerCallOpenaiModelTool } from "./tools/callOpenaiModel";
import { registerListGeminiModelsTool } from "./tools/listGeminiModels";
import { registerCallGeminiModelTool } from "./tools/callGeminiModel";
import { registerGithubGraphqlAgentTool } from "./tools/githubGraphqlAgent";
import { registerPlaywrightAgentTool } from "./tools/playwrightAgent";

/**
 * createMcpServer
 * @role Factory function to create and configure MCP server
 * @returns Configured McpServer instance with all tools registered
 * @invariants
 *   - Creates server with fixed name and version
 *   - Registers list_openai_models tool
 *   - Registers call_openai_model tool
 */
export function createMcpServer(): McpServer {
  const server = new McpServer({
    name: "claude-openai-bridge",
    version: "0.1.0"
  });

  registerListModelsTool(server);
  registerCallOpenaiModelTool(server);
  registerListGeminiModelsTool(server);
  registerCallGeminiModelTool(server);
  registerGithubGraphqlAgentTool(server);
  registerPlaywrightAgentTool(server);

  return server;
}

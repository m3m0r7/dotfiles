/**
 * @layer Application
 * @role MCP server initialization and tool registration
 * @deps @modelcontextprotocol/sdk, ./tools/*, node:fs, node:path, node:url
 * @exports createMcpServer
 * @invariants
 *   - Server name and version read from package.json
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
import { registerHealthTool } from "./tools/health";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import type { IOpenAIClient } from "./infrastructure/clients/openai.client";
import type { IGeminiClient } from "./infrastructure/clients/gemini.client";
import type { IGitHubClient } from "./infrastructure/clients/github.client";

/**
 * Read package.json to get server metadata
 */
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const packageJson = JSON.parse(
  readFileSync(resolve(__dirname, "../package.json"), "utf-8")
) as { name: string; version: string };

/**
 * ServerDependencies
 * @role Optional dependencies for dependency injection
 * @notes
 *   - Allows injecting mock clients for testing
 *   - Currently defined for future extension
 *   - Tool implementations use factory pattern with optional API key injection
 *   - For full DI support, tool registration functions would need to accept client instances
 */
export interface ServerDependencies {
  openaiClient?: IOpenAIClient;
  geminiClient?: IGeminiClient;
  githubClient?: IGitHubClient;
}

/**
 * createMcpServer
 * @role Factory function to create and configure MCP server
 * @input deps: optional dependencies for dependency injection (reserved for future use)
 * @returns Configured McpServer instance with all tools registered
 * @invariants
 *   - Creates server with name and version from package.json
 *   - Registers all MCP tools
 * @notes
 *   - Current implementation: tools create clients internally using factories
 *   - Testing strategy: use environment variables or factory API key parameters
 *   - Future enhancement: pass deps to tool registration functions
 */
export function createMcpServer(_deps?: ServerDependencies): McpServer {
  const server = new McpServer({
    name: packageJson.name,
    version: packageJson.version
  });

  registerHealthTool(server);
  registerListModelsTool(server);
  registerCallOpenaiModelTool(server);
  registerListGeminiModelsTool(server);
  registerCallGeminiModelTool(server);
  registerGithubGraphqlAgentTool(server);
  registerPlaywrightAgentTool(server);

  return server;
}

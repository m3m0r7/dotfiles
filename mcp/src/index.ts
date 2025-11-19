/**
 * @layer Application
 * @role Application entrypoint
 * @deps dotenv, @modelcontextprotocol/sdk, ./server, ./domain/utils
 * @exports None (main execution)
 * @invariants
 *   - Loads environment variables on startup
 *   - Creates and connects MCP server via stdio transport
 *   - Exits with code 1 on connection failure
 * @notes Keep minimal - only environment setup and server startup
 */

import { config as loadEnv } from "dotenv";
import { fileURLToPath } from "url";
import { dirname, resolve } from "path";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createMcpServer } from "./server";
import { toErrorMessage } from "./domain/utils/index";

/**
 * Guard: Load environment variables at process start
 * @effect Reads .env file from project root into process.env
 */
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
loadEnv({ path: resolve(__dirname, "../.env") });

/**
 * main
 * @role Entrypoint function
 * @effect
 *   - Creates MCP server with registered tools
 *   - Establishes stdio transport connection
 * @throws Error if server connection fails
 */
async function main(): Promise<void> {
  const server = createMcpServer();
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

/**
 * Guard: Catch startup errors and exit gracefully
 */
main().catch((error: unknown) => {
  const message = toErrorMessage(error);
  console.error("Failed to start MCP server", message);
  process.exit(1);
});

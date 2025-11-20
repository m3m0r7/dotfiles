/**
 * @layer Application
 * @role Application entrypoint
 * @deps dotenv, @modelcontextprotocol/sdk, ./server, ./domain/utils, ./config/env
 * @exports None (main execution)
 * @invariants
 *   - Loads environment variables on startup
 *   - Validates environment configuration before server creation
 *   - Creates and connects MCP server via stdio transport
 *   - Exits with code 1 on connection failure
 * @notes Keep minimal - only environment setup and server startup
 */

import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { createMcpServer } from "./server";
import { toErrorMessage } from "./domain/utils";

/**
 * Guard: Validate environment variables after loading
 * @effect Triggers environment validation on import
 * @note This will throw if validation fails, preventing server startup
 */
import "./config/env";

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

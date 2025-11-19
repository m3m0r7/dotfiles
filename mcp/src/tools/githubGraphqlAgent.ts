/**
 * @layer Application
 * @role MCP tool for executing arbitrary GitHub GraphQL queries
 * @deps ../domain/githubGraphqlAgent, ../domain/schemas, @modelcontextprotocol/sdk
 * @exports registerGithubGraphqlAgentTool
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import {
  githubGraphqlAgentInputSchema,
  type GithubGraphqlAgentInput
} from "../domain/schemas.js";
import {
  runGithubGraphqlAgent,
  type GithubGraphqlAgentResult
} from "../domain/githubGraphqlAgent.js";

/**
 * Register github_graphql_agent MCP tool
 */
export function registerGithubGraphqlAgentTool(server: McpServer): void {
  server.registerTool<typeof githubGraphqlAgentInputSchema, never>(
    "github_graphql_agent",
    {
      description:
        "GitHub GraphQL API に任意のクエリを実行します。Issue、PR、プロジェクト、検索など幅広い操作が可能です。",
      inputSchema: githubGraphqlAgentInputSchema
    },
    async (input: GithubGraphqlAgentInput) => {
      const result = await runGithubGraphqlAgent(input);
      const text = formatResult(result);
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

function formatResult(result: GithubGraphqlAgentResult): string {
  const lines: string[] = [];

  if (result.task) {
    lines.push(`Task: ${result.task}`);
    lines.push("");
  }

  if (result.repository) {
    lines.push(`Repository: ${result.repository}`);
  }

  if (result.gitRoot) {
    lines.push(`Git Root: ${result.gitRoot}`);
  }

  if (result.repository || result.gitRoot) {
    lines.push("");
  }

  lines.push("Query executed successfully.");
  lines.push("");
  lines.push("Variables:");
  lines.push(JSON.stringify(result.variables, null, 2));
  lines.push("");
  lines.push("Result:");
  lines.push(JSON.stringify(result.data, null, 2));

  return lines.join("\n");
}

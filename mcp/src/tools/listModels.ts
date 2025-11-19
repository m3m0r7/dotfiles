/**
 * @layer Application
 * @role MCP tool for listing OpenAI models
 * @deps ../infrastructure/clients, @modelcontextprotocol/sdk
 * @exports registerListModelsTool
 * @invariants
 *   - Returns JSON string with model count and sorted models array
 *   - Models are sorted by id in ascending order
 * @notes Single responsibility: tool registration for list_openai_models
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { OpenAIClientFactory } from "../infrastructure/clients/index";
import { ResponseFormatter } from "../domain/utils/index";

/**
 * registerListModelsTool
 * @role Register list_openai_models tool on MCP server
 * @input server: McpServer instance
 * @effect Registers tool handler on provided server
 * @invariants
 *   - Fetches models from OpenAI API
 *   - Maps to { id, created, ownedBy }
 *   - Sorts by id alphabetically
 *   - Returns JSON formatted content
 */
export function registerListModelsTool(server: McpServer): void {
  server.registerTool(
    "list_openai_models",
    {
      description: "OpenAI API の model 一覧を取得し、基本情報を返します。"
    },
    async () => {
      const client = OpenAIClientFactory.create();
      const response = await client.models.list();

      const models = response.data.map((rawModel) => ({
        id: rawModel.id,
        created: rawModel.created,
        ownedBy: rawModel.owned_by
      }));

      // 共通のフォーマッターを使用
      return ResponseFormatter.formatModelList(models, "id");
    }
  );
}

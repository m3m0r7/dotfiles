/**
 * @layer Application
 * @role MCP tool for listing Gemini models
 * @deps @modelcontextprotocol/sdk, infrastructure/clients
 * @exports registerListGeminiModelsTool
 * @invariants
 *   - Returns JSON string with model count and sorted models array
 *   - Models are sorted by name in ascending order
 * @notes Single responsibility: tool registration for list_gemini_models
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { ResponseFormatter } from "../domain/utils/index";
import { getGeminiApiKey } from "../infrastructure/clients/index";

/**
 * GeminiModel
 * @role Type definition for Gemini model response
 * @invariants
 *   - name: model identifier
 *   - displayName: human-readable name
 *   - description: model description
 *   - supportedGenerationMethods: array of supported methods
 */
type GeminiModel = {
  name: string;
  displayName: string;
  description: string;
  supportedGenerationMethods: string[];
};

/**
 * GeminiModelsResponse
 * @role Type definition for Gemini API response
 * @invariants
 *   - models: array of GeminiModel
 */
type GeminiModelsResponse = {
  models: GeminiModel[];
};

/**
 * registerListGeminiModelsTool
 * @role Register list_gemini_models tool on MCP server
 * @input server: McpServer instance
 * @effect Registers tool handler on provided server
 * @invariants
 *   - Fetches models from Gemini REST API
 *   - Maps to { name, displayName, description, supportedGenerationMethods }
 *   - Sorts by name alphabetically
 *   - Returns JSON formatted content
 */
export function registerListGeminiModelsTool(server: McpServer): void {
  server.registerTool(
    "list_gemini_models",
    {
      description: "Gemini API の model 一覧を取得し、基本情報を返します。"
    },
    async () => {
      const apiKey = getGeminiApiKey();

      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`
      );

      if (!response.ok) {
        throw new Error(
          `Gemini API returned ${response.status}: ${response.statusText}`
        );
      }

      const data = (await response.json()) as GeminiModelsResponse;

      const models = data.models.map((rawModel) => ({
        name: rawModel.name,
        displayName: rawModel.displayName,
        description: rawModel.description ?? "",
        supportedGenerationMethods: rawModel.supportedGenerationMethods ?? []
      }));

      // 共通のフォーマッターを使用
      return ResponseFormatter.formatModelList(models, "name");
    }
  );
}

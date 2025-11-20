/**
 * @layer Application
 * @role MCP tool for calling Gemini generative models
 * @deps ../infrastructure/clients, ../domain/schemas, ../domain/utils, @modelcontextprotocol/sdk
 * @exports registerCallGeminiModelTool
 * @invariants
 *   - Validates input against callGeminiModelInputSchema
 *   - Requests JSON mode from Gemini when json_schema is provided
 *   - Parses and validates response as JSON
 *   - Returns formatted response
 * @notes Single responsibility: tool registration for call_gemini_model
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { GeminiClientFactory } from "../infrastructure/clients";
import { callGeminiModelInputSchema, type CallGeminiModelInput } from "../domain/schemas";
import { ResponseFormatter } from "../domain/utils";

/**
 * registerCallGeminiModelTool
 * @role Register call_gemini_model tool on MCP server
 * @input server: McpServer instance
 * @effect Registers tool handler on provided server
 * @invariants
 *   - Builds prompt with system instructions and user instructions
 *   - Calls Gemini with JSON mode when json_schema is provided
 *   - Validates response is valid JSON when json_schema is provided
 *   - Throws if response is empty or invalid JSON
 */
export function registerCallGeminiModelTool(server: McpServer): void {
  server.registerTool<typeof callGeminiModelInputSchema, never>(
    "call_gemini_model",
    {
      description:
        "指定した Gemini モデルに指示を送り、レスポンスを返します。json_schema を指定した場合は JSON 形式で応答します。",
      inputSchema: callGeminiModelInputSchema
    },
    async ({
      model,
      instructions,
      system,
      json_schema,
      temperature,
      max_tokens
    }: CallGeminiModelInput) => {
      try {
        const client = GeminiClientFactory.create();

        const generationConfig = {
          temperature,
          maxOutputTokens: max_tokens,
          ...(json_schema ? { responseMimeType: "application/json" } : {})
        };

        const geminiModel = client.getGenerativeModel({
          model,
          generationConfig,
          systemInstruction: system
        });

        const schemaHint = json_schema
          ? `次の JSON スキーマに厳密に従ってください:\n${json_schema}`
          : "";

        const prompt = schemaHint
          ? `${instructions}\n\n${schemaHint}`
          : instructions;

        const result = await geminiModel.generateContent(prompt);
        const response = result.response;
        const text = response.text();

        // 共通のレスポンスフォーマッターを使用
        return ResponseFormatter.formatModelResponse(text, Boolean(json_schema));
      } catch (error: unknown) {
        // エラーを構造化して返す（プロセスを落とさない）
        return ResponseFormatter.formatError(error);
      }
    }
  );
}

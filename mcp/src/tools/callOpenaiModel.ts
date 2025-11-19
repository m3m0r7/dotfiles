/**
 * @layer Application
 * @role MCP tool for calling OpenAI chat models
 * @deps ../infrastructure/clients, ../domain/schemas, ../domain/utils, @modelcontextprotocol/sdk
 * @exports registerCallOpenaiModelTool
 * @invariants
 *   - Validates input against callOpenaiModelInputSchema
 *   - Requests JSON mode from OpenAI when json_schema is provided
 *   - Parses and validates response as JSON
 *   - Returns formatted response
 * @notes Single responsibility: tool registration for call_openai_model
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { OpenAIClientFactory } from "../infrastructure/clients/index";
import { callOpenaiModelInputSchema, type CallOpenaiModelInput } from "../domain/schemas/index";
import { buildMessages, normalizeContent, ResponseFormatter } from "../domain/utils/index";

/**
 * registerCallOpenaiModelTool
 * @role Register call_openai_model tool on MCP server
 * @input server: McpServer instance
 * @effect Registers tool handler on provided server
 * @invariants
 *   - Builds messages with system and user instructions
 *   - Calls OpenAI with json_object response format when json_schema is provided
 *   - Validates response is valid JSON when json_schema is provided
 *   - Throws if response is empty or invalid JSON
 */
export function registerCallOpenaiModelTool(server: McpServer): void {
  server.registerTool<typeof callOpenaiModelInputSchema, never>(
    "call_openai_model",
    {
      description:
        "指定した OpenAI モデルに指示を送り、レスポンスを返します。json_schema を指定した場合は JSON 形式で応答します。",
      inputSchema: callOpenaiModelInputSchema
    },
    async ({
      model,
      instructions,
      system,
      json_schema,
      temperature,
      max_tokens
    }: CallOpenaiModelInput) => {
      const client = OpenAIClientFactory.create();
      const messages = buildMessages(instructions, system, json_schema);

      const completion = await client.chat.completions.create({
        model,
        messages,
        temperature,
        max_tokens,
        ...(json_schema ? { response_format: { type: "json_object" } } : {})
      });

      const content = completion.choices[0]?.message?.content ?? null;
      const text = normalizeContent(content);

      // 共通のレスポンスフォーマッターを使用
      return ResponseFormatter.formatModelResponse(text, Boolean(json_schema));
    }
  );
}

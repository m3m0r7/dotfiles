/**
 * @layer Application
 * @role MCP tool for calling OpenAI chat models
 * @deps ../infrastructure/openaiClient, ../domain/schemas, ../domain/utils, @modelcontextprotocol/sdk
 * @exports registerCallOpenaiModelTool
 * @invariants
 *   - Validates input against callOpenaiModelInputSchema
 *   - Requests JSON mode from OpenAI when json_schema is provided
 *   - Parses and validates response as JSON
 *   - Returns formatted response
 * @notes Single responsibility: tool registration for call_openai_model
 */

import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { getOpenAIClient } from "../infrastructure/openaiClient.js";
import { callOpenaiModelInputSchema, type CallOpenaiModelInput } from "../domain/schemas.js";
import { buildMessages, normalizeContent, toErrorMessage } from "../domain/utils.js";

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
      const client = getOpenAIClient();
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

      if (!text) {
        throw new Error(
          "OpenAI から有効なレスポンステキストを取得できませんでした。"
        );
      }

      // JSON スキーマが指定されている場合のみ JSON としてパース
      if (json_schema) {
        let parsed: unknown;
        try {
          parsed = JSON.parse(text);
        } catch (error: unknown) {
          throw new Error(`JSON のパースに失敗しました: ${toErrorMessage(error)}`);
        }

        return {
          content: [
            {
              type: "text",
              text: JSON.stringify(parsed, null, 2)
            } satisfies { type: "text"; text: string }
          ]
        };
      }

      // JSON スキーマが指定されていない場合はそのまま返す
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

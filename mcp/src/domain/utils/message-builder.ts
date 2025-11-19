/**
 * @layer Domain
 * @role Message construction utilities for AI models
 * @deps openai/resources/chat/completions
 * @exports buildMessages
 * @invariants
 *   - Always includes base system message for JSON generation
 *   - Appends custom system message if provided
 *   - Appends user message with instructions and schema hint
 * @notes OpenAI-specific message building logic
 */

import type { ChatCompletionMessageParam } from "openai/resources/chat/completions";

/**
 * buildMessages
 * @role Construct ChatCompletionMessageParam[] for OpenAI API
 * @input instructions: string, system?: string, jsonSchema?: string
 * @output ChatCompletionMessageParam[]
 * @invariants
 *   - Always includes base system message for JSON generation
 *   - Appends custom system message if provided
 *   - Appends user message with instructions and schema hint
 */
export function buildMessages(
  instructions: string,
  system?: string,
  jsonSchema?: string
): ChatCompletionMessageParam[] {
  const messages: ChatCompletionMessageParam[] = [
    {
      role: "system",
      content:
        "You are a strict JSON generator. Always answer with valid JSON that matches the user's requirements."
    }
  ];

  if (system) {
    messages.push({ role: "system", content: system });
  }

  const schemaHint = jsonSchema
    ? `次の JSON スキーマに厳密に従ってください:\n${jsonSchema}`
    : "必ず 1 つの JSON オブジェクトのみを返してください。`json_schema` がない場合も、全ての値は問題文に適合するようにしてください。";

  messages.push({
    role: "user",
    content: `${instructions}\n\n${schemaHint}`
  });

  return messages;
}

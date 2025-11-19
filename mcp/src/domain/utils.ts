/**
 * @layer Domain
 * @role Utility functions for content and message processing
 * @deps openai/resources/chat/completions, ./types
 * @exports isMessageContentArray, normalizeContent, toErrorMessage, buildMessages
 * @invariants
 *   - Type guards never throw, return boolean
 *   - normalizeContent always returns string (empty if null/undefined)
 *   - toErrorMessage always returns human-readable string
 * @notes Keep functions pure and side-effect free
 */

import type { ChatCompletionMessageParam } from "openai/resources/chat/completions";
import type { MessageContent, MessageContentPart } from "./types.js";

/**
 * isMessageContentArray
 * @role Type guard for MessageContentPart[]
 * @input unknown
 * @output boolean (true if MessageContentPart[])
 * @invariants
 *   - Returns false if not array
 *   - Returns false if any element lacks type field or has invalid text
 */
export function isMessageContentArray(
  value: unknown
): value is MessageContentPart[] {
  if (!Array.isArray(value)) return false;

  return value.every((contentPart) => {
    if (typeof contentPart !== "object" || contentPart === null) return false;
    if (!("type" in contentPart) || typeof contentPart.type !== "string") return false;
    if ("text" in contentPart && typeof contentPart.text !== "string") return false;
    return true;
  });
}

/**
 * normalizeContent
 * @role Normalize OpenAI message content to plain string
 * @input MessageContent | null | undefined
 * @output string
 * @invariants
 *   - null/undefined -> empty string
 *   - string -> trimmed string
 *   - array -> concatenated text parts, trimmed
 */
export function normalizeContent(
  content: MessageContent | null | undefined
): string {
  if (content == null) return "";
  if (typeof content === "string") return content.trim();
  if (!isMessageContentArray(content)) return "";

  return content
    .map((contentPart) => contentPart.text ?? "")
    .join("")
    .trim();
}

/**
 * toErrorMessage
 * @role Convert unknown error to human-readable string
 * @input unknown
 * @output string
 * @invariants
 *   - Error instance -> error.message
 *   - string -> as-is
 *   - other -> JSON.stringify or "Unknown error"
 */
export function toErrorMessage(error: unknown): string {
  if (error instanceof Error) return error.message;
  if (typeof error === "string") return error;

  try {
    return JSON.stringify(error);
  } catch {
    return "Unknown error";
  }
}

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

/**
 * @layer Domain
 * @role Content normalization utilities for AI model responses
 * @deps ../types
 * @exports isMessageContentArray, normalizeContent
 * @invariants
 *   - Type guards never throw, return boolean
 *   - normalizeContent always returns string (empty if null/undefined)
 * @notes Pure functions for content processing
 */

import type { MessageContent, MessageContentPart } from "../types/index";

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
 * @role Normalize AI model message content to plain string
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

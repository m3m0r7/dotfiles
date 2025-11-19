/**
 * @layer Domain
 * @role Type definitions for MCP tools
 * @deps None
 * @exports MessageContentPart, MessageContent
 * @invariants
 *   - MessageContent: string or MessageContentPart[]
 *   - MessageContentPart: object with type and optional text
 * @notes Keep types minimal and focused on domain concepts
 */

/**
 * @type MessageContentPart
 * @role Content part structure from OpenAI
 * @invariants
 *   - type: always string
 *   - text: optional string
 */
export type MessageContentPart = { type: string; text?: string };

/**
 * @type MessageContent
 * @role Union type for OpenAI message content
 * @invariants
 *   - string: plain text content
 *   - MessageContentPart[]: structured content parts
 */
export type MessageContent = string | MessageContentPart[];

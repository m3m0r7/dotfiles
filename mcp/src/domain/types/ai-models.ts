/**
 * @layer Domain
 * @role AI model-specific type definitions
 * @deps None
 * @exports MessageContentPart, MessageContent
 * @invariants
 *   - MessageContent: string or MessageContentPart[]
 *   - MessageContentPart: object with type and optional text
 * @notes Shared types for OpenAI and Gemini message handling
 */

/**
 * @type MessageContentPart
 * @role Content part structure from AI models
 * @invariants
 *   - type: always string
 *   - text: optional string
 */
export type MessageContentPart = { type: string; text?: string };

/**
 * @type MessageContent
 * @role Union type for AI model message content
 * @invariants
 *   - string: plain text content
 *   - MessageContentPart[]: structured content parts
 */
export type MessageContent = string | MessageContentPart[];

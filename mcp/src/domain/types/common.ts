/**
 * @layer Domain
 * @role Common type definitions shared across the application
 * @deps None
 * @exports ToolContent, ToolResponse
 * @invariants
 *   - ToolContent: always has type "text" and text content
 *   - ToolResponse: always contains array of ToolContent
 * @notes Central type definitions to avoid duplication
 */

/**
 * @type ToolContent
 * @role MCP tool content format
 * @invariants
 *   - type: always "text"
 *   - text: content string
 */
export type ToolContent = { type: "text"; text: string };

/**
 * @type ToolResponse
 * @role MCP tool response format
 * @invariants
 *   - content: array of ToolContent objects
 */
export type ToolResponse = { content: ToolContent[] };

/**
 * @type BaseModel
 * @role Minimum model structure with sortable key
 * @notes Used for generic model list formatting
 */
export type BaseModel = Record<string, unknown>;

/**
 * @layer Domain
 * @role Unified response formatting utilities
 * @deps ../types, ./error-handler
 * @exports ResponseFormatter
 * @invariants
 *   - All methods return ToolResponse format
 *   - JSON formatting uses 2-space indentation
 * @notes Centralized response formatting logic
 */

import type { ToolContent, ToolResponse, BaseModel } from "../types";
import { toErrorMessage } from "./error-handler";

/**
 * ResponseFormatter
 * @role Static class for formatting various response types
 * @notes Provides consistent formatting across all tools
 */
export class ResponseFormatter {
  /**
   * formatModelList
   * @role Sort and format model list as JSON string
   * @input models: array of model objects
   * @input sortKey: property name to sort by (default: "id")
   * @output ToolResponse with formatted JSON content
   * @invariants
   *   - Sorts models by specified key using localeCompare
   *   - Returns count and sorted models array
   *   - Pretty-prints JSON with 2-space indentation
   */
  static formatModelList<T extends BaseModel>(
    models: T[],
    sortKey: keyof T = "id" as keyof T
  ): ToolResponse {
    const sortedModels = [...models].sort((modelA, modelB) => {
      const keyA = String(modelA[sortKey] ?? "");
      const keyB = String(modelB[sortKey] ?? "");
      return keyA.localeCompare(keyB);
    });

    const textContent = JSON.stringify(
      { count: sortedModels.length, models: sortedModels },
      null,
      2
    );

    return {
      content: [
        {
          type: "text",
          text: textContent
        } satisfies ToolContent
      ]
    };
  }

  /**
   * formatModelResponse
   * @role Process AI model response text with optional JSON parsing
   * @input text: raw response text from AI model
   * @input hasJsonSchema: whether JSON schema was provided in request
   * @output ToolResponse with formatted content
   * @invariants
   *   - Parses and validates JSON when hasJsonSchema is true
   *   - Returns plain text when hasJsonSchema is false
   *   - Throws error on JSON parse failure
   */
  static formatModelResponse(
    text: string,
    hasJsonSchema: boolean
  ): ToolResponse {
    // Guard: empty response
    if (!text) {
      throw new Error("AI モデルから有効なレスポンステキストを取得できませんでした。");
    }

    // JSON schema指定時のみJSONパース
    if (hasJsonSchema) {
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
          } satisfies ToolContent
        ]
      };
    }

    // JSON schema未指定時はプレーンテキスト返却
    return {
      content: [
        {
          type: "text",
          text
        } satisfies ToolContent
      ]
    };
  }

  /**
   * formatText
   * @role Format plain text as ToolResponse
   * @input text: plain text content
   * @output ToolResponse with text content
   */
  static formatText(text: string): ToolResponse {
    return {
      content: [
        {
          type: "text",
          text
        } satisfies ToolContent
      ]
    };
  }

  /**
   * formatError
   * @role Format error as ToolResponse with isError flag
   * @input error: unknown error object
   * @output ToolResponse with error message and isError flag
   * @invariants
   *   - Always includes isError: true
   *   - Converts error to human-readable message
   */
  static formatError(error: unknown): ToolResponse & { isError: true } {
    const message = toErrorMessage(error);
    return {
      content: [
        {
          type: "text",
          text: `Error: ${message}`
        } satisfies ToolContent
      ],
      isError: true
    };
  }
}

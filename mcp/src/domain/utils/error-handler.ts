/**
 * @layer Domain
 * @role Centralized error handling utilities
 * @deps None
 * @exports toErrorMessage, AppError
 * @invariants
 *   - toErrorMessage always returns string
 *   - AppError extends Error with additional context
 * @notes Unified error handling across the application
 */

/**
 * AppError
 * @role Custom error class with additional context
 * @invariants
 *   - code: error code for categorization
 *   - cause: optional original error
 */
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly cause?: unknown
  ) {
    super(message);
    this.name = "AppError";
  }
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

/**
 * @layer Infrastructure
 * @role Gemini client factory with dependency injection support
 * @deps @google/generative-ai, process.env
 * @exports GeminiClientFactory, IGeminiClient (re-export), getGeminiApiKey
 * @invariants
 *   - Factory creates new instances (no singleton)
 *   - Throws error if GEMINI_API_KEY is not set
 * @notes Supports dependency injection for better testability
 */

import { GoogleGenerativeAI } from "@google/generative-ai";

/**
 * IGeminiClient
 * @role Interface for Gemini client (re-exported for type safety)
 * @notes Allows mocking in tests
 */
export type IGeminiClient = GoogleGenerativeAI;

/**
 * getGeminiApiKey
 * @role Get validated Gemini API key from environment
 * @returns string - API key
 * @invariants
 *   - Returns non-empty string
 *   - Throws if GEMINI_API_KEY is not set in environment
 * @throws Error when GEMINI_API_KEY is missing
 * @notes Centralizes API key validation logic
 */
export function getGeminiApiKey(): string {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    throw new Error(
      "GEMINI_API_KEY is not set. Place it in a .env file at the project root."
    );
  }
  return apiKey;
}

/**
 * GeminiClientFactory
 * @role Factory for creating Gemini client instances
 * @invariants
 *   - Validates API key before creating client
 *   - Throws descriptive error if key is missing
 */
export class GeminiClientFactory {
  /**
   * create
   * @role Create new Gemini client instance
   * @input apiKey: optional API key (defaults to env var)
   * @output GoogleGenerativeAI client instance
   * @throws Error when GEMINI_API_KEY is missing
   */
  static create(apiKey?: string): IGeminiClient {
    const key = apiKey ?? getGeminiApiKey();
    return new GoogleGenerativeAI(key);
  }
}

/**
 * getGeminiClient
 * @role Legacy function for backward compatibility
 * @returns GoogleGenerativeAI client instance
 * @deprecated Use GeminiClientFactory.create() instead
 */
export function getGeminiClient(): IGeminiClient {
  return GeminiClientFactory.create();
}

/**
 * @layer Infrastructure
 * @role Gemini client factory with dependency injection support
 * @deps @google/generative-ai, ../config/env
 * @exports GeminiClientFactory, IGeminiClient (re-export), getGeminiApiKey
 * @invariants
 *   - Factory creates new instances (no singleton)
 *   - Uses validated environment variables
 * @notes Supports dependency injection for better testability
 */

import { GoogleGenerativeAI } from "@google/generative-ai";
import { env } from "../../config";

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
 *   - Returns non-empty string from validated config
 * @notes Uses centralized environment validation
 */
export function getGeminiApiKey(): string {
  return env.GEMINI_API_KEY;
}

/**
 * GeminiClientFactory
 * @role Factory for creating Gemini client instances
 * @invariants
 *   - Uses validated environment configuration
 *   - Supports API key override for testing
 */
export class GeminiClientFactory {
  /**
   * create
   * @role Create new Gemini client instance
   * @input apiKey: optional API key (defaults to validated env var)
   * @output GoogleGenerativeAI client instance
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

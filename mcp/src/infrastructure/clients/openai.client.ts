/**
 * @layer Infrastructure
 * @role OpenAI client factory with dependency injection support
 * @deps openai, ../config/env
 * @exports OpenAIClientFactory, IOpenAIClient (re-export)
 * @invariants
 *   - Factory creates new instances (no singleton)
 *   - Uses validated environment variables
 * @notes Supports dependency injection for better testability
 */

import OpenAI from "openai";
import { env } from "../../config/env";

/**
 * IOpenAIClient
 * @role Interface for OpenAI client (re-exported for type safety)
 * @notes Allows mocking in tests
 */
export type IOpenAIClient = OpenAI;

/**
 * OpenAIClientFactory
 * @role Factory for creating OpenAI client instances
 * @invariants
 *   - Uses validated environment configuration
 *   - Supports API key override for testing
 */
export class OpenAIClientFactory {
  /**
   * create
   * @role Create new OpenAI client instance
   * @input apiKey: optional API key (defaults to validated env var)
   * @output OpenAI client instance
   */
  static create(apiKey?: string): IOpenAIClient {
    const key = apiKey ?? env.OPENAI_API_KEY;
    return new OpenAI({ apiKey: key });
  }
}

/**
 * getOpenAIClient
 * @role Legacy function for backward compatibility
 * @returns OpenAI client instance
 * @deprecated Use OpenAIClientFactory.create() instead
 */
export function getOpenAIClient(): IOpenAIClient {
  return OpenAIClientFactory.create();
}

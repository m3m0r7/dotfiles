/**
 * @layer Infrastructure
 * @role OpenAI client factory with dependency injection support
 * @deps openai, process.env
 * @exports OpenAIClientFactory, IOpenAIClient (re-export)
 * @invariants
 *   - Factory creates new instances (no singleton)
 *   - Throws error if OPENAI_API_KEY is not set
 * @notes Supports dependency injection for better testability
 */

import OpenAI from "openai";

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
 *   - Validates API key before creating client
 *   - Throws descriptive error if key is missing
 */
export class OpenAIClientFactory {
  /**
   * create
   * @role Create new OpenAI client instance
   * @input apiKey: optional API key (defaults to env var)
   * @output OpenAI client instance
   * @throws Error when OPENAI_API_KEY is missing
   */
  static create(apiKey?: string): IOpenAIClient {
    const key = apiKey ?? process.env.OPENAI_API_KEY;
    if (!key) {
      throw new Error(
        "OPENAI_API_KEY is not set. Place it in a .env file at the project root."
      );
    }
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

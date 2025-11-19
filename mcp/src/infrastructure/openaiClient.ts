/**
 * @layer Infrastructure
 * @role OpenAI client singleton management
 * @deps openai, process.env
 * @exports getOpenAIClient
 * @invariants
 *   - cachedClient is null or valid OpenAI instance
 *   - Throws error if OPENAI_API_KEY is not set
 *   - Client is created once and reused
 * @notes Singleton pattern for OpenAI client to avoid multiple instances
 */

import OpenAI from "openai";

/**
 * @variable cachedClient
 * @role Singleton cache for OpenAI client instance
 * @invariants null or valid OpenAI instance
 */
let cachedClient: OpenAI | null = null;

/**
 * getOpenAIClient
 * @role Factory function to get or create OpenAI client
 * @returns OpenAI client instance
 * @invariants
 *   - Returns cached client if available
 *   - Creates new client if cache is empty
 *   - Throws if OPENAI_API_KEY is not set in environment
 * @throws Error when OPENAI_API_KEY is missing
 */
export function getOpenAIClient(): OpenAI {
  if (cachedClient) {
    return cachedClient;
  }

  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error(
      "OPENAI_API_KEY is not set. Place it in a .env file at the project root."
    );
  }

  cachedClient = new OpenAI({ apiKey });
  return cachedClient;
}

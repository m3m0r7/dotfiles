/**
 * @layer Test
 * @role Vitest setup file for test environment
 * @notes Sets up environment variables for testing
 */

// Set test environment variables before any imports
process.env.OPENAI_API_KEY = "test-openai-api-key";
process.env.GEMINI_API_KEY = "test-gemini-api-key";
process.env.GITHUB_TOKEN = "test-github-token";

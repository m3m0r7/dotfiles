/**
 * @layer Infrastructure
 * @role Environment variable validation and type-safe configuration
 * @deps zod
 * @exports env
 * @invariants
 *   - Validates environment variables at startup
 *   - Provides type-safe access to configuration
 *   - Fails fast if required variables are missing
 * @notes Centralized configuration management
 */

import { z } from "zod";

/**
 * Environment variable schema
 * @role Define and validate all required environment variables
 * @invariants
 *   - OPENAI_API_KEY: required non-empty string
 *   - GEMINI_API_KEY: required non-empty string
 *   - GITHUB_TOKEN or GH_TOKEN: at least one required
 */
const envSchema = z.object({
  OPENAI_API_KEY: z.string().min(1, "OPENAI_API_KEY is required"),
  GEMINI_API_KEY: z.string().min(1, "GEMINI_API_KEY is required"),
  GITHUB_TOKEN: z.string().optional(),
  GH_TOKEN: z.string().optional(),
  NODE_ENV: z.enum(["development", "production", "test"]).default("development"),
}).refine(
  (data) => data.GITHUB_TOKEN || data.GH_TOKEN,
  {
    message: "Either GITHUB_TOKEN or GH_TOKEN must be set",
    path: ["GITHUB_TOKEN"],
  }
);

/**
 * Validated and typed environment configuration
 * @role Provides type-safe access to environment variables
 * @throws {ZodError} if validation fails
 */
export const env = envSchema.parse(process.env);

/**
 * Type of validated environment
 */
export type Env = z.infer<typeof envSchema>;

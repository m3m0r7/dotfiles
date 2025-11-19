/**
 * @layer Domain
 * @role Input validation schemas using Zod
 * @deps zod
 * @exports callOpenaiModelInputSchema, CallOpenaiModelInput
 * @invariants
 *   - callOpenaiModelInputSchema: single source of truth for call_openai_model tool input
 *   - All fields have validation constraints
 * @notes Keep schemas aligned with OpenAI API requirements
 */

import { z } from "zod";

/**
 * @schema callOpenaiModelInputSchema
 * @role Validation schema for call_openai_model tool
 * @fields
 *   - model: required non-empty string
 *   - instructions: required non-empty string
 *   - system: optional system message
 *   - json_schema: optional JSON schema string
 *   - temperature: optional number [0, 2]
 *   - max_tokens: optional positive integer
 */
export const callOpenaiModelInputSchema = z.object({
  model: z.string().min(1, "model は必須です"),
  instructions: z.string().min(1, "instructions は必須です"),
  system: z.string().optional(),
  json_schema: z.string().optional(),
  temperature: z.number().min(0).max(2).optional(),
  max_tokens: z.number().int().positive().optional()
});

/**
 * @type CallOpenaiModelInput
 * @role Inferred type from callOpenaiModelInputSchema
 * @invariants Always validated against callOpenaiModelInputSchema
 */
export type CallOpenaiModelInput = z.infer<typeof callOpenaiModelInputSchema>;

/**
 * @schema githubGraphqlAgentInputSchema
 * @role Validation schema for github_graphql_agent tool
 * @fields
 *   - query: required GraphQL query string
 *   - variables: optional JSON object with query variables
 *   - use_repo_context: auto-inject owner/name from .git (default true)
 *   - task: optional natural language description for logging
 */
export const githubGraphqlAgentInputSchema = z.object({
  query: z.string().min(1, "query は必須です"),
  variables: z.record(z.unknown()).optional(),
  use_repo_context: z.boolean().optional(),
  task: z.string().optional()
});

/**
 * @type GithubGraphqlAgentInput
 * @role Inferred type for github_graphql_agent tool input
 */
export type GithubGraphqlAgentInput = z.infer<typeof githubGraphqlAgentInputSchema>;

/**
 * @schema playwrightAgentInputSchema
 * @role Validation schema for playwright_agent tool
 * @fields
 *   - task: required natural language instruction for browser automation
 *   - url: optional starting URL
 *   - headless: run browser in headless mode (default true)
 *   - screenshot: take screenshot after task completion (default false)
 *   - screenshot_path: path to save screenshot (default: ./screenshot.png)
 */
export const playwrightAgentInputSchema = z.object({
  task: z.string().min(1, "task は必須です"),
  url: z.string().url().optional(),
  headless: z.boolean().optional(),
  screenshot: z.boolean().optional(),
  screenshot_path: z.string().optional()
});

/**
 * @type PlaywrightAgentInput
 * @role Inferred type for playwright_agent tool input
 */
export type PlaywrightAgentInput = z.infer<typeof playwrightAgentInputSchema>;

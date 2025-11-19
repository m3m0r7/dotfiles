/**
 * @layer Domain
 * @role GitHub-specific validation schemas
 * @deps zod
 * @exports githubGraphqlAgentInputSchema, GithubGraphqlAgentInput
 * @invariants All fields have validation constraints for GitHub GraphQL queries
 */

import { z } from "zod";

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

/**
 * @layer Domain/Application boundary
 * @role Execute arbitrary GitHub GraphQL queries with auto-detected repo context
 * @deps ../infrastructure/git, ../infrastructure/githubApi
 * @exports runGithubGraphqlAgent, GithubGraphqlAgentResult
 */

import type { GithubGraphqlAgentInput } from "./schemas.js";
import { toErrorMessage } from "./utils.js";
import { callGitHubGraphql } from "../infrastructure/githubApi.js";
import { detectGitHubRepo, findGitRoot } from "../infrastructure/git.js";

export interface GithubGraphqlAgentResult {
  repository?: string;
  gitRoot?: string;
  query: string;
  variables: Record<string, unknown>;
  data: unknown;
  task?: string;
}

/**
 * Main execution point for github graphql agent
 * @input GithubGraphqlAgentInput
 * @output GithubGraphqlAgentResult (throws on GraphQL errors)
 */
export async function runGithubGraphqlAgent(
  input: GithubGraphqlAgentInput
): Promise<GithubGraphqlAgentResult> {
  const useRepoContext = input.use_repo_context ?? true;
  const baseVariables = input.variables ?? {};

  let repoInfo: { owner: string; name: string; slug: string } | null = null;
  let gitRoot: string | undefined;

  // Auto-detect repo context if requested
  if (useRepoContext) {
    try {
      gitRoot = await findGitRoot();
      repoInfo = await detectGitHubRepo(gitRoot);
    } catch (error: unknown) {
      const message = toErrorMessage(error);
      throw new Error(
        `リポジトリ情報の自動検出に失敗しました。use_repo_context を false にするか、Git リポジトリ内で実行してください: ${message}`
      );
    }
  }

  // Merge auto-detected repo variables with user-provided variables
  const mergedVariables: Record<string, string | number | undefined> = {};

  // Copy base variables (only primitive types)
  for (const [key, value] of Object.entries(baseVariables)) {
    if (typeof value === "string" || typeof value === "number" || value === undefined) {
      mergedVariables[key] = value;
    }
  }

  if (repoInfo) {
    // Only inject owner/name if not already provided by user
    if (!mergedVariables.owner) {
      mergedVariables.owner = repoInfo.owner;
    }
    if (!mergedVariables.name) {
      mergedVariables.name = repoInfo.name;
    }
  }

  // Execute GraphQL query
  let data: unknown;
  try {
    data = await callGitHubGraphql<unknown>(input.query, mergedVariables);
  } catch (error: unknown) {
    const message = toErrorMessage(error);
    throw new Error(`GitHub GraphQL クエリの実行に失敗しました: ${message}`);
  }

  return {
    repository: repoInfo?.slug,
    gitRoot,
    query: input.query,
    variables: mergedVariables,
    data,
    task: input.task
  };
}

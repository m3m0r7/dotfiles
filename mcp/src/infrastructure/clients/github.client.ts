/**
 * @layer Infrastructure
 * @role GitHub GraphQL client factory with dependency injection support
 * @deps @octokit/graphql, process.env
 * @exports GitHubClientFactory, IGitHubClient, GraphqlVariables
 * @invariants
 *   - Factory creates new instances (no singleton)
 *   - Throws if GITHUB_TOKEN/GH_TOKEN not set
 * @notes Supports dependency injection for better testability
 */

import { graphql } from "@octokit/graphql";

/**
 * GraphqlVariables
 * @role Type definition for GraphQL query variables
 * @invariants Record with string keys and string|number|undefined values
 */
export type GraphqlVariables = Record<string, string | number | undefined>;

/**
 * IGitHubClient
 * @role Interface for GitHub GraphQL client
 * @notes Allows mocking in tests
 */
export type IGitHubClient = typeof graphql;

/**
 * GitHubClientFactory
 * @role Factory for creating GitHub GraphQL client instances
 * @invariants
 *   - Validates GitHub token before creating client
 *   - Supports both GITHUB_TOKEN and GH_TOKEN env vars
 *   - Throws descriptive error if token is missing
 */
export class GitHubClientFactory {
  /**
   * create
   * @role Create new GitHub GraphQL client instance
   * @input token: optional GitHub token (defaults to env var)
   * @output Configured graphql client
   * @throws Error when neither GITHUB_TOKEN nor GH_TOKEN is set
   */
  static create(token?: string): IGitHubClient {
    const githubToken = token ?? process.env.GITHUB_TOKEN ?? process.env.GH_TOKEN;
    if (!githubToken) {
      throw new Error(
        "GitHub API へ接続するには GITHUB_TOKEN もしくは GH_TOKEN を設定してください。"
      );
    }

    return graphql.defaults({
      headers: {
        authorization: `bearer ${githubToken}`
      }
    });
  }
}

/**
 * callGitHubGraphql
 * @role Execute GitHub GraphQL request
 * @input query: GraphQL query string, variables: query variables
 * @output Promise<T> - typed response from GitHub API
 * @throws Error when GitHub GraphQL call fails
 * @notes Generic function - caller specifies response type T
 */
export async function callGitHubGraphql<T>(
  query: string,
  variables: GraphqlVariables,
  client?: IGitHubClient
): Promise<T> {
  const graphqlClient = client ?? GitHubClientFactory.create();
  try {
    return await graphqlClient<T>(query, variables);
  } catch (error: unknown) {
    throw new Error(`GitHub GraphQL 呼び出しに失敗しました: ${String(error)}`);
  }
}

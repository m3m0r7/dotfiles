/**
 * @layer Infrastructure
 * @role Thin wrapper around GitHub GraphQL via Octokit
 * @deps @octokit/graphql
 * @exports callGitHubGraphql
 */

import { graphql } from "@octokit/graphql";

export type GraphqlVariables = Record<string, string | number | undefined>;

let cachedGraphql: typeof graphql | null = null;

function getGraphqlClient(): typeof graphql {
  if (cachedGraphql) {
    return cachedGraphql;
  }

  const token = process.env.GITHUB_TOKEN || process.env.GH_TOKEN;
  if (!token) {
    throw new Error(
      "GitHub API へ接続するには GITHUB_TOKEN もしくは GH_TOKEN を設定してください。"
    );
  }

  cachedGraphql = graphql.defaults({
    headers: {
      authorization: `bearer ${token}`
    }
  });
  return cachedGraphql;
}

/**
 * Execute GitHub GraphQL request
 */
export async function callGitHubGraphql<T>(
  query: string,
  variables: GraphqlVariables
): Promise<T> {
  const client = getGraphqlClient();
  try {
    return (await client<T>(query, variables)) as T;
  } catch (error: unknown) {
    throw new Error(`GitHub GraphQL 呼び出しに失敗しました: ${String(error)}`);
  }
}

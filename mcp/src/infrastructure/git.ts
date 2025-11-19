/**
 * @layer Infrastructure
 * @role Git helper utilities (root detection, remote parsing)
 * @deps ./commandRunner, node:path
 * @exports findGitRoot, getGitRemoteUrl, parseGitHubRepoSlug, detectGitHubRepo
 */

import path from "node:path";
import { CommandError, runCommand } from "./commandRunner.js";

/**
 * Discover git root by ascending directories and invoking git rev-parse
 */
export async function findGitRoot(startDir: string = process.cwd()): Promise<string> {
  let current = path.resolve(startDir);

  while (true) {
    try {
      const { stdout } = await runCommand("git", ["rev-parse", "--show-toplevel"], {
        cwd: current
      });
      const root = stdout.trim();
      if (root) {
        return root;
      }
    } catch (error: unknown) {
      if (!(error instanceof CommandError)) {
        throw error;
      }
      // continue walking up when git reports no repository
    }

    const parent = path.dirname(current);
    if (parent === current) {
      break;
    }
    current = parent;
  }

  throw new Error(
    `Git リポジトリルートが見つかりませんでした (開始ディレクトリ: ${startDir}).`
  );
}

/**
 * Retrieve git remote URL
 */
export async function getGitRemoteUrl(
  repoRoot: string,
  remoteName = "origin"
): Promise<string> {
  try {
    const { stdout } = await runCommand(
      "git",
      ["config", "--get", `remote.${remoteName}.url`],
      { cwd: repoRoot }
    );
    const remote = stdout.trim();
    if (!remote) {
      throw new Error();
    }
    return remote;
  } catch (error: unknown) {
    const message =
      error instanceof CommandError
        ? error.stderr || error.message
        : String(error);
    throw new Error(
      `git remote '${remoteName}' の URL を取得できませんでした: ${message}`
    );
  }
}

/**
 * Repository coordinates parsed from remote URL
 */
export interface GitHubRepoSlug {
  owner: string;
  name: string;
  slug: string;
}

function normalizeRepoName(name: string): string {
  return name.replace(/\.git$/i, "");
}

/**
 * Parse owner/name from remote URL when it points to GitHub
 */
export function parseGitHubRepoSlug(remoteUrl: string): GitHubRepoSlug | null {
  const trimmed = remoteUrl.trim();
  if (!trimmed) return null;

  // SSH style: git@github.com:owner/repo.git
  const sshMatch = trimmed.match(/git@github\.com:(?<owner>[^\/]+)\/(?<name>.+)$/i);
  if (sshMatch?.groups) {
    const owner = sshMatch.groups.owner;
    const name = normalizeRepoName(sshMatch.groups.name);
    return { owner, name, slug: `${owner}/${name}` };
  }

  try {
    const url = new URL(trimmed);
    if (!url.hostname.toLowerCase().endsWith("github.com")) {
      return null;
    }
    const segments = url.pathname.replace(/^\//, "").split("/");
    if (segments.length < 2) {
      return null;
    }
    const [owner, nameWithMaybeGit] = segments;
    const name = normalizeRepoName(nameWithMaybeGit);
    return { owner, name, slug: `${owner}/${name}` };
  } catch {
    // fall back to loose matching: github.com/<owner>/<repo>
    const genericMatch = trimmed.match(/github\.com[:\/](?<owner>[^\/]+)\/(?<name>.+)$/i);
    if (genericMatch?.groups) {
      const owner = genericMatch.groups.owner;
      const name = normalizeRepoName(genericMatch.groups.name);
      return { owner, name, slug: `${owner}/${name}` };
    }
    return null;
  }
}

/**
 * Combined helper for GitHub repo info (remote URL + slug)
 */
export interface GitHubRepoInfo extends GitHubRepoSlug {
  remoteUrl: string;
}

export async function detectGitHubRepo(repoRoot: string): Promise<GitHubRepoInfo> {
  const remoteUrl = await getGitRemoteUrl(repoRoot);
  const slug = parseGitHubRepoSlug(remoteUrl);
  if (!slug) {
    throw new Error(
      `GitHub リポジトリではないリモート URL です: ${remoteUrl}`
    );
  }
  return { ...slug, remoteUrl };
}

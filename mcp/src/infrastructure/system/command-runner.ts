/**
 * @layer Infrastructure
 * @role Execute shell commands and normalize results/errors
 * @deps node:child_process
 * @exports runCommand, CommandError
 * @invariants
 *   - Always resolves stdout/stderr as UTF-8 strings
 *   - Rejects with CommandError when exit code is non-zero
 *   - Supports optional cwd/env/timeout overrides
 */

import { spawn } from "node:child_process";

/**
 * Command execution options
 */
export interface CommandOptions {
  cwd?: string;
  env?: NodeJS.ProcessEnv;
  timeoutMs?: number;
}

/**
 * Command execution result payload
 */
export interface CommandResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}

/**
 * Error thrown when command exits abnormally
 */
export class CommandError extends Error {
  public readonly command: string;
  public readonly args: readonly string[];
  public readonly exitCode: number | null;
  public readonly stdout: string;
  public readonly stderr: string;

  constructor(
    command: string,
    args: readonly string[],
    exitCode: number | null,
    stdout: string,
    stderr: string,
    message?: string
  ) {
    super(
      message ??
        `Command failed: ${command} ${args.join(" ")}`
    );
    this.name = "CommandError";
    this.command = command;
    this.args = args;
    this.exitCode = exitCode;
    this.stdout = stdout;
    this.stderr = stderr;
  }
}

/**
 * Execute a command and collect stdout/stderr buffers
 */
export function runCommand(
  command: string,
  args: string[],
  options: CommandOptions = {}
): Promise<CommandResult> {
  return new Promise((resolve, reject) => {
    const spawnOptions = {
      cwd: options.cwd,
      env: { ...process.env, ...options.env }
    };

    const child = spawn(command, args, spawnOptions);
    let stdout = "";
    let stderr = "";
    let timeout: NodeJS.Timeout | undefined;
    const stdoutStream = child.stdout;
    const stderrStream = child.stderr;

    if (!stdoutStream || !stderrStream) {
      reject(
        new CommandError(
          command,
          args,
          null,
          stdout,
          stderr,
          "子プロセスのストリームを初期化できませんでした"
        )
      );
      return;
    }

    stdoutStream.setEncoding("utf8");
    stderrStream.setEncoding("utf8");

    stdoutStream.on("data", (chunk: string) => {
      stdout += chunk;
    });

    stderrStream.on("data", (chunk: string) => {
      stderr += chunk;
    });

    const clearTimer = (): void => {
      if (timeout) {
        clearTimeout(timeout);
        timeout = undefined;
      }
    };

    if (options.timeoutMs && options.timeoutMs > 0) {
      timeout = setTimeout(() => {
        child.kill("SIGKILL");
        clearTimer();
        reject(
          new CommandError(
            command,
            args,
            null,
            stdout,
            stderr,
            `Command timed out after ${options.timeoutMs}ms`
          )
        );
      }, options.timeoutMs);
    }

    child.on("error", (error: Error) => {
      clearTimer();
      reject(
        new CommandError(
          command,
          args,
          null,
          stdout,
          stderr,
          error.message
        )
      );
    });

    child.on("close", (exitCode: number | null) => {
      clearTimer();
      if (exitCode === 0) {
        resolve({ stdout, stderr, exitCode: 0 });
        return;
      }

      reject(new CommandError(command, args, exitCode, stdout, stderr));
    });
  });
}

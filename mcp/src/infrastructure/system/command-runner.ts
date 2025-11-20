/**
 * @layer Infrastructure
 * @role Execute shell commands and normalize results/errors with security restrictions
 * @deps node:child_process
 * @exports runCommand, CommandError
 * @invariants
 *   - Always resolves stdout/stderr as UTF-8 strings
 *   - Rejects with CommandError when exit code is non-zero
 *   - Supports optional cwd/env/timeout overrides
 *   - Commands are validated against whitelist
 */

import { spawn } from "node:child_process";

/**
 * Allowed commands for execution
 * @note Override via ALLOWED_COMMANDS env var (comma-separated)
 */
const DEFAULT_ALLOWED_COMMANDS = [
  "git",
  "node",
  "npm",
  "npx",
  "pnpm",
  "yarn",
  "tsc",
  "eslint"
];

/**
 * Get allowed commands from environment or use defaults
 */
function getAllowedCommands(): string[] {
  const envCommands = process.env.ALLOWED_COMMANDS;
  if (envCommands) {
    return envCommands.split(",").map(c => c.trim()).filter(Boolean);
  }
  return DEFAULT_ALLOWED_COMMANDS;
}

/**
 * Validate command against whitelist
 * @throws Error if command is not allowed
 */
function validateCommand(command: string): void {
  const allowedCommands = getAllowedCommands();
  if (!allowedCommands.includes(command)) {
    throw new Error(
      `Security Error: Command "${command}" is not in the allowed list. ` +
      `Allowed commands: ${allowedCommands.join(", ")}`
    );
  }
}

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
 * @note Command is validated against whitelist before execution
 */
export function runCommand(
  command: string,
  args: string[],
  options: CommandOptions = {}
): Promise<CommandResult> {
  return new Promise((resolve, reject) => {
    // Security: validate command before execution
    try {
      validateCommand(command);
    } catch (error) {
      reject(error instanceof Error ? error : new Error(String(error)));
      return;
    }

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

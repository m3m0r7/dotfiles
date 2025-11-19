/**
 * @layer Infrastructure
 * @role Central export point for all client factories
 * @deps ./openai.client, ./gemini.client, ./github.client
 * @exports All client factories and types
 * @notes Barrel export for convenient imports
 */

export * from "./openai.client";
export * from "./gemini.client";
export * from "./github.client";

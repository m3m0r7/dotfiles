/**
 * @layer Domain
 * @role Playwright-specific validation schemas
 * @deps zod
 * @exports playwrightAgentInputSchema, PlaywrightAgentInput
 * @invariants All fields have validation constraints for browser automation
 */

import { z } from "zod";

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

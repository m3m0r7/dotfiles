/**
 * @layer Domain
 * @role OpenAI-specific validation schemas
 * @deps zod
 * @exports callOpenaiModelInputSchema, CallOpenaiModelInput
 * @invariants All fields have validation constraints aligned with OpenAI API
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
 */
export type CallOpenaiModelInput = z.infer<typeof callOpenaiModelInputSchema>;

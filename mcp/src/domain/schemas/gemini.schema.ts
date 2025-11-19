/**
 * @layer Domain
 * @role Gemini-specific validation schemas
 * @deps zod
 * @exports callGeminiModelInputSchema, CallGeminiModelInput
 * @invariants All fields have validation constraints aligned with Gemini API
 */

import { z } from "zod";

/**
 * @schema callGeminiModelInputSchema
 * @role Validation schema for call_gemini_model tool
 * @fields
 *   - model: required non-empty string
 *   - instructions: required non-empty string
 *   - system: optional system instruction
 *   - json_schema: optional JSON schema string
 *   - temperature: optional number [0, 2]
 *   - max_tokens: optional positive integer
 */
export const callGeminiModelInputSchema = z.object({
  model: z.string().min(1, "model は必須です"),
  instructions: z.string().min(1, "instructions は必須です"),
  system: z.string().optional(),
  json_schema: z.string().optional(),
  temperature: z.number().min(0).max(2).optional(),
  max_tokens: z.number().int().positive().optional()
});

/**
 * @type CallGeminiModelInput
 * @role Inferred type from callGeminiModelInputSchema
 */
export type CallGeminiModelInput = z.infer<typeof callGeminiModelInputSchema>;

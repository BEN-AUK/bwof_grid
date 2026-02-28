/// <reference path="./deno.d.ts" />

const DEFAULT_GEMINI_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

/**
 * Gemini API 基础 URL（不含 key 参数）。
 * 优先从环境变量 GEMINI_API_URL 读取，缺失时使用默认 v1beta 路径。
 */
export const GEMINI_API_URL =
  Deno.env.get("GEMINI_API_URL") ?? DEFAULT_GEMINI_URL

/// <reference path="./deno.d.ts" />

/**
 * 系统级 Prompt 配置，供 parser.service 等注入使用。
 */
export const SYSTEM_PROMPTS = {
  /** 文档识别：简要描述文档内容（当前能力） */
  DOCUMENT_IDENTIFIER:
    "You are a document analyzer. Identify this document and provide a brief description in less than 20 English words. Output must be a strict JSON object with a single key 'description'. No markdown, no preamble.",
  /** 合规解析（SS/12A 等），预留 */
  SS_EXTRACTOR: "",
} as const

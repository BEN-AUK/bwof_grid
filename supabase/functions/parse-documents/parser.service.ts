/// <reference path="./deno.d.ts" />
import type { ExtractionResult } from "./types.ts"

/** 供注入的 Gemini 配置（如 API 基础 URL） */
export interface GeminiConfig {
  url: string
}

/** 供注入的系统 Prompt（如 document identifier 文本） */
export interface SystemPromptInjection {
  text: string
}

const BASE64_ALPHABET =
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

/** Uint8Array → base64 字符串（Deno 环境，无外部依赖）. */
function toBase64(bytes: Uint8Array): string {
  let out = ""
  for (let i = 0; i < bytes.length; i += 3) {
    const a = bytes[i]!
    const b = bytes[i + 1]
    const c = bytes[i + 2]
    out += BASE64_ALPHABET[a >> 2]
    out += BASE64_ALPHABET[((a & 3) << 4) | (b ?? 0) >> 4]
    out += b !== undefined ? BASE64_ALPHABET[((b & 15) << 2) | (c ?? 0) >> 6] : "="
    out += c !== undefined ? BASE64_ALPHABET[c & 63] : "="
  }
  return out
}

/**
 * 将 File 转为 Base64 字符串（Deno 环境，二进制安全）。
 */
export async function fileToBase64(file: File): Promise<string> {
  const buffer = await file.arrayBuffer()
  return toBase64(new Uint8Array(buffer))
}

/**
 * 从 AI 返回文本中提取纯 JSON，剔除 ```json ... ``` 等代码块标签。
 */
function stripJsonCodeBlock(raw: string): string {
  let s = raw.trim()
  const codeBlockMatch = s.match(/^```(?:json)?\s*([\s\S]*?)```\s*$/im)
  if (codeBlockMatch) {
    s = codeBlockMatch[1].trim()
  }
  s = s.replace(/^```(?:json)?\s*/im, "").replace(/\s*```\s*$/im, "")
  return s.trim()
}

/**
 * 使用 Gemini 分析单个文件，返回 description。
 */
async function analyzeOneFile(
  file: File,
  apiKey: string,
  config: GeminiConfig,
  prompt: SystemPromptInjection
): Promise<ExtractionResult> {
  const data = await fileToBase64(file)
  const mimeType = file.type || "application/octet-stream"
  const url = `${config.url}?key=${apiKey}`

  const body = {
    systemInstruction: {
      parts: [{ text: prompt.text }],
    },
    contents: [
      {
        role: "user",
        parts: [
          {
            inlineData: {
              mimeType,
              data,
            },
          },
        ],
      },
    ],
  }

  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  })

  if (!res.ok) {
    const errText = await res.text()
    throw new Error(`Gemini API error (${res.status}): ${errText}`)
  }

  const json = await res.json()
  const textPart = json?.candidates?.[0]?.content?.parts?.[0]?.text
  if (typeof textPart !== "string") {
    throw new Error("Gemini response missing text in candidates[0].content.parts[0]")
  }

  const cleaned = stripJsonCodeBlock(textPart)
  const parsed = JSON.parse(cleaned) as { description?: string }
  const description = typeof parsed?.description === "string" ? parsed.description : String(parsed?.description ?? "Unknown document")

  return { original_name: file.name, description }
}

/**
 * 并行处理多个文件，调用 Gemini 提取描述。
 * config 与 prompt 由入口注入，避免硬编码。
 */
export async function processFiles(
  files: File[],
  apiKey: string,
  config: GeminiConfig,
  prompt: SystemPromptInjection
): Promise<ExtractionResult[]> {
  return Promise.all(files.map((file) => analyzeOneFile(file, apiKey, config, prompt)))
}

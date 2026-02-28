/// <reference path="./deno.d.ts" />
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

// --- 资源限制配置 ---
const MAX_FILES = 5
const MAX_SIZE_BYTES = 10 * 1024 * 1024 // 10MB

const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
}

function jsonError(status: number, code: string, message: string): Response {
  return new Response(JSON.stringify({ code, message }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  })
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  try {
    // 环境变量校验：必须在处理请求前检查
    const apiKey = Deno.env.get("LLM_API_KEY")
    if (!apiKey) {
      return jsonError(500, "CONFIG_ERROR", "Server configuration error: missing API Key")
    }

    const formData = await req.formData()
    const files = formData.getAll("files") as File[]

    if (!files.length) {
      return jsonError(400, "NO_FILES", "No files uploaded")
    }

    if (files.length > MAX_FILES) {
      return jsonError(400, "MAX_FILES_EXCEEDED", "Maximum 5 files allowed")
    }

    for (let i = 0; i < files.length; i++) {
      const file = files[i]
      if (file.size > MAX_SIZE_BYTES) {
        return jsonError(
          413,
          "PAYLOAD_TOO_LARGE",
          `File "${file.name}" exceeds maximum size (10MB)`
        )
      }
    }

    // 模拟 AI 提取逻辑 (下一步接入真实的 LLM 调用)
    const results = await Promise.all(
      files.map(async (file) => {
        return {
          original_name: file.name,
          extracted_name: `AI_PROCESSED_${file.name.split(".")[0]}`,
          type: file.type,
          size: file.size,
        }
      })
    )

    return new Response(JSON.stringify({ success: true, data: results }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (error) {
    console.error("Function error:", error)
    const message = error instanceof Error ? error.message : "Unknown error"
    return jsonError(500, "INTERNAL_ERROR", message)
  }
})
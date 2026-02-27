/**
 * Browser Supabase client only. Safe for Client Components.
 * For Server Components / Route Handlers use @/lib/supabase/server.
 * Env: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY.
 */
import { createBrowserClient } from "@supabase/ssr";
import type { Database } from "@/lib/database.types";

function getEnv() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) {
    throw new Error(
      "Missing Supabase Environment Variables: ensure NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY are set in .env.local"
    );
  }
  return { url, key };
}

/** Browser/client Supabase instance (use in Client Components only). */
export function createClient() {
  const { url, key } = getEnv();
  if (process.env.NODE_ENV === "development") {
    console.debug("[Supabase] Env loaded:", { url_length: url.length, key_length: key.length });
  }
  return createBrowserClient<Database>(url, key);
}

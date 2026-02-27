/**
 * Server Supabase client. Use only in Server Components, Route Handlers, Server Actions.
 * Do not import this file from Client Components.
 */
import { createServerClient as createServerClientSSR } from "@supabase/ssr";
import { cookies } from "next/headers";
import type { Database } from "@/lib/database.types";

function getEnv() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const key = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
  if (!url || !key) {
    console.error("Missing Supabase Environment Variables");
    throw new Error(
      "Missing Supabase Environment Variables: ensure NEXT_PUBLIC_SUPABASE_URL and NEXT_PUBLIC_SUPABASE_ANON_KEY are set in .env.local"
    );
  }
  return { url, key };
}

/** Server Supabase instance (Next.js 15: cookies() is async). */
export async function createClient() {
  const { url, key } = getEnv();
  const cookieStore = await cookies();
  return createServerClientSSR<Database>(url, key, {
    cookies: {
      getAll() {
        return cookieStore.getAll();
      },
      setAll(cookiesToSet) {
        try {
          cookiesToSet.forEach(({ name, value, options }) =>
            cookieStore.set(name, value, options)
          );
        } catch {
          // Ignore in Server Component (e.g. during static render)
        }
      },
    },
  });
}

import { NextResponse, type NextRequest } from "next/server";
import { createSupabaseMiddlewareClient } from "@/lib/supabase/middleware";

const protectedPaths = ["/dashboard"];
const publicPaths = ["/", "/unauthorized", "/login", "/auth/callback"];

function isProtected(pathname: string) {
  return protectedPaths.some(
    (p) => pathname === p || pathname.startsWith(p + "/")
  );
}

function isPublic(pathname: string) {
  return (
    publicPaths.some((p) => pathname === p) || pathname.startsWith("/auth/")
  );
}

export async function middleware(request: NextRequest) {
  const { supabase, response } = await createSupabaseMiddlewareClient(request);
  const { data: { user } } = await supabase.auth.getUser();
  const pathname = request.nextUrl.pathname;

  if (isPublic(pathname)) {
    return response;
  }

  if (isProtected(pathname) && !user) {
    const login = new URL("/login", request.url);
    login.searchParams.set("next", pathname);
    const redirectRes = NextResponse.redirect(login);
    response.cookies.getAll().forEach((c) => redirectRes.cookies.set(c.name, c.value));
    return redirectRes;
  }

  return response;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};

import createMiddleware from "next-intl/middleware";
import { NextResponse, type NextRequest } from "next/server";
import { createSupabaseMiddlewareClient } from "@/lib/supabase/middleware";
import { routing } from "@/i18n/routing";

const handleI18nRouting = createMiddleware(routing);

const protectedPathSegments = ["dashboard"];
const publicPathSegments = ["", "unauthorized", "login", "register", "auth"];

function getLocaleAndPath(pathname: string): { locale: string; pathWithoutLocale: string } {
  const segments = pathname.split("/").filter(Boolean);
  const locale =
    segments[0] === "en" || segments[0] === "zh" ? segments[0] : routing.defaultLocale;
  const pathWithoutLocale =
    segments[0] === "en" || segments[0] === "zh"
      ? "/" + segments.slice(1).join("/") || "/"
      : pathname || "/";
  return { locale, pathWithoutLocale };
}

function isProtected(pathWithoutLocale: string) {
  return protectedPathSegments.some(
    (p) =>
      pathWithoutLocale === `/${p}` || pathWithoutLocale.startsWith(`/${p}/`)
  );
}

function isPublic(pathWithoutLocale: string) {
  if (pathWithoutLocale === "/" || pathWithoutLocale === "") return true;
  return publicPathSegments.some(
    (p) =>
      pathWithoutLocale === `/${p}` ||
      pathWithoutLocale.startsWith(`/${p}/`)
  );
}

export async function middleware(request: NextRequest) {
  const i18nResponse = handleI18nRouting(request);

  if (i18nResponse.status >= 300 && i18nResponse.status < 400) {
    return i18nResponse;
  }

  const pathname = request.nextUrl.pathname;
  const { locale, pathWithoutLocale } = getLocaleAndPath(pathname);

  const { supabase, response: supabaseResponse } =
    await createSupabaseMiddlewareClient(request);

  supabaseResponse.cookies.getAll().forEach((c) =>
    i18nResponse.cookies.set(c.name, c.value)
  );

  const { data: { user } } = await supabase.auth.getUser();

  if (isPublic(pathWithoutLocale)) {
    return i18nResponse;
  }

  if (isProtected(pathWithoutLocale) && !user) {
    const loginUrl = new URL(`/${locale}/login`, request.url);
    loginUrl.searchParams.set("next", pathWithoutLocale);
    const redirectRes = NextResponse.redirect(loginUrl);
    i18nResponse.cookies.getAll().forEach((c) =>
      redirectRes.cookies.set(c.name, c.value)
    );
    return redirectRes;
  }

  return i18nResponse;
}

export const config = {
  matcher: [
    "/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)",
  ],
};

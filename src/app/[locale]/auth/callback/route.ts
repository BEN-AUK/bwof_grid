import { NextResponse } from "next/server";
import { createClient } from "@/lib/supabase/server";

type RouteParams = { params: Promise<{ locale: string }> };

export async function GET(request: Request, { params }: RouteParams) {
  const { locale } = await params;
  const { searchParams, origin } = new URL(request.url);
  const code = searchParams.get("code");
  const next = searchParams.get("next") ?? "/dashboard";

  if (code) {
    const supabase = await createClient();
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (error) {
      return NextResponse.redirect(
        `${origin}/${locale}/login?error=${encodeURIComponent(error.message)}`
      );
    }

    const { data: { user } } = await supabase.auth.getUser();
    if (!user?.id) {
      return NextResponse.redirect(`${origin}/${locale}/login?error=session`);
    }

    await supabase
      .from("profiles")
      .upsert({ id: user.id }, { onConflict: "id" });

    const { data: profile } = await supabase
      .from("profiles")
      .select("organization_id")
      .eq("id", user.id)
      .single();

    if (profile?.organization_id) {
      return NextResponse.redirect(`${origin}/${locale}${next}`);
    }

    return NextResponse.redirect(`${origin}/${locale}/unauthorized`);
  }

  return NextResponse.redirect(`${origin}/${locale}/login`);
}

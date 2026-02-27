import { createClient } from "@/lib/supabase/server";
import { redirect } from "@/i18n/navigation";
import { getTranslations, getLocale } from "next-intl/server";

const mainClass = "min-h-screen bg-slate-50 p-6";
const titleClass = "text-xl font-semibold text-slate-900";
const welcomeClass = "mt-2 text-sm text-slate-600";

export default async function DashboardPage() {
  const locale = await getLocale();
  const t = await getTranslations("DashboardPage");
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return redirect({ href: "/login", locale });

  await supabase
    .from("profiles")
    .upsert({ id: user.id }, { onConflict: "id" });

  return (
    <main className={mainClass}>
      <h1 className={titleClass}>{t("title")}</h1>
      <p className={welcomeClass}>{t("welcome")}</p>
    </main>
  );
}

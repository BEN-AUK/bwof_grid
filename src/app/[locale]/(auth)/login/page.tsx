import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { LoginForm } from "@/components/Auth/LoginForm";
import { LocaleSwitcher } from "@/components/Auth/LocaleSwitcher";

const loginLayout =
  "min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4";
const titleClass = "text-xl font-semibold text-slate-900";
const wrapperClass = "w-full flex flex-col items-center gap-6";

export default async function LoginPage() {
  const locale = await getLocale();
  const t = await getTranslations("LoginPage");
  const tForm = await getTranslations("LoginForm");

  return (
    <main className={loginLayout}>
      <div className={wrapperClass}>
        <div className="fixed top-4 right-4 z-10">
          <LocaleSwitcher />
        </div>
        <h1 className={titleClass}>{t("title")}</h1>
        <LoginForm />
        <p className="text-center text-sm text-slate-600">
          <Link
            href={`/${locale}/register`}
            className="underline hover:text-slate-900"
          >
            {tForm("noAccount")} {tForm("goRegister")}
          </Link>
        </p>
      </div>
    </main>
  );
}

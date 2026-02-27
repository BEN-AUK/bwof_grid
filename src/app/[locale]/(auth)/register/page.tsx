import { getTranslations } from "next-intl/server";
import { RegisterForm } from "@/components/Auth/RegisterForm";
import { LocaleSwitcher } from "@/components/Auth/LocaleSwitcher";

const registerLayout =
  "min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4";
const titleClass = "text-xl font-semibold text-slate-900";
const wrapperClass = "w-full flex flex-col items-center gap-6";

export default async function RegisterPage() {
  const t = await getTranslations("RegisterPage");

  return (
    <main className={registerLayout}>
      <div className={wrapperClass}>
        <div className="fixed top-4 right-4 z-10">
          <LocaleSwitcher />
        </div>
        <h1 className={titleClass}>{t("title")}</h1>
        <RegisterForm />
      </div>
    </main>
  );
}

import { getTranslations } from "next-intl/server";
import { Link } from "@/i18n/navigation";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";

const mainClass =
  "min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4";
const cardClass = "w-full max-w-md border-slate-200";
const titleClass = "text-slate-900";
const messageClass = "text-sm text-slate-600";
const hintClass = "text-xs text-slate-500";

export default async function UnauthorizedPage() {
  const t = await getTranslations("UnauthorizedPage");

  return (
    <main className={mainClass}>
      <Card className={cardClass}>
        <CardHeader>
          <CardTitle className={titleClass}>{t("title")}</CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <p className={messageClass}>{t("messageZh")}</p>
          <p className={hintClass}>{t("messageEn")}</p>
          <Button variant="outline" asChild>
            <Link href="/login">{t("backToSignIn")}</Link>
          </Button>
        </CardContent>
      </Card>
    </main>
  );
}

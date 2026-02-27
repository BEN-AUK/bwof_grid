"use client";

import { useLocale } from "next-intl";
import { useTranslations } from "next-intl";
import { usePathname as useNextPathname } from "next/navigation";
import { useRouter } from "@/i18n/navigation";
import { Button } from "@/components/ui/button";

const switcherWrapper = "flex gap-1";

function pathnameWithoutLocale(fullPath: string): string {
  const segment = fullPath.replace(/^\//, "").split("/")[0];
  if (segment === "en" || segment === "zh") {
    const rest = fullPath.slice(segment.length + 1);
    return rest || "/";
  }
  return fullPath;
}

export function LocaleSwitcher() {
  const locale = useLocale();
  const t = useTranslations("common");
  const fullPath = useNextPathname();
  const pathname = pathnameWithoutLocale(fullPath);
  const router = useRouter();

  return (
    <div className={switcherWrapper}>
      <Button
        type="button"
        variant={locale === "en" ? "default" : "outline"}
        size="sm"
        onClick={() => router.replace(pathname, { locale: "en" })}
      >
        {t("localeEn")}
      </Button>
      <Button
        type="button"
        variant={locale === "zh" ? "default" : "outline"}
        size="sm"
        onClick={() => router.replace(pathname, { locale: "zh" })}
      >
        {t("localeZh")}
      </Button>
    </div>
  );
}

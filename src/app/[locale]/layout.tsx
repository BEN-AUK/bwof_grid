import { NextIntlClientProvider } from "next-intl";
import { SetHtmlLang } from "./SetHtmlLang";

type Props = {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
};

export default async function LocaleLayout({ children, params }: Props) {
  const { locale } = await params;
  const messages = (
    await import(`@/messages/${locale}.json`)
  ).default as Record<string, unknown>;

  return (
    <NextIntlClientProvider locale={locale} messages={messages}>
      <SetHtmlLang locale={locale} />
      {children}
    </NextIntlClientProvider>
  );
}

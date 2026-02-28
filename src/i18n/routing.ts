import { defineRouting } from "next-intl/routing";
// a
export const routing = defineRouting({
  locales: ["en", "zh"],
  defaultLocale: "en",
  localePrefix: "always",
});

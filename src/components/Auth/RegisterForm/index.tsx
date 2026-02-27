"use client";

import { Loader2 } from "lucide-react";
import { useLocale } from "next-intl";
import { useTranslations } from "next-intl";
import Link from "next/link";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { createClient } from "@/lib/supabase/client";
import { isEmailAllowed } from "@/config/auth";
import { useToast } from "@/components/ui/use-toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import styles from "./RegisterForm.module.css";

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function registerSchema(t: (key: string) => string) {
  return z
    .object({
      email: z
        .string()
        .min(1)
        .refine((v) => emailRegex.test(v), { message: t("invalidEmail") }),
      password: z
        .string()
        .min(6, t("passwordTooShort")),
      confirmPassword: z.string().min(1),
    })
    .refine((data) => data.password === data.confirmPassword, {
      message: t("passwordMismatch"),
      path: ["confirmPassword"],
    });
}

type RegisterFields = z.infer<ReturnType<typeof registerSchema>>;

export function RegisterForm() {
  const locale = useLocale();
  const t = useTranslations("RegisterForm");
  const schema = registerSchema(t);
  const { toast } = useToast();

  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<RegisterFields>({
    resolver: zodResolver(schema),
    defaultValues: { email: "", password: "", confirmPassword: "" },
  });

  async function onSubmit(values: RegisterFields) {
    const trimmedEmail = values.email.trim();
    if (!isEmailAllowed(trimmedEmail)) {
      toast({
        variant: "destructive",
        title: t("toastErrorTitle"),
        description: t("toastEmailNotAllowedDescription"),
      });
      return;
    }

    const supabase = createClient();
    const { data, error } = await supabase.auth.signUp({
      email: trimmedEmail,
      password: values.password,
    });

    if (error) {
      toast({
        variant: "destructive",
        title: t("toastErrorTitle"),
        description: error.message,
      });
      return;
    }

    const session = data.session;
    if (session) {
      toast({
        variant: "success",
        title: t("registerSuccess"),
      });
      window.location.href = `/${locale}/dashboard`;
      return;
    }

    toast({
      variant: "success",
      title: t("registerRequestSent"),
    });
  }

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle className="text-slate-900">{t("cardTitle")}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit(onSubmit)} className={styles.wrapper}>
          <div>
            <Input
              type="email"
              placeholder={t("emailPlaceholder")}
              {...register("email")}
              disabled={isSubmitting}
              className={styles.input}
              autoComplete="email"
              aria-invalid={!!errors.email}
            />
            {errors.email && (
              <p className={styles.errorText} role="alert">
                {errors.email.message}
              </p>
            )}
          </div>
          <div>
            <Input
              type="password"
              placeholder={t("passwordPlaceholder")}
              {...register("password")}
              disabled={isSubmitting}
              className={styles.input}
              autoComplete="new-password"
              aria-invalid={!!errors.password}
            />
            {errors.password && (
              <p className={styles.errorText} role="alert">
                {errors.password.message}
              </p>
            )}
          </div>
          <div>
            <Input
              type="password"
              placeholder={t("confirmPasswordPlaceholder")}
              {...register("confirmPassword")}
              disabled={isSubmitting}
              className={styles.input}
              autoComplete="new-password"
              aria-invalid={!!errors.confirmPassword}
            />
            {errors.confirmPassword && (
              <p className={styles.errorText} role="alert">
                {errors.confirmPassword.message}
              </p>
            )}
          </div>
          <Button type="submit" disabled={isSubmitting} className={styles.submit}>
            {isSubmitting ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                {t("submitting")}
              </>
            ) : (
              t("submitButton")
            )}
          </Button>
        </form>
        <p className="mt-4 text-center text-sm text-slate-600">
          <Link href={`/${locale}/login`} className="underline hover:text-slate-900">
            {t("haveAccount")} {t("goLogin")}
          </Link>
        </p>
      </CardContent>
    </Card>
  );
}

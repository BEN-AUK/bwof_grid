"use client";

import { useState } from "react";
import { Loader2 } from "lucide-react";
import { useLocale } from "next-intl";
import { useTranslations } from "next-intl";
import { createClient } from "@/lib/supabase/client";
import { isEmailAllowed } from "@/config/auth";
import { useToast } from "@/components/ui/use-toast";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import styles from "./LoginForm.module.css";

export function LoginForm() {
  const locale = useLocale();
  const t = useTranslations("LoginForm");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    const trimmed = email.trim();
    if (!trimmed) return;

    if (!isEmailAllowed(trimmed)) {
      toast({
        variant: "destructive",
        title: t("toastEmailNotAllowedTitle"),
        description: t("toastEmailNotAllowedDescription"),
      });
      return;
    }

    setLoading(true);
    const supabase = createClient();
    const usePassword = password.length > 0;

    if (usePassword) {
      const { error } = await supabase.auth.signInWithPassword({
        email: trimmed,
        password,
      });
      setLoading(false);
      if (error) {
        toast({
          variant: "destructive",
          title: t("toastErrorTitle"),
          description: error.message,
        });
        return;
      }
      toast({
        variant: "success",
        title: t("toastLoginSuccessTitle"),
        description: t("toastLoginSuccessDescription"),
      });
      window.location.href = `/${locale}/dashboard`;
      return;
    }

    const { error } = await supabase.auth.signInWithOtp({
      email: trimmed,
      options: {
        emailRedirectTo: `${window.location.origin}/${locale}/auth/callback`,
      },
    });

    setLoading(false);

    if (error) {
      toast({
        variant: "destructive",
        title: t("toastErrorTitle"),
        description: error.message,
      });
      return;
    }

    toast({
      variant: "success",
      title: t("toastSuccessTitle"),
      description: t("toastSuccessDescription"),
    });
  }

  return (
    <Card className="w-full max-w-sm">
      <CardHeader>
        <CardTitle className="text-slate-900">{t("cardTitle")}</CardTitle>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit} className={styles.wrapper}>
          <Input
            type="email"
            placeholder={t("emailPlaceholder")}
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            disabled={loading}
            required
            className={styles.input}
            autoComplete="email"
          />
          <Input
            type="password"
            placeholder={t("passwordPlaceholder")}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            disabled={loading}
            className={styles.input}
            autoComplete="current-password"
          />
          <Button type="submit" disabled={loading} className={styles.submit}>
            {loading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                {password ? t("signingIn") : t("sendingLink")}
              </>
            ) : (
              t("submitButton")
            )}
          </Button>
        </form>
      </CardContent>
    </Card>
  );
}

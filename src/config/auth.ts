/**
 * Auth config: optional enterprise email allowlist.
 * When set, only these suffixes can request magic link; otherwise any email can request.
 * Profile check (organization_id) is always done after login in auth-callback.
 */
const ALLOWED_EMAIL_SUFFIXES = (
  process.env.NEXT_PUBLIC_ALLOWED_EMAIL_SUFFIXES ?? ""
)
  .split(",")
  .map((s) => s.trim().toLowerCase())
  .filter(Boolean);

export function isEmailAllowed(email: string): boolean {
  if (ALLOWED_EMAIL_SUFFIXES.length === 0) return true;
  const lower = email.trim().toLowerCase();
  return ALLOWED_EMAIL_SUFFIXES.some((suffix) => lower.endsWith("@" + suffix));
}

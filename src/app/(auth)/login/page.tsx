import { LoginForm } from "@/components/Auth/LoginForm";

export default function LoginPage() {
  return (
    <main className="min-h-screen bg-slate-50 flex flex-col items-center justify-center p-4">
      <div className="w-full flex flex-col items-center gap-6">
        <h1 className="text-xl font-semibold text-slate-900">
          NZ BWoF Compliance Hub
        </h1>
        <LoginForm />
      </div>
    </main>
  );
}

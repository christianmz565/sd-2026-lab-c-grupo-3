import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { HealthIndicator } from "@/components/HealthIndicator";
import { Sidebar } from "@/components/Sidebar";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "LogiFresh S.A. — Panel de Operaciones",
  description:
    "Frontend para el sistema distribuido de LogiFresh: pedidos, inventario, facturación, transporte y notificaciones.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="es"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full bg-[var(--background)] text-[var(--foreground)]">
        <div className="flex min-h-screen">
          <Sidebar />
          <div className="flex min-w-0 flex-1 flex-col">
            <header className="sticky top-0 z-10 flex h-16 items-center justify-between border-b border-[var(--border)] bg-[var(--surface)]/80 px-6 backdrop-blur">
              <div>
                <p className="text-xs uppercase tracking-wider text-slate-500">
                  LogiFresh S.A.
                </p>
                <p className="text-sm font-semibold">Panel de Operaciones</p>
              </div>
              <HealthIndicator />
            </header>
            <main className="min-w-0 flex-1 px-6 py-6">{children}</main>
          </div>
        </div>
      </body>
    </html>
  );
}

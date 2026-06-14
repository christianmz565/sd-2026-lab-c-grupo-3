"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

interface NavItem {
  href: string;
  label: string;
  icon: React.ReactNode;
}

const Icon = ({ d }: { d: string }) => (
  <svg
    xmlns="http://www.w3.org/2000/svg"
    fill="none"
    viewBox="0 0 24 24"
    strokeWidth={1.6}
    stroke="currentColor"
    className="h-4 w-4"
    aria-hidden="true"
  >
    <path strokeLinecap="round" strokeLinejoin="round" d={d} />
  </svg>
);

const items: NavItem[] = [
  {
    href: "/dashboard",
    label: "Dashboard",
    icon: (
      <Icon d="M3 12l9-9 9 9M5 10v10a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1V10" />
    ),
  },
  {
    href: "/orders",
    label: "Pedidos",
    icon: <Icon d="M3 7.5h18M3 12h18M3 16.5h12" />,
  },
  {
    href: "/inventory",
    label: "Inventario",
    icon: (
      <Icon d="M21 8.25H3m18 0-1.5 9.75A2.25 2.25 0 0 1 17.27 20H6.73a2.25 2.25 0 0 1-2.23-2.005L3 8.25m18 0V6a2.25 2.25 0 0 0-2.25-2.25H5.25A2.25 2.25 0 0 0 3 6v2.25" />
    ),
  },
  {
    href: "/promotions",
    label: "Promociones",
    icon: (
      <Icon d="M9.568 3.001H4.25A1.25 1.25 0 0 0 3 4.25v5.318a1.25 1.25 0 0 0 .366.884l10.182 10.182a1.25 1.25 0 0 0 1.768 0l4.95-4.95a1.25 1.25 0 0 0 0-1.768L10.084 3.367a1.25 1.25 0 0 0-.884-.366h.368Z M7 7.5a.75.75 0 1 1-1.5 0 .75.75 0 0 1 1.5 0Z" />
    ),
  },
  {
    href: "/billing",
    label: "Facturación",
    icon: (
      <Icon d="M19.5 14.25v-2.625a3.375 3.375 0 0 0-3.375-3.375h-1.5A1.125 1.125 0 0 1 13.5 7.125v-1.5a3.375 3.375 0 0 0-3.375-3.375H8.25m2.25 0H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 0 0-9-9Z" />
    ),
  },
  {
    href: "/shipping",
    label: "Transporte",
    icon: (
      <Icon d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25M16.5 18.75h-2.25m0-11.177v-.958c0-.568-.422-1.048-.987-1.106a48.554 48.554 0 0 0-10.026 0 1.106 1.106 0 0 0-.987 1.106v7.635m12-6.677v6.677m0 4.5v-4.5m0 0h-12" />
    ),
  },
  {
    href: "/notifications",
    label: "Notificaciones",
    icon: (
      <Icon d="M21.75 6.75v10.5a2.25 2.25 0 0 1-2.25 2.25h-15a2.25 2.25 0 0 1-2.25-2.25V6.75m19.5 0A2.25 2.25 0 0 0 19.5 4.5h-15a2.25 2.25 0 0 0-2.25 2.25m19.5 0v.243a2.25 2.25 0 0 1-1.07 1.916l-7.5 4.615a2.25 2.25 0 0 1-2.36 0L3.32 8.91a2.25 2.25 0 0 1-1.07-1.916V6.75" />
    ),
  },
];

export function Sidebar() {
  const pathname = usePathname();
  return (
    <aside className="hidden w-60 shrink-0 flex-col border-r border-slate-800 bg-[var(--sidebar-bg)] text-[var(--sidebar-fg)] md:flex">
      <div className="flex h-16 items-center gap-3 border-b border-slate-800 px-5">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-[var(--primary)] text-white">
          <svg
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            strokeWidth={2}
            stroke="currentColor"
            className="h-4 w-4"
            aria-hidden="true"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              d="M8.25 18.75a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h6m-9 0H3.375a1.125 1.125 0 0 1-1.125-1.125V14.25m17.25 4.5a1.5 1.5 0 0 1-3 0m3 0a1.5 1.5 0 0 0-3 0m3 0h1.125c.621 0 1.129-.504 1.09-1.124a17.902 17.902 0 0 0-3.213-9.193 2.056 2.056 0 0 0-1.58-.86H14.25"
            />
          </svg>
        </div>
        <div className="leading-tight">
          <p className="text-sm font-semibold text-white">LogiFresh</p>
          <p className="text-[10px] uppercase tracking-wider text-slate-400">
            S.A.
          </p>
        </div>
      </div>
      <nav className="flex-1 space-y-0.5 px-3 py-4 text-sm">
        {items.map((item) => {
          const active =
            pathname === item.href ||
            (item.href !== "/dashboard" &&
              pathname.startsWith(`${item.href}/`));
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center gap-3 rounded-lg px-3 py-2 transition-colors ${
                active
                  ? "bg-[var(--sidebar-active-bg)] text-[var(--sidebar-fg-active)]"
                  : "text-[var(--sidebar-fg)] hover:bg-slate-800/60 hover:text-white"
              }`}
            >
              {item.icon}
              <span>{item.label}</span>
            </Link>
          );
        })}
      </nav>
      <div className="border-t border-slate-800 px-5 py-3 text-[11px] text-slate-500">
        v1.0 · Sistema distribuido
      </div>
    </aside>
  );
}

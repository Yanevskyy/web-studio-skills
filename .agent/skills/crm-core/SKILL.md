---
name: crm-core
description: "Use when building a CRM system: customers, services (tariffs/packages), projects. Data models, CRUD helpers, admin UI. Does NOT include payments or analytics."
---

# CRM Core — Customers, Services, Projects

## When to use

**WHEN BUILDING A CRM** — managing customers, services, and projects.

This skill is ONLY about:
- Data model (customers, services, projects)
- Server-side CRUD helpers
- Basic admin UI

**NOT in scope:**
- Stripe, payments, invoices → use `crm-invoicing`
- Financial reports, dashboards → use `crm-analytics`

---

## Step 1: Clarify Requirements

Before starting, ask 2-4 questions:

1. What is a "customer" in this project? (individual, company, both)
2. What is a "service"? (tariff, package, one-time work)
3. Are "projects" per customer needed now or later?
4. What DB stack is used? (Supabase, Prisma, Drizzle)

**Do NOT guess the business model** — always ask.

---

## Step 2: Database Schema

### Prisma Schema

```prisma
// prisma/schema.prisma

// ============ CUSTOMERS ============

model Customer {
  id              String    @id @default(cuid())
  name            String
  email           String?   @unique
  phone           String?
  company         String?
  notes           String?
  status          CustomerStatus @default(ACTIVE)
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  projects        Project[]
  invoices        Invoice[] // FK from crm-invoicing skill

  @@map("customers")
}

enum CustomerStatus {
  ACTIVE
  ARCHIVED
}

// ============ SERVICES (TARIFFS / PACKAGES) ============

model Service {
  id              String    @id @default(cuid())
  code            String    @unique       // short internal code, e.g. "web-basic"
  name            String                  // display name in UI
  description     String?
  amount          Decimal   @db.Decimal(10, 2)
  currency        String    @default("EUR")
  isActive        Boolean   @default(true)
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  invoices        Invoice[] // FK from crm-invoicing skill

  @@map("crm_services")
}

// ============ PROJECTS ============

model Project {
  id              String    @id @default(cuid())
  name            String
  description     String?
  status          ProjectStatus @default(PLANNED)
  startDate       DateTime?
  endDate         DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  customerId      String
  customer        Customer  @relation(fields: [customerId], references: [id])

  invoices        Invoice[] // FK from crm-invoicing skill

  @@map("crm_projects")
}

enum ProjectStatus {
  PLANNED
  ACTIVE
  ON_HOLD
  COMPLETED
  CANCELLED
}
```

### Supabase SQL (alternative)

```sql
-- customers
CREATE TABLE customers (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL,
  email       TEXT UNIQUE,
  phone       TEXT,
  company     TEXT,
  notes       TEXT,
  status      TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'archived')),
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- crm_services
CREATE TABLE crm_services (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code        TEXT NOT NULL UNIQUE,
  name        TEXT NOT NULL,
  description TEXT,
  amount      NUMERIC(10,2) NOT NULL,
  currency    TEXT NOT NULL DEFAULT 'EUR',
  is_active   BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- crm_projects
CREATE TABLE crm_projects (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES customers(id),
  name        TEXT NOT NULL,
  description TEXT,
  status      TEXT NOT NULL DEFAULT 'planned'
              CHECK (status IN ('planned','active','on_hold','completed','cancelled')),
  start_date  DATE,
  end_date    DATE,
  created_at  TIMESTAMPTZ DEFAULT now(),
  updated_at  TIMESTAMPTZ DEFAULT now()
);

-- RLS (if using Supabase)
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE crm_projects ENABLE ROW LEVEL SECURITY;
```

---

## Step 3: Server Helpers

### Customers (`lib/crm-customers.ts`)

```ts
import { prisma } from '@/lib/prisma'

export async function listCustomers(search?: string) {
  return prisma.customer.findMany({
    where: search
      ? {
          OR: [
            { name: { contains: search, mode: 'insensitive' } },
            { email: { contains: search, mode: 'insensitive' } },
            { company: { contains: search, mode: 'insensitive' } },
          ],
        }
      : undefined,
    orderBy: { createdAt: 'desc' },
  })
}

export async function getCustomer(id: string) {
  return prisma.customer.findUnique({
    where: { id },
    include: { projects: true },
  })
}

export async function createCustomer(data: {
  name: string; email?: string; phone?: string; company?: string; notes?: string
}) {
  return prisma.customer.create({ data })
}

export async function updateCustomer(
  id: string,
  data: Partial<{ name: string; email: string; phone: string; company: string; notes: string; status: 'ACTIVE' | 'ARCHIVED' }>
) {
  return prisma.customer.update({ where: { id }, data })
}

export async function archiveCustomer(id: string) {
  return prisma.customer.update({ where: { id }, data: { status: 'ARCHIVED' } })
}
```

### Services (`lib/crm-services.ts`)

```ts
import { prisma } from '@/lib/prisma'

export async function listServices(activeOnly = true) {
  return prisma.service.findMany({
    where: activeOnly ? { isActive: true } : undefined,
    orderBy: { name: 'asc' },
  })
}

export async function createService(data: {
  code: string; name: string; description?: string; amount: number; currency?: string
}) {
  return prisma.service.create({ data })
}

export async function updateService(
  id: string,
  data: Partial<{ code: string; name: string; description: string; amount: number; currency: string; isActive: boolean }>
) {
  return prisma.service.update({ where: { id }, data })
}

export async function archiveService(id: string) {
  return prisma.service.update({ where: { id }, data: { isActive: false } })
}
```

### Projects (`lib/crm-projects.ts`)

```ts
import { prisma } from '@/lib/prisma'

export async function listProjects(customerId?: string) {
  return prisma.project.findMany({
    where: customerId ? { customerId } : undefined,
    include: { customer: true },
    orderBy: { createdAt: 'desc' },
  })
}

export async function createProject(data: {
  name: string; customerId: string; description?: string; startDate?: Date; endDate?: Date
}) {
  return prisma.project.create({ data })
}

export async function updateProjectStatus(
  id: string, status: 'PLANNED' | 'ACTIVE' | 'ON_HOLD' | 'COMPLETED' | 'CANCELLED'
) {
  return prisma.project.update({ where: { id }, data: { status } })
}
```

---

## Step 4: API Routes

```ts
// app/api/crm/customers/route.ts
import { NextResponse } from 'next/server'
import { listCustomers, createCustomer } from '@/lib/crm-customers'

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const search = searchParams.get('search') ?? undefined
  const customers = await listCustomers(search)
  return NextResponse.json({ success: true, data: customers })
}

export async function POST(req: Request) {
  const body = await req.json()
  const customer = await createCustomer(body)
  return NextResponse.json({ success: true, data: customer })
}
```

---

## Step 5: Basic CRM UI

Place CRM pages under `/crm` or `/admin`. Guard with your project's auth.

```tsx
// app/crm/customers/page.tsx
import { listCustomers } from '@/lib/crm-customers'

export default async function CustomersPage() {
  const customers = await listCustomers()

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Customers</h1>
        <a href="/crm/customers/new" className="btn btn-primary">+ New Customer</a>
      </div>
      <table className="w-full border-collapse">
        <thead>
          <tr className="border-b text-left text-sm text-muted-foreground">
            <th className="p-3">Name</th>
            <th className="p-3">Email</th>
            <th className="p-3">Company</th>
            <th className="p-3">Status</th>
          </tr>
        </thead>
        <tbody>
          {customers.map((c) => (
            <tr key={c.id} className="border-b hover:bg-muted/50">
              <td className="p-3"><a href={`/crm/customers/${c.id}`} className="underline">{c.name}</a></td>
              <td className="p-3">{c.email}</td>
              <td className="p-3">{c.company}</td>
              <td className="p-3">
                <span className={c.status === 'ACTIVE' ? 'text-green-600' : 'text-gray-400'}>{c.status}</span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
```

---

## Rules

- **DB is the single source of truth.** Do not hardcode customers or services in code.
- **Soft delete** via `status` / `isActive` field. Do not physically delete records.
- **Reuse existing patterns** from the project (ORM, API style, auth, RLS).
- **Do not add Stripe or payment logic** — that belongs to `crm-invoicing`.

---

## Checklist

### Data Schema
- [ ] `customers` table created
- [ ] `crm_services` table created
- [ ] `crm_projects` table created (or planned)
- [ ] Migration applied

### Server-side
- [ ] Customer helpers (list, get, create, update, archive)
- [ ] Service helpers (list, get, create, update, archive)
- [ ] Project helpers (list, create, updateStatus)
- [ ] API routes or server actions working

### UI
- [ ] Customer list with search
- [ ] Create/edit customer
- [ ] Service list with `isActive` filter
- [ ] Create/edit service
- [ ] CRM protected by auth

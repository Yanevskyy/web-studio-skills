---
name: crm-core
description: "Используй при создании CRM-системы: клиенты, услуги (тарифы/пакеты), проекты. Модели данных, CRUD-хелперы, админ-UI. НЕ включает платежи и аналитику."
---

# CRM Core — Клиенты, Услуги, Проекты

## Когда использовать

**ПРИ СОЗДАНИИ CRM** — управление клиентами, услугами и проектами.

Этот скилл отвечает ТОЛЬКО за:
- Модель данных (customers, services, projects)
- Серверные CRUD-хелперы
- Базовый админ-UI

**НЕ входит** в этот скилл:
- Stripe, платежи, инвойсы → используй `crm-invoicing`
- Финансовые отчёты, дашборды → используй `crm-analytics`

---

## Шаг 1: Уточнение требований

Перед началом работы задай 2–4 вопроса:

1. Что такое "клиент" в этом проекте? (физлицо, компания, и то и другое)
2. Что такое "услуга"? (тариф, пакет, разовая работа)
3. Нужны ли "проекты" для клиентов сейчас или позже?
4. Какой стек БД используется? (Supabase, Prisma, Drizzle)

**Не угадывай бизнес-модель** — всегда спроси.

---

## Шаг 2: Схема базы данных

### Prisma-схема

```prisma
// prisma/schema.prisma

// ============ КЛИЕНТЫ ============

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

// ============ УСЛУГИ (ТАРИФЫ / ПАКЕТЫ) ============

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

// ============ ПРОЕКТЫ ============

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

### Supabase SQL (альтернатива)

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

## Шаг 3: Серверные хелперы

### Клиенты (`lib/crm-customers.ts`)

```ts
import { prisma } from '@/lib/prisma'

// List customers with optional search
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

// Get single customer with projects
export async function getCustomer(id: string) {
  return prisma.customer.findUnique({
    where: { id },
    include: { projects: true },
  })
}

// Create customer
export async function createCustomer(data: {
  name: string
  email?: string
  phone?: string
  company?: string
  notes?: string
}) {
  return prisma.customer.create({ data })
}

// Update customer
export async function updateCustomer(
  id: string,
  data: Partial<{
    name: string
    email: string
    phone: string
    company: string
    notes: string
    status: 'ACTIVE' | 'ARCHIVED'
  }>
) {
  return prisma.customer.update({ where: { id }, data })
}

// Archive (soft delete)
export async function archiveCustomer(id: string) {
  return prisma.customer.update({
    where: { id },
    data: { status: 'ARCHIVED' },
  })
}
```

### Услуги (`lib/crm-services.ts`)

```ts
import { prisma } from '@/lib/prisma'

export async function listServices(activeOnly = true) {
  return prisma.service.findMany({
    where: activeOnly ? { isActive: true } : undefined,
    orderBy: { name: 'asc' },
  })
}

export async function getService(id: string) {
  return prisma.service.findUnique({ where: { id } })
}

export async function createService(data: {
  code: string
  name: string
  description?: string
  amount: number
  currency?: string
}) {
  return prisma.service.create({ data })
}

export async function updateService(
  id: string,
  data: Partial<{
    code: string
    name: string
    description: string
    amount: number
    currency: string
    isActive: boolean
  }>
) {
  return prisma.service.update({ where: { id }, data })
}

export async function archiveService(id: string) {
  return prisma.service.update({
    where: { id },
    data: { isActive: false },
  })
}
```

### Проекты (`lib/crm-projects.ts`)

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
  name: string
  customerId: string
  description?: string
  startDate?: Date
  endDate?: Date
}) {
  return prisma.project.create({ data })
}

export async function updateProjectStatus(
  id: string,
  status: 'PLANNED' | 'ACTIVE' | 'ON_HOLD' | 'COMPLETED' | 'CANCELLED'
) {
  return prisma.project.update({
    where: { id },
    data: { status },
  })
}
```

---

## Шаг 4: API Routes

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

## Шаг 5: Базовый CRM UI

Размести CRM-страницы в `/crm` или `/admin`. Защити авторизацией проекта.

```tsx
// app/crm/customers/page.tsx
import { listCustomers } from '@/lib/crm-customers'

export default async function CustomersPage() {
  const customers = await listCustomers()

  return (
    <div className="p-6">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Клиенты</h1>
        <a href="/crm/customers/new" className="btn btn-primary">
          + Новый клиент
        </a>
      </div>

      <table className="w-full border-collapse">
        <thead>
          <tr className="border-b text-left text-sm text-muted-foreground">
            <th className="p-3">Имя</th>
            <th className="p-3">Email</th>
            <th className="p-3">Компания</th>
            <th className="p-3">Статус</th>
          </tr>
        </thead>
        <tbody>
          {customers.map((c) => (
            <tr key={c.id} className="border-b hover:bg-muted/50">
              <td className="p-3">
                <a href={`/crm/customers/${c.id}`} className="underline">
                  {c.name}
                </a>
              </td>
              <td className="p-3">{c.email}</td>
              <td className="p-3">{c.company}</td>
              <td className="p-3">
                <span className={c.status === 'ACTIVE' ? 'text-green-600' : 'text-gray-400'}>
                  {c.status}
                </span>
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

## Правила

- **БД — единственный источник правды.** Не хардкодь клиентов или услуги в коде.
- **Soft delete** через поле `status` / `isActive`. Не удаляй записи физически.
- **Переиспользуй существующие паттерны** проекта (ORM, API-стиль, auth, RLS).
- **Не добавляй Stripe или платёжную логику** — это скилл `crm-invoicing`.

---

## Чеклист

### Схема данных
- [ ] Таблица `customers` создана
- [ ] Таблица `crm_services` создана
- [ ] Таблица `crm_projects` создана (или запланирована)
- [ ] Миграция применена

### Серверная часть
- [ ] Хелперы для customers (list, get, create, update, archive)
- [ ] Хелперы для services (list, get, create, update, archive)
- [ ] Хелперы для projects (list, create, updateStatus)
- [ ] API routes или server actions работают

### UI
- [ ] Список клиентов с поиском
- [ ] Создание/редактирование клиента
- [ ] Список услуг с фильтром по `isActive`
- [ ] Создание/редактирование услуги
- [ ] CRM защищена авторизацией

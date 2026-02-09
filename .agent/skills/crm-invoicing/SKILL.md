---
name: crm-invoicing
description: "Используй при создании инвойсов и приёме платежей через Stripe Invoice API. Ссылки на оплату, вебхуки, статусы инвойсов. Для CRM (НЕ для e-commerce checkout — для этого используй stripe-integration)."
---

# CRM Invoicing — Инвойсы и Платежи (Stripe)

## Когда использовать

**ПРИ СОЗДАНИИ ИНВОЙСОВ И ПРИЁМЕ ПЛАТЕЖЕЙ** в CRM-системе.

Этот скилл отвечает ТОЛЬКО за:
- Модель инвойсов (таблица `crm_invoices`)
- Интеграцию со Stripe Invoice API
- Создание платёжных ссылок
- Обработку вебхуков

**НЕ входит** в этот скилл:
- Схема клиентов и услуг → используй `crm-core`
- Финансовые отчёты и дашборды → используй `crm-analytics`

**Отличие от `stripe-integration`:**
> `stripe-integration` — это Stripe Checkout для e-commerce (корзина → оплата → заказ).
> `crm-invoicing` — это Stripe Invoicing для CRM (инвойс → ссылка → оплата клиентом).

---

## Шаг 1: Проверка зависимостей

Перед началом убедись, что существуют:
- Таблица `customers` (из скилла `crm-core`)
- Таблица `crm_services` (из скилла `crm-core`)

Если их нет — сначала примени скилл `crm-core`.

### Уточняющие вопросы:

1. Разовые платежи, подписки или и то и другое?
2. Провайдер: Stripe или другой?
3. Способы оплаты: карты, кошельки, банковский перевод?
4. Нужны ли юридические поля (VAT, налоги)?

---

## Шаг 2: Установка

```bash
npm install stripe
```

```env
# .env.local
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

---

## Шаг 3: Схема инвойсов

### Prisma

```prisma
// prisma/schema.prisma

model Invoice {
  id                  String        @id @default(cuid())
  invoiceNumber       String        @unique   // e.g. "INV-2026-001"
  status              InvoiceStatus @default(DRAFT)

  // Amounts (snapshot at creation time)
  amount              Decimal       @db.Decimal(10, 2)
  currency            String        @default("EUR")

  // Dates
  dueDate             DateTime?
  sentAt              DateTime?
  paidAt              DateTime?

  // Notes
  note                String?

  // Stripe fields
  stripeCustomerId    String?
  stripeInvoiceId     String?
  stripeInvoiceUrl    String?       // hosted_invoice_url
  stripePdfUrl        String?       // invoice_pdf

  // Relations
  customerId          String
  customer            Customer      @relation(fields: [customerId], references: [id])

  serviceId           String?
  service             Service?      @relation(fields: [serviceId], references: [id])

  projectId           String?
  project             Project?      @relation(fields: [projectId], references: [id])

  createdAt           DateTime      @default(now())
  updatedAt           DateTime      @updatedAt

  @@map("crm_invoices")
}

enum InvoiceStatus {
  DRAFT
  SENT
  PAID
  FAILED
  VOID
  UNCOLLECTIBLE
}
```

### Supabase SQL (альтернатива)

```sql
CREATE TABLE crm_invoices (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  invoice_number      TEXT NOT NULL UNIQUE,
  status              TEXT NOT NULL DEFAULT 'draft'
                      CHECK (status IN ('draft','sent','paid','failed','void','uncollectible')),
  amount              NUMERIC(10,2) NOT NULL,
  currency            TEXT NOT NULL DEFAULT 'EUR',
  due_date            DATE,
  sent_at             TIMESTAMPTZ,
  paid_at             TIMESTAMPTZ,
  note                TEXT,
  stripe_customer_id  TEXT,
  stripe_invoice_id   TEXT,
  stripe_invoice_url  TEXT,
  stripe_pdf_url      TEXT,
  customer_id         UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
  service_id          UUID REFERENCES crm_services(id) ON DELETE SET NULL,
  project_id          UUID REFERENCES crm_projects(id) ON DELETE SET NULL,
  created_at          TIMESTAMPTZ DEFAULT now(),
  updated_at          TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE crm_invoices ENABLE ROW LEVEL SECURITY;
```

**Важно:** Инвойсы хранят snapshot суммы. Если услуга позже изменится — инвойс остаётся с исходной суммой.

---

## Шаг 4: Stripe-клиент

```ts
// lib/stripe.ts
import Stripe from 'stripe'

if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error('Missing STRIPE_SECRET_KEY')
}

export const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: '2024-12-18.acacia',
})
```

**Одна точка инициализации.** Не создавай Stripe-клиенты в других файлах.

---

## Шаг 5: Создание инвойса

```ts
// lib/crm-invoices.ts
import { prisma } from '@/lib/prisma'
import { stripe } from '@/lib/stripe'

interface CreateInvoiceInput {
  customerId: string
  serviceId: string
  projectId?: string
  note?: string
  dueDate?: Date
}

export async function createInvoice(input: CreateInvoiceInput) {
  // 1. Load service and verify it's active
  const service = await prisma.service.findUnique({
    where: { id: input.serviceId },
  })
  if (!service || !service.isActive) {
    throw new Error('Service not found or inactive')
  }

  // 2. Load customer
  const customer = await prisma.customer.findUnique({
    where: { id: input.customerId },
  })
  if (!customer) throw new Error('Customer not found')

  // 3. Create or reuse Stripe Customer
  let stripeCustomerId: string

  const existing = await prisma.invoice.findFirst({
    where: { customerId: customer.id, stripeCustomerId: { not: null } },
    select: { stripeCustomerId: true },
  })

  if (existing?.stripeCustomerId) {
    stripeCustomerId = existing.stripeCustomerId
  } else {
    const sc = await stripe.customers.create({
      name: customer.name,
      email: customer.email ?? undefined,
      phone: customer.phone ?? undefined,
    })
    stripeCustomerId = sc.id
  }

  // 4. Create Stripe invoice item
  await stripe.invoiceItems.create({
    customer: stripeCustomerId,
    amount: Math.round(Number(service.amount) * 100), // cents
    currency: service.currency.toLowerCase(),
    description: `${service.name} — ${service.code}`,
  })

  // 5. Create Stripe invoice
  const stripeInvoice = await stripe.invoices.create({
    customer: stripeCustomerId,
    collection_method: 'send_invoice',
    days_until_due: input.dueDate
      ? Math.max(1, Math.ceil((input.dueDate.getTime() - Date.now()) / 86400000))
      : 14,
    metadata: {
      customerId: customer.id,
      serviceId: service.id,
      projectId: input.projectId ?? '',
    },
  })

  // 6. Finalize to get payment URL
  const finalized = await stripe.invoices.finalizeInvoice(stripeInvoice.id)

  // 7. Generate invoice number
  const count = await prisma.invoice.count()
  const invoiceNumber = `INV-${new Date().getFullYear()}-${String(count + 1).padStart(3, '0')}`

  // 8. Save to DB
  const invoice = await prisma.invoice.create({
    data: {
      invoiceNumber,
      status: 'SENT',
      amount: service.amount,
      currency: service.currency,
      dueDate: input.dueDate,
      sentAt: new Date(),
      note: input.note,
      stripeCustomerId,
      stripeInvoiceId: finalized.id,
      stripeInvoiceUrl: finalized.hosted_invoice_url,
      stripePdfUrl: finalized.invoice_pdf,
      customerId: customer.id,
      serviceId: service.id,
      projectId: input.projectId,
    },
  })

  return {
    success: true,
    data: {
      invoiceId: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      paymentUrl: finalized.hosted_invoice_url,
      pdfUrl: finalized.invoice_pdf,
      amount: Number(service.amount),
      currency: service.currency,
    },
  }
}
```

---

## Шаг 6: API Route

```ts
// app/api/invoices/create/route.ts
import { NextResponse } from 'next/server'
import { createInvoice } from '@/lib/crm-invoices'

export async function POST(req: Request) {
  try {
    const body = await req.json()
    const result = await createInvoice(body)
    return NextResponse.json(result)
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message },
      { status: 400 }
    )
  }
}
```

---

## Шаг 7: Webhook

```ts
// app/api/invoices/webhook/route.ts
import { NextResponse } from 'next/server'
import { stripe } from '@/lib/stripe'
import { prisma } from '@/lib/prisma'
import Stripe from 'stripe'

export async function POST(req: Request) {
  const body = await req.text()
  const signature = req.headers.get('stripe-signature')!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 })
  }

  const stripeInvoice = event.data.object as Stripe.Invoice

  switch (event.type) {
    case 'invoice.paid':
      await prisma.invoice.updateMany({
        where: { stripeInvoiceId: stripeInvoice.id },
        data: { status: 'PAID', paidAt: new Date() },
      })
      break

    case 'invoice.payment_failed':
      await prisma.invoice.updateMany({
        where: { stripeInvoiceId: stripeInvoice.id },
        data: { status: 'FAILED' },
      })
      break

    case 'invoice.voided':
      await prisma.invoice.updateMany({
        where: { stripeInvoiceId: stripeInvoice.id },
        data: { status: 'VOID' },
      })
      break
  }

  return NextResponse.json({ received: true })
}
```

### Локальное тестирование вебхуков:

```bash
stripe listen --forward-to localhost:3000/api/invoices/webhook
```

---

## Шаг 8: Интеграция в CRM UI

Добавь кнопку на страницу клиента или проекта (НЕ переделывай весь CRM):

```tsx
// components/crm/CreateInvoiceButton.tsx
'use client'

import { useState } from 'react'

interface Props {
  customerId: string
  services: { id: string; name: string; amount: number; currency: string }[]
  projectId?: string
}

export function CreateInvoiceButton({ customerId, services, projectId }: Props) {
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<{ paymentUrl: string } | null>(null)

  async function handleCreate(serviceId: string) {
    setLoading(true)
    const res = await fetch('/api/invoices/create', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ customerId, serviceId, projectId }),
    })
    const data = await res.json()
    if (data.success) {
      setResult(data.data)
    }
    setLoading(false)
  }

  if (result) {
    return (
      <div className="rounded-lg border p-4 bg-green-50">
        <p className="font-medium text-green-800">Инвойс создан!</p>
        <a
          href={result.paymentUrl}
          target="_blank"
          rel="noopener noreferrer"
          className="text-blue-600 underline"
        >
          Ссылка на оплату →
        </a>
      </div>
    )
  }

  return (
    <div className="space-y-2">
      {services.map((s) => (
        <button
          key={s.id}
          onClick={() => handleCreate(s.id)}
          disabled={loading}
          className="btn btn-outline w-full text-left"
        >
          Выставить: {s.name} — {s.amount} {s.currency}
        </button>
      ))}
    </div>
  )
}
```

---

## Правила

- **Единая точка Stripe-клиента** — только `lib/stripe.ts`.
- **Никогда не хардкодь** реальные Stripe-ключи или ID.
- **Не полагайся на клиентский стейт** для определения оплачен ли инвойс — только вебхуки.
- **Инвойсы не удаляются** — используй `void` для отмены.
- **Snapshot суммы** — инвойс хранит `amount` на момент создания.

---

## Чеклист

### Настройка
- [ ] `stripe` пакет установлен
- [ ] `STRIPE_SECRET_KEY` в env
- [ ] `STRIPE_WEBHOOK_SECRET` в env
- [ ] `lib/stripe.ts` создан (единственный инстанс)

### Схема данных
- [ ] Таблица `crm_invoices` создана
- [ ] FK на customers, services, projects
- [ ] Миграция применена

### Основной flow
- [ ] Создание инвойса (service + customer → Stripe Invoice → DB)
- [ ] Финализация и получение `hosted_invoice_url`
- [ ] API route `POST /api/invoices/create` работает
- [ ] Ответ содержит paymentUrl и invoiceNumber

### Вебхуки
- [ ] Route `POST /api/invoices/webhook` создан
- [ ] Подпись Stripe верифицируется
- [ ] `invoice.paid` → статус PAID + paidAt
- [ ] `invoice.payment_failed` → статус FAILED
- [ ] `invoice.voided` → статус VOID

### UI
- [ ] Кнопка "Выставить инвойс" на странице клиента
- [ ] Показ ссылки на оплату после создания
- [ ] Список инвойсов клиента с фильтром по статусу

### Тестирование
- [ ] `stripe listen` для локальных вебхуков
- [ ] Тестовая карта `4242 4242 4242 4242`
- [ ] Production ключи перед запуском

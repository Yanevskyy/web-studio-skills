---
name: crm-invoicing
description: "Use when creating invoices and accepting payments via Stripe Invoice API. Payment links, webhooks, invoice statuses. For CRM (NOT for e-commerce checkout — use stripe-integration for that)."
---

# CRM Invoicing — Invoices & Payments (Stripe)

## When to use

**WHEN CREATING INVOICES AND ACCEPTING PAYMENTS** in a CRM system.

This skill is ONLY about:
- Invoice model (`crm_invoices` table)
- Stripe Invoice API integration
- Creating payment links
- Handling webhooks

**NOT in scope:**
- Customer and service schemas → use `crm-core`
- Financial reports and dashboards → use `crm-analytics`

**Difference from `stripe-integration`:**
> `stripe-integration` = Stripe Checkout for e-commerce (cart → pay → order).
> `crm-invoicing` = Stripe Invoicing for CRM (invoice → link → client pays).

---

## Step 1: Check Dependencies

Before starting, verify these exist:
- `customers` table (from `crm-core` skill)
- `crm_services` table (from `crm-core` skill)

If missing — apply `crm-core` first.

### Clarifying questions:

1. One-time payments, subscriptions, or both?
2. Provider: Stripe or other?
3. Payment methods: cards, wallets, bank transfer?
4. Legal fields needed (VAT, tax)?

---

## Step 2: Installation

```bash
npm install stripe
```

```env
# .env.local
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

---

## Step 3: Invoice Schema

### Prisma

```prisma
model Invoice {
  id                  String        @id @default(cuid())
  invoiceNumber       String        @unique   // e.g. "INV-2026-001"
  status              InvoiceStatus @default(DRAFT)

  amount              Decimal       @db.Decimal(10, 2)
  currency            String        @default("EUR")

  dueDate             DateTime?
  sentAt              DateTime?
  paidAt              DateTime?
  note                String?

  stripeCustomerId    String?
  stripeInvoiceId     String?
  stripeInvoiceUrl    String?       // hosted_invoice_url
  stripePdfUrl        String?       // invoice_pdf

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

**Important:** Invoices store an amount snapshot. If a service changes later, the invoice keeps its original amount.

---

## Step 4: Stripe Client

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

**Single initialization point.** Do not create Stripe clients elsewhere.

---

## Step 5: Create Invoice

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
  const service = await prisma.service.findUnique({ where: { id: input.serviceId } })
  if (!service || !service.isActive) throw new Error('Service not found or inactive')

  // 2. Load customer
  const customer = await prisma.customer.findUnique({ where: { id: input.customerId } })
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
    amount: Math.round(Number(service.amount) * 100),
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
    metadata: { customerId: customer.id, serviceId: service.id, projectId: input.projectId ?? '' },
  })

  // 6. Finalize to get payment URL
  const finalized = await stripe.invoices.finalizeInvoice(stripeInvoice.id)

  // 7. Generate invoice number
  const count = await prisma.invoice.count()
  const invoiceNumber = `INV-${new Date().getFullYear()}-${String(count + 1).padStart(3, '0')}`

  // 8. Save to DB
  const invoice = await prisma.invoice.create({
    data: {
      invoiceNumber, status: 'SENT',
      amount: service.amount, currency: service.currency,
      dueDate: input.dueDate, sentAt: new Date(), note: input.note,
      stripeCustomerId, stripeInvoiceId: finalized.id,
      stripeInvoiceUrl: finalized.hosted_invoice_url,
      stripePdfUrl: finalized.invoice_pdf,
      customerId: customer.id, serviceId: service.id, projectId: input.projectId,
    },
  })

  return {
    success: true,
    data: {
      invoiceId: invoice.id, invoiceNumber: invoice.invoiceNumber,
      paymentUrl: finalized.hosted_invoice_url, pdfUrl: finalized.invoice_pdf,
      amount: Number(service.amount), currency: service.currency,
    },
  }
}
```

---

## Step 6: API Route

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
    return NextResponse.json({ success: false, error: error.message }, { status: 400 })
  }
}
```

---

## Step 7: Webhook

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
    event = stripe.webhooks.constructEvent(body, signature, process.env.STRIPE_WEBHOOK_SECRET!)
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

### Local webhook testing:
```bash
stripe listen --forward-to localhost:3000/api/invoices/webhook
```

---

## Step 8: CRM UI Integration

Add a button on the customer or project page (do NOT redesign the whole CRM):

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
    if (data.success) setResult(data.data)
    setLoading(false)
  }

  if (result) {
    return (
      <div className="rounded-lg border p-4 bg-green-50">
        <p className="font-medium text-green-800">Invoice created!</p>
        <a href={result.paymentUrl} target="_blank" rel="noopener noreferrer"
          className="text-blue-600 underline">Payment link &rarr;</a>
      </div>
    )
  }

  return (
    <div className="space-y-2">
      {services.map((s) => (
        <button key={s.id} onClick={() => handleCreate(s.id)} disabled={loading}
          className="btn btn-outline w-full text-left">
          Invoice: {s.name} — {s.amount} {s.currency}
        </button>
      ))}
    </div>
  )
}
```

---

## Rules

- **Single Stripe client** — only `lib/stripe.ts`.
- **Never hardcode** real Stripe keys or IDs.
- **Don't rely on client state** for payment status — use webhooks only.
- **Invoices are never deleted** — use `void` to cancel.
- **Amount snapshot** — invoice stores `amount` at creation time.

---

## Checklist

### Setup
- [ ] `stripe` package installed
- [ ] `STRIPE_SECRET_KEY` in env
- [ ] `STRIPE_WEBHOOK_SECRET` in env
- [ ] `lib/stripe.ts` created (single instance)

### Data Schema
- [ ] `crm_invoices` table created
- [ ] FK to customers, services, projects
- [ ] Migration applied

### Main Flow
- [ ] Invoice creation (service + customer → Stripe Invoice → DB)
- [ ] Finalization and `hosted_invoice_url` obtained
- [ ] API route `POST /api/invoices/create` works
- [ ] Response includes paymentUrl and invoiceNumber

### Webhooks
- [ ] Route `POST /api/invoices/webhook` created
- [ ] Stripe signature verified
- [ ] `invoice.paid` → status PAID + paidAt
- [ ] `invoice.payment_failed` → status FAILED
- [ ] `invoice.voided` → status VOID

### UI
- [ ] "Create Invoice" button on customer page
- [ ] Payment link shown after creation
- [ ] Customer invoice list with status filter

### Testing
- [ ] `stripe listen` for local webhooks
- [ ] Test card `4242 4242 4242 4242`
- [ ] Production keys before launch

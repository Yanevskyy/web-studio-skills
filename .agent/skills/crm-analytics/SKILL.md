---
name: crm-analytics
description: "Use for CRM financial reports and dashboards. Revenue, paid/overdue invoices, customer and service metrics. Read-only — does NOT create CRM schema or handle payments."
---

# CRM Analytics — Financial Reports & Dashboards

## When to use

**WHEN BUILDING FINANCIAL REPORTS** and dashboards for a CRM system.

This skill is ONLY about:
- Reading CRM and invoice data
- Aggregations and metrics (revenue, DSO, LTV)
- SQL queries and views
- Dashboard UI

**NOT in scope:**
- CRM schema creation (customers, services) → use `crm-core`
- Payments and Stripe → use `crm-invoicing`

---

## Step 1: Verify Data Sources

Before building reports, identify available tables:

| Table | Source Skill | Required? |
|-------|-------------|-----------|
| `customers` | crm-core | Yes |
| `crm_services` | crm-core | Yes |
| `crm_invoices` | crm-invoicing | Yes |
| `crm_projects` | crm-core | Optional |

If tables don't exist — apply `crm-core` and `crm-invoicing` first.

### Clarifying questions:

1. Most important metric? (revenue, profit, overdue)
2. Time granularity? (day / week / month)
3. Is VAT/tax relevant?
4. Analytics stack? (SQL, Supabase views, Prisma, external BI)

---

## Step 2: Key Metrics

### Revenue

| Metric | Formula | Source |
|--------|---------|--------|
| Total revenue | SUM(amount) WHERE status = 'paid' | crm_invoices |
| Revenue per period | Filter by `paid_at` | crm_invoices |
| Revenue by service | GROUP BY service_id | crm_invoices + crm_services |
| Revenue by customer | GROUP BY customer_id | crm_invoices + customers |

### Invoices

| Metric | Formula | Source |
|--------|---------|--------|
| Issued | COUNT(*) | crm_invoices |
| Paid | COUNT(*) WHERE status = 'paid' | crm_invoices |
| Overdue | WHERE status = 'sent' AND due_date < now() | crm_invoices |
| DSO (Days Sales Outstanding) | AVG(paid_at - sent_at) | crm_invoices |

### Customers

| Metric | Formula | Source |
|--------|---------|--------|
| Active customers | COUNT DISTINCT customer_id paid in last N days | crm_invoices |
| LTV (simple) | SUM(amount) paid / COUNT DISTINCT customers | crm_invoices |
| New vs returning | By first invoice date per customer | crm_invoices |

Detailed SQL queries — in [reference.md](reference.md).

---

## Step 3: Server Helpers

```ts
// lib/crm-analytics.ts
import { prisma } from '@/lib/prisma'

export async function getRevenueSummary(from: Date, to: Date) {
  const invoices = await prisma.invoice.findMany({
    where: { status: 'PAID', paidAt: { gte: from, lte: to } },
    select: { amount: true, currency: true, paidAt: true },
  })
  const total = invoices.reduce((sum, inv) => sum + Number(inv.amount), 0)
  return { total, count: invoices.length, currency: 'EUR' }
}

export async function getRevenueByService(from: Date, to: Date) {
  const result = await prisma.invoice.groupBy({
    by: ['serviceId'],
    where: { status: 'PAID', paidAt: { gte: from, lte: to } },
    _sum: { amount: true },
    _count: true,
  })
  const serviceIds = result.map((r) => r.serviceId).filter(Boolean) as string[]
  const services = await prisma.service.findMany({
    where: { id: { in: serviceIds } },
    select: { id: true, name: true, code: true },
  })
  const serviceMap = Object.fromEntries(services.map((s) => [s.id, s]))
  return result.map((r) => ({
    service: serviceMap[r.serviceId!] ?? { name: 'Unknown' },
    revenue: Number(r._sum.amount),
    count: r._count,
  }))
}

export async function getInvoiceStatusBreakdown() {
  const result = await prisma.invoice.groupBy({
    by: ['status'],
    _count: true,
    _sum: { amount: true },
  })
  return result.map((r) => ({
    status: r.status, count: r._count, totalAmount: Number(r._sum.amount),
  }))
}

export async function getTopCustomers(limit = 10) {
  const result = await prisma.invoice.groupBy({
    by: ['customerId'],
    where: { status: 'PAID' },
    _sum: { amount: true },
    _count: true,
    orderBy: { _sum: { amount: 'desc' } },
    take: limit,
  })
  const customerIds = result.map((r) => r.customerId)
  const customers = await prisma.customer.findMany({
    where: { id: { in: customerIds } },
    select: { id: true, name: true, company: true },
  })
  const customerMap = Object.fromEntries(customers.map((c) => [c.id, c]))
  return result.map((r) => ({
    customer: customerMap[r.customerId],
    revenue: Number(r._sum.amount),
    invoiceCount: r._count,
  }))
}

export async function getOverdueInvoices() {
  return prisma.invoice.findMany({
    where: { status: 'SENT', dueDate: { lt: new Date() } },
    include: { customer: true, service: true },
    orderBy: { dueDate: 'asc' },
  })
}
```

---

## Step 4: API Route

```ts
// app/api/crm/analytics/route.ts
import { NextResponse } from 'next/server'
import { getRevenueSummary, getRevenueByService, getInvoiceStatusBreakdown, getTopCustomers } from '@/lib/crm-analytics'

export async function GET(req: Request) {
  const { searchParams } = new URL(req.url)
  const from = new Date(searchParams.get('from') ?? new Date(Date.now() - 30 * 86400000))
  const to = new Date(searchParams.get('to') ?? new Date())

  const [revenue, byService, statusBreakdown, topCustomers] = await Promise.all([
    getRevenueSummary(from, to),
    getRevenueByService(from, to),
    getInvoiceStatusBreakdown(),
    getTopCustomers(10),
  ])

  return NextResponse.json({ success: true, data: { revenue, byService, statusBreakdown, topCustomers } })
}
```

---

## Step 5: Dashboard UI

```tsx
// app/crm/analytics/page.tsx
import { getRevenueSummary, getInvoiceStatusBreakdown, getTopCustomers, getOverdueInvoices } from '@/lib/crm-analytics'

export default async function AnalyticsDashboard() {
  const now = new Date()
  const monthAgo = new Date(Date.now() - 30 * 86400000)

  const [revenue, statuses, topCustomers, overdue] = await Promise.all([
    getRevenueSummary(monthAgo, now),
    getInvoiceStatusBreakdown(),
    getTopCustomers(5),
    getOverdueInvoices(),
  ])

  return (
    <div className="p-6 space-y-8">
      <h1 className="text-2xl font-bold">Financial Dashboard</h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="rounded-lg border p-6">
          <p className="text-sm text-muted-foreground">Revenue (30 days)</p>
          <p className="text-3xl font-bold">&euro;{revenue.total.toFixed(2)}</p>
          <p className="text-sm text-muted-foreground">{revenue.count} invoices</p>
        </div>
        {statuses.map((s) => (
          <div key={s.status} className="rounded-lg border p-6">
            <p className="text-sm text-muted-foreground">{s.status}</p>
            <p className="text-2xl font-bold">{s.count}</p>
            <p className="text-sm">&euro;{s.totalAmount.toFixed(2)}</p>
          </div>
        ))}
      </div>

      {overdue.length > 0 && (
        <div className="rounded-lg border-l-4 border-red-500 bg-red-50 p-4">
          <p className="font-medium text-red-800">Overdue invoices: {overdue.length}</p>
        </div>
      )}

      <div>
        <h2 className="text-lg font-semibold mb-3">Top Customers by Revenue</h2>
        <table className="w-full border-collapse">
          <thead>
            <tr className="border-b text-left text-sm text-muted-foreground">
              <th className="p-3">Customer</th>
              <th className="p-3">Revenue</th>
              <th className="p-3">Invoices</th>
            </tr>
          </thead>
          <tbody>
            {topCustomers.map((c) => (
              <tr key={c.customer.id} className="border-b">
                <td className="p-3">{c.customer.name}</td>
                <td className="p-3">&euro;{c.revenue.toFixed(2)}</td>
                <td className="p-3">{c.invoiceCount}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
```

---

## Rules

- **Read-only.** Analytics does not modify CRM records or create payments.
- **All aggregations server-side.** Don't pull all records to the client.
- **Respect RLS** when using Supabase.
- **Define metrics clearly** before writing queries.

---

## Checklist

### Data
- [ ] Tables `customers`, `crm_services`, `crm_invoices` exist
- [ ] Test data available for reports

### Server-side
- [ ] `lib/crm-analytics.ts` — aggregation helpers
- [ ] Revenue summary (total, per period)
- [ ] Revenue by service
- [ ] Invoice status breakdown
- [ ] Top customers
- [ ] Overdue invoices

### Dashboard UI
- [ ] KPI cards (revenue, invoice count)
- [ ] Overdue invoice warning
- [ ] Top customers table
- [ ] Date filter (optional)
- [ ] Dashboard protected by auth

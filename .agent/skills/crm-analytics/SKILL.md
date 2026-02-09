---
name: crm-analytics
description: "Используй для финансовых отчётов и дашбордов CRM. Выручка, оплаченные/просроченные инвойсы, метрики по клиентам и услугам. Только чтение данных — НЕ создаёт CRM-схему и НЕ реализует платежи."
---

# CRM Analytics — Финансовые Отчёты и Дашборды

## Когда использовать

**ПРИ СОЗДАНИИ ФИНАНСОВЫХ ОТЧЁТОВ** и дашбордов для CRM-системы.

Этот скилл отвечает ТОЛЬКО за:
- Чтение данных из CRM и инвойсов
- Агрегации и метрики (выручка, DSO, LTV)
- SQL-запросы и view
- UI дашборда

**НЕ входит** в этот скилл:
- Создание CRM-схемы (customers, services) → используй `crm-core`
- Платежи и Stripe → используй `crm-invoicing`

---

## Шаг 1: Проверка источников данных

Перед построением отчётов определи, какие таблицы доступны:

| Таблица | Скилл-источник | Обязательна? |
|---------|---------------|-------------|
| `customers` | crm-core | Да |
| `crm_services` | crm-core | Да |
| `crm_invoices` | crm-invoicing | Да |
| `crm_projects` | crm-core | Опционально |

Если таблиц нет — сначала примени `crm-core` и `crm-invoicing`.

### Уточняющие вопросы:

1. Какая метрика самая важная? (выручка, прибыль, просрочки)
2. Гранулярность по времени? (день / неделя / месяц)
3. Нужно ли учитывать VAT/налоги?
4. Стек для аналитики? (SQL, Supabase views, Prisma, внешний BI)

---

## Шаг 2: Ключевые метрики

### Выручка

| Метрика | Формула | Источник |
|---------|---------|----------|
| Общая выручка | SUM(amount) WHERE status = 'paid' | crm_invoices |
| Выручка за период | Фильтр по `paid_at` | crm_invoices |
| Выручка по услуге | GROUP BY service_id | crm_invoices + crm_services |
| Выручка по клиенту | GROUP BY customer_id | crm_invoices + customers |

### Инвойсы

| Метрика | Формула | Источник |
|---------|---------|----------|
| Выставлено | COUNT(*) | crm_invoices |
| Оплачено | COUNT(*) WHERE status = 'paid' | crm_invoices |
| Просрочено | WHERE status = 'sent' AND due_date < now() | crm_invoices |
| DSO (Days Sales Outstanding) | AVG(paid_at - sent_at) | crm_invoices |

### Клиенты

| Метрика | Формула | Источник |
|---------|---------|----------|
| Активных клиентов | COUNT DISTINCT customer_id WHERE paid в последние N дней | crm_invoices |
| LTV (простой) | SUM(amount) WHERE status = 'paid' / COUNT DISTINCT customers | crm_invoices |
| Новые vs возвратные | По дате первого инвойса клиента | crm_invoices |

Подробные SQL-запросы — в [reference.md](reference.md).

---

## Шаг 3: Серверные хелперы

```ts
// lib/crm-analytics.ts
import { prisma } from '@/lib/prisma'

// Revenue summary for a date range
export async function getRevenueSummary(from: Date, to: Date) {
  const invoices = await prisma.invoice.findMany({
    where: {
      status: 'PAID',
      paidAt: { gte: from, lte: to },
    },
    select: { amount: true, currency: true, paidAt: true },
  })

  const total = invoices.reduce((sum, inv) => sum + Number(inv.amount), 0)

  return { total, count: invoices.length, currency: 'EUR' }
}

// Revenue per service
export async function getRevenueByService(from: Date, to: Date) {
  const result = await prisma.invoice.groupBy({
    by: ['serviceId'],
    where: {
      status: 'PAID',
      paidAt: { gte: from, lte: to },
    },
    _sum: { amount: true },
    _count: true,
  })

  // Enrich with service names
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

// Invoice status breakdown
export async function getInvoiceStatusBreakdown() {
  const result = await prisma.invoice.groupBy({
    by: ['status'],
    _count: true,
    _sum: { amount: true },
  })

  return result.map((r) => ({
    status: r.status,
    count: r._count,
    totalAmount: Number(r._sum.amount),
  }))
}

// Top customers by revenue
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

// Overdue invoices
export async function getOverdueInvoices() {
  return prisma.invoice.findMany({
    where: {
      status: 'SENT',
      dueDate: { lt: new Date() },
    },
    include: { customer: true, service: true },
    orderBy: { dueDate: 'asc' },
  })
}
```

---

## Шаг 4: API Routes

```ts
// app/api/crm/analytics/route.ts
import { NextResponse } from 'next/server'
import {
  getRevenueSummary,
  getRevenueByService,
  getInvoiceStatusBreakdown,
  getTopCustomers,
} from '@/lib/crm-analytics'

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

  return NextResponse.json({
    success: true,
    data: { revenue, byService, statusBreakdown, topCustomers },
  })
}
```

---

## Шаг 5: Дашборд UI

```tsx
// app/crm/analytics/page.tsx
import {
  getRevenueSummary,
  getInvoiceStatusBreakdown,
  getTopCustomers,
  getOverdueInvoices,
} from '@/lib/crm-analytics'

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
      <h1 className="text-2xl font-bold">Финансовый дашборд</h1>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div className="rounded-lg border p-6">
          <p className="text-sm text-muted-foreground">Выручка (30 дней)</p>
          <p className="text-3xl font-bold">€{revenue.total.toFixed(2)}</p>
          <p className="text-sm text-muted-foreground">{revenue.count} инвойсов</p>
        </div>
        {statuses.map((s) => (
          <div key={s.status} className="rounded-lg border p-6">
            <p className="text-sm text-muted-foreground">{s.status}</p>
            <p className="text-2xl font-bold">{s.count}</p>
            <p className="text-sm">€{s.totalAmount.toFixed(2)}</p>
          </div>
        ))}
      </div>

      {/* Overdue Warning */}
      {overdue.length > 0 && (
        <div className="rounded-lg border-l-4 border-red-500 bg-red-50 p-4">
          <p className="font-medium text-red-800">
            Просроченных инвойсов: {overdue.length}
          </p>
        </div>
      )}

      {/* Top Customers */}
      <div>
        <h2 className="text-lg font-semibold mb-3">Топ клиентов по выручке</h2>
        <table className="w-full border-collapse">
          <thead>
            <tr className="border-b text-left text-sm text-muted-foreground">
              <th className="p-3">Клиент</th>
              <th className="p-3">Выручка</th>
              <th className="p-3">Инвойсов</th>
            </tr>
          </thead>
          <tbody>
            {topCustomers.map((c) => (
              <tr key={c.customer.id} className="border-b">
                <td className="p-3">{c.customer.name}</td>
                <td className="p-3">€{c.revenue.toFixed(2)}</td>
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

## Правила

- **Только чтение данных.** Аналитика не модифицирует CRM-записи и не создаёт платежи.
- **Все агрегации — на сервере.** Не тяни все записи на клиент.
- **Учитывай RLS** при работе с Supabase.
- **Определяй метрики чётко** перед написанием запросов.

---

## Чеклист

### Данные
- [ ] Таблицы `customers`, `crm_services`, `crm_invoices` существуют
- [ ] Есть данные для отчётов (хотя бы тестовые)

### Серверная часть
- [ ] `lib/crm-analytics.ts` — хелперы для агрегаций
- [ ] Revenue summary (общая, за период)
- [ ] Revenue by service
- [ ] Invoice status breakdown
- [ ] Top customers
- [ ] Overdue invoices

### UI Дашборд
- [ ] KPI-карточки (выручка, кол-во инвойсов)
- [ ] Предупреждение о просроченных инвойсах
- [ ] Таблица топ-клиентов
- [ ] Фильтр по дате (опционально)
- [ ] Дашборд защищён авторизацией

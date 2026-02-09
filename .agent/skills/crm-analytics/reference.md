# CRM Analytics — SQL Reference

Готовые SQL-запросы для PostgreSQL / Supabase. Адаптируй имена таблиц под свой проект.

---

## Revenue: Total per period

```sql
-- Monthly revenue (last 12 months)
SELECT
  date_trunc('month', paid_at) AS month,
  SUM(amount) AS revenue,
  COUNT(*) AS invoice_count
FROM crm_invoices
WHERE status = 'paid'
  AND paid_at >= now() - interval '12 months'
GROUP BY month
ORDER BY month DESC;
```

---

## Revenue: By service

```sql
SELECT
  s.code,
  s.name AS service_name,
  COUNT(i.id) AS invoice_count,
  SUM(i.amount) AS total_revenue
FROM crm_invoices i
JOIN crm_services s ON s.id = i.service_id
WHERE i.status = 'paid'
  AND i.paid_at >= :from_date
  AND i.paid_at <= :to_date
GROUP BY s.id, s.code, s.name
ORDER BY total_revenue DESC;
```

---

## Revenue: By customer

```sql
SELECT
  c.name AS customer_name,
  c.company,
  COUNT(i.id) AS invoice_count,
  SUM(i.amount) AS total_revenue
FROM crm_invoices i
JOIN customers c ON c.id = i.customer_id
WHERE i.status = 'paid'
  AND i.paid_at >= :from_date
  AND i.paid_at <= :to_date
GROUP BY c.id, c.name, c.company
ORDER BY total_revenue DESC
LIMIT 20;
```

---

## Invoice status breakdown

```sql
SELECT
  status,
  COUNT(*) AS count,
  SUM(amount) AS total_amount
FROM crm_invoices
GROUP BY status
ORDER BY count DESC;
```

---

## Overdue invoices

```sql
SELECT
  i.invoice_number,
  i.amount,
  i.currency,
  i.due_date,
  (now()::date - i.due_date::date) AS days_overdue,
  c.name AS customer_name,
  c.email AS customer_email
FROM crm_invoices i
JOIN customers c ON c.id = i.customer_id
WHERE i.status = 'sent'
  AND i.due_date < now()
ORDER BY i.due_date ASC;
```

---

## DSO (Days Sales Outstanding)

```sql
-- Average time from sent to paid
SELECT
  AVG(EXTRACT(EPOCH FROM (paid_at - sent_at)) / 86400)::int AS avg_dso_days,
  MIN(EXTRACT(EPOCH FROM (paid_at - sent_at)) / 86400)::int AS min_dso_days,
  MAX(EXTRACT(EPOCH FROM (paid_at - sent_at)) / 86400)::int AS max_dso_days
FROM crm_invoices
WHERE status = 'paid'
  AND sent_at IS NOT NULL
  AND paid_at IS NOT NULL;
```

---

## Simple LTV (Lifetime Value)

```sql
SELECT
  c.id,
  c.name,
  c.company,
  SUM(i.amount) AS lifetime_revenue,
  COUNT(i.id) AS total_invoices,
  MIN(i.paid_at) AS first_payment,
  MAX(i.paid_at) AS last_payment
FROM customers c
JOIN crm_invoices i ON i.customer_id = c.id AND i.status = 'paid'
GROUP BY c.id, c.name, c.company
ORDER BY lifetime_revenue DESC;
```

---

## New vs returning customers per month

```sql
WITH first_payment AS (
  SELECT
    customer_id,
    MIN(date_trunc('month', paid_at)) AS first_month
  FROM crm_invoices
  WHERE status = 'paid'
  GROUP BY customer_id
),
monthly_customers AS (
  SELECT DISTINCT
    date_trunc('month', i.paid_at) AS month,
    i.customer_id,
    fp.first_month
  FROM crm_invoices i
  JOIN first_payment fp ON fp.customer_id = i.customer_id
  WHERE i.status = 'paid'
)
SELECT
  month,
  COUNT(*) FILTER (WHERE month = first_month) AS new_customers,
  COUNT(*) FILTER (WHERE month > first_month) AS returning_customers
FROM monthly_customers
GROUP BY month
ORDER BY month DESC;
```

---

## Active customers (with payment in last N days)

```sql
SELECT COUNT(DISTINCT customer_id) AS active_customers
FROM crm_invoices
WHERE status = 'paid'
  AND paid_at >= now() - interval '90 days';
```

---

## Revenue by project

```sql
SELECT
  p.name AS project_name,
  c.name AS customer_name,
  COUNT(i.id) AS invoice_count,
  SUM(i.amount) AS total_revenue
FROM crm_invoices i
JOIN crm_projects p ON p.id = i.project_id
JOIN customers c ON c.id = i.customer_id
WHERE i.status = 'paid'
GROUP BY p.id, p.name, c.id, c.name
ORDER BY total_revenue DESC;
```

---

## Supabase View (optional)

Если используешь Supabase, можно создать view для частых запросов:

```sql
CREATE OR REPLACE VIEW crm_revenue_monthly AS
SELECT
  date_trunc('month', paid_at) AS month,
  SUM(amount) AS revenue,
  COUNT(*) AS invoice_count,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM crm_invoices
WHERE status = 'paid'
GROUP BY month
ORDER BY month DESC;
```

---
name: stripe-integration
description: "Используй при добавлении платежей в интернет-магазин. Stripe Checkout, вебхуки, обработка заказов для Next.js."
---

# Stripe Integration для Next.js

## Когда использовать

**ПРИ ДОБАВЛЕНИИ ПЛАТЕЖЕЙ** в любой e-commerce проект.

---

## Шаг 1: Установка

```bash
npm install stripe @stripe/stripe-js
```

---

## Шаг 2: Environment Variables

```env
# .env.local
STRIPE_SECRET_KEY=sk_test_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

---

## Шаг 3: Stripe Checkout (рекомендуется)

### API Route для создания сессии:

```ts
// app/api/checkout/route.ts
import { NextResponse } from 'next/server'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(req: Request) {
  const { items } = await req.json()

  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: items.map((item: any) => ({
      price_data: {
        currency: 'eur',
        product_data: {
          name: item.name,
          images: [item.image],
        },
        unit_amount: item.price * 100, // в центах
      },
      quantity: item.quantity,
    })),
    mode: 'payment',
    success_url: `${process.env.NEXT_PUBLIC_SITE_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_SITE_URL}/cart`,
    metadata: {
      orderId: 'order_123', // для связи с БД
    },
  })

  return NextResponse.json({ url: session.url })
}
```

### Клиентский код:

```tsx
// components/CheckoutButton.tsx
'use client'

import { loadStripe } from '@stripe/stripe-js'

const stripePromise = loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!)

export function CheckoutButton({ items }: { items: CartItem[] }) {
  const handleCheckout = async () => {
    const response = await fetch('/api/checkout', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ items }),
    })
    
    const { url } = await response.json()
    window.location.href = url
  }

  return (
    <button onClick={handleCheckout}>
      Оплатить
    </button>
  )
}
```

---

## Шаг 4: Webhook для обработки платежей

```ts
// app/api/webhook/route.ts
import { NextResponse } from 'next/server'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

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
    return NextResponse.json({ error: 'Webhook error' }, { status: 400 })
  }

  switch (event.type) {
    case 'checkout.session.completed':
      const session = event.data.object as Stripe.Checkout.Session
      // Обновить заказ в БД
      await updateOrderStatus(session.metadata?.orderId, 'paid')
      // Отправить email
      await sendOrderConfirmation(session.customer_email!)
      break
      
    case 'payment_intent.payment_failed':
      // Обработать неудачный платёж
      break
  }

  return NextResponse.json({ received: true })
}
```

---

## Шаг 5: Тестирование

### Тестовые карты:
| Карта | Результат |
|-------|-----------|
| `4242 4242 4242 4242` | Успешный платёж |
| `4000 0000 0000 0002` | Отклонено |
| `4000 0025 0000 3155` | Требует 3D Secure |

### Локальный webhook:
```bash
stripe listen --forward-to localhost:3000/api/webhook
```

---

## Чеклист интеграции

- [ ] Stripe аккаунт создан
- [ ] API ключи в env
- [ ] Checkout сессия создаётся
- [ ] Редирект на success/cancel работает
- [ ] Webhook настроен и тестирован
- [ ] Заказы сохраняются в БД
- [ ] Email уведомления отправляются
- [ ] Production ключи перед запуском

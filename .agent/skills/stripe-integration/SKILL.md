---
name: stripe-integration
description: "Use when adding payments to an e-commerce store. Stripe Checkout, webhooks, order processing for Next.js."
---

# Stripe Integration for Next.js

## When to use

**WHEN ADDING PAYMENTS** to any e-commerce project.

---

## Step 1: Installation

```bash
npm install stripe @stripe/stripe-js
```

---

## Step 2: Environment Variables

```env
# .env.local
STRIPE_SECRET_KEY=sk_test_xxx
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx
```

---

## Step 3: Stripe Checkout (recommended)

### API Route for creating a session:

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
        unit_amount: item.price * 100, // in cents
      },
      quantity: item.quantity,
    })),
    mode: 'payment',
    success_url: `${process.env.NEXT_PUBLIC_SITE_URL}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${process.env.NEXT_PUBLIC_SITE_URL}/cart`,
    metadata: {
      orderId: 'order_123', // to link with DB
    },
  })

  return NextResponse.json({ url: session.url })
}
```

### Client-side code:

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
      Pay Now
    </button>
  )
}
```

---

## Step 4: Webhook for Payment Processing

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
      // Update order in DB
      await updateOrderStatus(session.metadata?.orderId, 'paid')
      // Send email
      await sendOrderConfirmation(session.customer_email!)
      break
      
    case 'payment_intent.payment_failed':
      // Handle failed payment
      break
  }

  return NextResponse.json({ received: true })
}
```

---

## Step 5: Testing

### Test cards:
| Card | Result |
|------|--------|
| `4242 4242 4242 4242` | Successful payment |
| `4000 0000 0000 0002` | Declined |
| `4000 0025 0000 3155` | Requires 3D Secure |

### Local webhook:
```bash
stripe listen --forward-to localhost:3000/api/webhook
```

---

## Integration Checklist

- [ ] Stripe account created
- [ ] API keys in env
- [ ] Checkout session creates
- [ ] Redirect to success/cancel works
- [ ] Webhook configured and tested
- [ ] Orders saved to DB
- [ ] Email notifications sent
- [ ] Production keys before launch

---
name: email-integration
description: "Use when setting up email: contact forms, transactional emails, notifications. EmailJS, Resend, React Email."
---

# Email Integration for Next.js

## When to use

**WHEN ADDING FORMS** or **TRANSACTIONAL EMAILS** (order confirmation, password reset).

---

## Option 1: EmailJS (for contact forms)

**Pros:** Works without backend, free 200 emails/month.

### Installation:
```bash
npm install @emailjs/browser
```

### Setup:
1. Sign up at [emailjs.com](https://www.emailjs.com)
2. Add Email Service (Gmail/Outlook)
3. Create Email Template with variables: `{{user_name}}`, `{{user_email}}`, `{{message}}`

### Code:
```tsx
'use client'

import { useRef } from 'react'
import emailjs from '@emailjs/browser'
import { toast } from 'sonner'

export function ContactForm() {
  const formRef = useRef<HTMLFormElement>(null)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    try {
      await emailjs.sendForm(
        'YOUR_SERVICE_ID',
        'YOUR_TEMPLATE_ID',
        formRef.current!,
        'YOUR_PUBLIC_KEY'
      )
      toast.success('Message sent!')
      formRef.current?.reset()
    } catch (error) {
      toast.error('Failed to send')
    }
  }

  return (
    <form ref={formRef} onSubmit={handleSubmit}>
      <input name="user_name" placeholder="Name" required />
      <input name="user_email" type="email" placeholder="Email" required />
      <textarea name="message" placeholder="Message" required />
      <button type="submit">Send</button>
    </form>
  )
}
```

---

## Option 2: Resend (for transactional emails)

**Pros:** Modern API, React Email, 3000 emails/month free.

### Installation:
```bash
npm install resend @react-email/components
```

### Environment:
```env
RESEND_API_KEY=re_xxx
```

### Email template (React Email):
```tsx
// emails/OrderConfirmation.tsx
import {
  Html,
  Head,
  Body,
  Container,
  Heading,
  Text,
  Button,
} from '@react-email/components'

interface OrderConfirmationProps {
  customerName: string
  orderNumber: string
  total: string
}

export function OrderConfirmation({
  customerName,
  orderNumber,
  total,
}: OrderConfirmationProps) {
  return (
    <Html>
      <Head />
      <Body style={{ fontFamily: 'sans-serif' }}>
        <Container>
          <Heading>Thank you for your order!</Heading>
          <Text>Hi, {customerName}!</Text>
          <Text>
            Your order #{orderNumber} for {total} has been confirmed.
          </Text>
          <Button
            href="https://example.com/orders"
            style={{ background: '#000', color: '#fff', padding: '12px 24px' }}
          >
            View Order
          </Button>
        </Container>
      </Body>
    </Html>
  )
}
```

### Sending:
```ts
// app/api/send-email/route.ts
import { Resend } from 'resend'
import { OrderConfirmation } from '@/emails/OrderConfirmation'

const resend = new Resend(process.env.RESEND_API_KEY)

export async function POST(req: Request) {
  const { email, name, orderNumber, total } = await req.json()

  await resend.emails.send({
    from: 'Shop <orders@example.com>',
    to: email,
    subject: `Order #${orderNumber} confirmed`,
    react: OrderConfirmation({
      customerName: name,
      orderNumber,
      total,
    }),
  })

  return Response.json({ success: true })
}
```

---

## Option 3: Nodemailer (full control)

```ts
// lib/email.ts
import nodemailer from 'nodemailer'

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS, // App Password for Gmail
  },
})

export async function sendEmail({
  to,
  subject,
  html,
}: {
  to: string
  subject: string
  html: string
}) {
  await transporter.sendMail({
    from: '"Shop" <noreply@example.com>',
    to,
    subject,
    html,
  })
}
```

---

## Which option to choose?

| Scenario | Recommendation |
|----------|---------------|
| Contact form | EmailJS |
| Transactional emails | Resend |
| Full control / own SMTP | Nodemailer |

---

## Checklist

- [ ] Service chosen (EmailJS/Resend/Nodemailer)
- [ ] API keys in env
- [ ] Email templates created
- [ ] Form works and sends
- [ ] Emails arrive (check spam!)
- [ ] Validation on client and server

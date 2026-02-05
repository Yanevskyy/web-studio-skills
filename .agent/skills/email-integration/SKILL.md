---
name: email-integration
description: "Используй для настройки email: контактные формы, транзакционные письма, уведомления. EmailJS, Resend, React Email."
---

# Email Integration для Next.js

## Когда использовать

**ПРИ ДОБАВЛЕНИИ ФОРМ** или **ТРАНЗАКЦИОННЫХ ПИСЕМ** (подтверждение заказа, сброс пароля).

---

## Вариант 1: EmailJS (для контактных форм)

**Плюсы:** Работает без бэкенда, бесплатно 200 писем/месяц.

### Установка:
```bash
npm install @emailjs/browser
```

### Настройка:
1. Зарегистрируйся на [emailjs.com](https://www.emailjs.com)
2. Добавь Email Service (Gmail/Outlook)
3. Создай Email Template с переменными: `{{user_name}}`, `{{user_email}}`, `{{message}}`

### Код:
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
      toast.success('Сообщение отправлено!')
      formRef.current?.reset()
    } catch (error) {
      toast.error('Ошибка отправки')
    }
  }

  return (
    <form ref={formRef} onSubmit={handleSubmit}>
      <input name="user_name" placeholder="Имя" required />
      <input name="user_email" type="email" placeholder="Email" required />
      <textarea name="message" placeholder="Сообщение" required />
      <button type="submit">Отправить</button>
    </form>
  )
}
```

---

## Вариант 2: Resend (для транзакционных писем)

**Плюсы:** Современный API, React Email, 3000 писем/месяц бесплатно.

### Установка:
```bash
npm install resend @react-email/components
```

### Environment:
```env
RESEND_API_KEY=re_xxx
```

### Email шаблон (React Email):
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
          <Heading>Спасибо за заказ!</Heading>
          <Text>Привет, {customerName}!</Text>
          <Text>
            Ваш заказ #{orderNumber} на сумму {total} успешно оформлен.
          </Text>
          <Button
            href="https://example.com/orders"
            style={{ background: '#000', color: '#fff', padding: '12px 24px' }}
          >
            Посмотреть заказ
          </Button>
        </Container>
      </Body>
    </Html>
  )
}
```

### Отправка:
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
    subject: `Заказ #${orderNumber} подтверждён`,
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

## Вариант 3: Nodemailer (полный контроль)

```ts
// lib/email.ts
import nodemailer from 'nodemailer'

const transporter = nodemailer.createTransport({
  host: 'smtp.gmail.com',
  port: 587,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS, // App Password для Gmail
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

## Какой вариант выбрать?

| Сценарий | Рекомендация |
|----------|--------------|
| Контактная форма | EmailJS |
| Транзакционные письма | Resend |
| Полный контроль / свой SMTP | Nodemailer |

---

## Чеклист

- [ ] Выбран сервис (EmailJS/Resend/Nodemailer)
- [ ] API ключи в env
- [ ] Шаблоны писем созданы
- [ ] Форма работает и отправляет
- [ ] Письма приходят (проверь спам!)
- [ ] Валидация на клиенте и сервере

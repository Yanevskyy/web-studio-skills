---
name: facebook-pixel
description: "Используй при настройке рекламы Facebook/Instagram. Meta Pixel, события, аудитории ретаргетинга для Next.js."
---

# Facebook Pixel для Next.js

## Когда использовать

**ПРИ ЗАПУСКЕ РЕКЛАМЫ** в Facebook/Instagram.

---

## Шаг 1: Создание Pixel

1. [Meta Events Manager](https://business.facebook.com/events_manager)
2. Connect Data Sources → Web → Meta Pixel
3. Скопируй Pixel ID

---

## Шаг 2: Установка

### Environment:
```env
NEXT_PUBLIC_FACEBOOK_PIXEL_ID=123456789
```

### Компонент:
```tsx
// components/FacebookPixel.tsx
'use client'

import { usePathname, useSearchParams } from 'next/navigation'
import Script from 'next/script'
import { useEffect, Suspense } from 'react'

const FB_PIXEL_ID = process.env.NEXT_PUBLIC_FACEBOOK_PIXEL_ID

declare global {
  interface Window {
    fbq: any
    _fbq: any
  }
}

function FacebookPixelEvents() {
  const pathname = usePathname()
  const searchParams = useSearchParams()

  useEffect(() => {
    if (typeof window.fbq === 'function') {
      window.fbq('track', 'PageView')
    }
  }, [pathname, searchParams])

  return null
}

export function FacebookPixel() {
  if (!FB_PIXEL_ID) return null

  return (
    <>
      <Script
        id="fb-pixel"
        strategy="afterInteractive"
        dangerouslySetInnerHTML={{
          __html: `
            !function(f,b,e,v,n,t,s)
            {if(f.fbq)return;n=f.fbq=function(){n.callMethod?
            n.callMethod.apply(n,arguments):n.queue.push(arguments)};
            if(!f._fbq)f._fbq=n;n.push=n;n.loaded=!0;n.version='2.0';
            n.queue=[];t=b.createElement(e);t.async=!0;
            t.src=v;s=b.getElementsByTagName(e)[0];
            s.parentNode.insertBefore(t,s)}(window, document,'script',
            'https://connect.facebook.net/en_US/fbevents.js');
            fbq('init', '${FB_PIXEL_ID}');
            fbq('track', 'PageView');
          `,
        }}
      />
      <Suspense fallback={null}>
        <FacebookPixelEvents />
      </Suspense>
    </>
  )
}
```

### В layout:
```tsx
// app/layout.tsx
import { FacebookPixel } from '@/components/FacebookPixel'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <FacebookPixel />
        {children}
      </body>
    </html>
  )
}
```

---

## Шаг 3: Отслеживание событий

### Функция отправки:
```tsx
// lib/facebook.ts
export function trackFBEvent(eventName: string, params?: Record<string, any>) {
  if (typeof window.fbq === 'function') {
    window.fbq('track', eventName, params)
  }
}

// Custom events
export function trackFBCustomEvent(eventName: string, params?: Record<string, any>) {
  if (typeof window.fbq === 'function') {
    window.fbq('trackCustom', eventName, params)
  }
}
```

### Стандартные события:
```tsx
// Просмотр контента
trackFBEvent('ViewContent', {
  content_name: 'Product Name',
  content_category: 'Category',
  content_ids: ['SKU123'],
  content_type: 'product',
  value: 29.99,
  currency: 'EUR',
})

// Добавление в корзину
trackFBEvent('AddToCart', {
  content_ids: ['SKU123'],
  content_type: 'product',
  value: 29.99,
  currency: 'EUR',
})

// Начало оформления
trackFBEvent('InitiateCheckout', {
  content_ids: ['SKU123', 'SKU456'],
  num_items: 2,
  value: 59.98,
  currency: 'EUR',
})

// Покупка
trackFBEvent('Purchase', {
  content_ids: ['SKU123'],
  content_type: 'product',
  value: 29.99,
  currency: 'EUR',
})

// Лид (контактная форма)
trackFBEvent('Lead', {
  content_name: 'Contact Form',
})
```

---

## Шаг 4: Тестирование

1. [Meta Pixel Helper](https://chrome.google.com/webstore/detail/meta-pixel-helper) — Chrome extension
2. Events Manager → Test Events → Open Website
3. Проверь, что события приходят

---

## Шаг 5: Conversions API (серверные события)

Для более точного отслеживания (обход блокировщиков):

```ts
// app/api/fb-event/route.ts
export async function POST(req: Request) {
  const { eventName, userData, customData } = await req.json()

  await fetch(
    `https://graph.facebook.com/v18.0/${process.env.FACEBOOK_PIXEL_ID}/events`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        data: [
          {
            event_name: eventName,
            event_time: Math.floor(Date.now() / 1000),
            action_source: 'website',
            user_data: {
              em: hashEmail(userData.email), // SHA256
              client_ip_address: userData.ip,
              client_user_agent: userData.userAgent,
            },
            custom_data: customData,
          },
        ],
        access_token: process.env.FACEBOOK_ACCESS_TOKEN,
      }),
    }
  )

  return Response.json({ success: true })
}
```

---

## Чеклист

- [ ] Pixel создан в Events Manager
- [ ] Pixel ID в env
- [ ] Код Pixel добавлен на сайт
- [ ] PageView отслеживается
- [ ] E-commerce события настроены
- [ ] Тестирование через Pixel Helper
- [ ] (Опционально) Conversions API

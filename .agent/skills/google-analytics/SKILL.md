---
name: google-analytics
description: "Используй при настройке аналитики. GA4, Google Tag Manager, Search Console. Отслеживание конверсий для Next.js."
---

# Google Analytics для Next.js

## Когда использовать

**ПЕРЕД ЗАПУСКОМ** любого коммерческого сайта.

---

## Шаг 1: Создание аккаунтов

1. **Google Analytics 4:** [analytics.google.com](https://analytics.google.com) → Создать ресурс
2. **Google Tag Manager:** [tagmanager.google.com](https://tagmanager.google.com) → Создать контейнер (Web)
3. **Search Console:** [search.google.com/search-console](https://search.google.com/search-console) → Добавить ресурс

---

## Шаг 2: Установка через GTM (рекомендуется)

### Environment:
```env
NEXT_PUBLIC_GTM_ID=GTM-XXXXXX
```

### Компонент:
```tsx
// components/GoogleTagManager.tsx
'use client'

import Script from 'next/script'

export function GoogleTagManager() {
  const gtmId = process.env.NEXT_PUBLIC_GTM_ID

  if (!gtmId) return null

  return (
    <>
      <Script
        id="gtm-script"
        strategy="afterInteractive"
        dangerouslySetInnerHTML={{
          __html: `
            (function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
            j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
            'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
            })(window,document,'script','dataLayer','${gtmId}');
          `,
        }}
      />
      <noscript>
        <iframe
          src={`https://www.googletagmanager.com/ns.html?id=${gtmId}`}
          height="0"
          width="0"
          style={{ display: 'none', visibility: 'hidden' }}
        />
      </noscript>
    </>
  )
}
```

### В layout:
```tsx
// app/layout.tsx
import { GoogleTagManager } from '@/components/GoogleTagManager'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        <GoogleTagManager />
        {children}
      </body>
    </html>
  )
}
```

---

## Шаг 3: Настройка GA4 в GTM

1. В GTM: Tags → New → Google Analytics: GA4 Configuration
2. Measurement ID: `G-XXXXXXXXXX` (из GA4)
3. Trigger: All Pages
4. Publish

---

## Шаг 4: Отслеживание событий

### DataLayer push:
```tsx
// Отправка события
declare global {
  interface Window {
    dataLayer: any[]
  }
}

export function trackEvent(eventName: string, params?: Record<string, any>) {
  window.dataLayer?.push({
    event: eventName,
    ...params,
  })
}

// Использование
trackEvent('add_to_cart', {
  currency: 'EUR',
  value: 29.99,
  items: [{ item_id: 'SKU123', item_name: 'Product' }],
})
```

### E-commerce события:
| Событие | Когда |
|---------|-------|
| `view_item` | Просмотр товара |
| `add_to_cart` | Добавление в корзину |
| `begin_checkout` | Начало оформления |
| `purchase` | Успешная покупка |

```tsx
// Пример purchase
trackEvent('purchase', {
  transaction_id: 'T12345',
  value: 99.99,
  currency: 'EUR',
  items: [
    { item_id: 'SKU1', item_name: 'Product 1', price: 49.99, quantity: 2 },
  ],
})
```

---

## Шаг 5: Search Console

1. Добавь сайт в Search Console
2. Подтверди через DNS или HTML-тег
3. Отправь sitemap: `https://example.com/sitemap.xml`
4. Свяжи с GA4: GA4 → Admin → Product Links → Search Console

---

## Чеклист

- [ ] GA4 ресурс создан
- [ ] GTM контейнер создан
- [ ] GTM код добавлен на сайт
- [ ] GA4 тег настроен в GTM
- [ ] События e-commerce отслеживаются
- [ ] Search Console подключён
- [ ] Sitemap отправлен
- [ ] GA4 и Search Console связаны

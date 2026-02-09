---
name: google-analytics
description: "Use when setting up analytics. GA4, Google Tag Manager, Search Console. Conversion tracking for Next.js."
---

# Google Analytics for Next.js

## When to use

**BEFORE LAUNCHING** any commercial website.

---

## Step 1: Create Accounts

1. **Google Analytics 4:** [analytics.google.com](https://analytics.google.com) → Create property
2. **Google Tag Manager:** [tagmanager.google.com](https://tagmanager.google.com) → Create container (Web)
3. **Search Console:** [search.google.com/search-console](https://search.google.com/search-console) → Add property

---

## Step 2: Install via GTM (recommended)

### Environment:
```env
NEXT_PUBLIC_GTM_ID=GTM-XXXXXX
```

### Component:
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

### In layout:
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

## Step 3: Configure GA4 in GTM

1. In GTM: Tags → New → Google Analytics: GA4 Configuration
2. Measurement ID: `G-XXXXXXXXXX` (from GA4)
3. Trigger: All Pages
4. Publish

---

## Step 4: Event Tracking

### DataLayer push:
```tsx
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

// Usage
trackEvent('add_to_cart', {
  currency: 'EUR',
  value: 29.99,
  items: [{ item_id: 'SKU123', item_name: 'Product' }],
})
```

### E-commerce events:
| Event | When |
|-------|------|
| `view_item` | Product view |
| `add_to_cart` | Added to cart |
| `begin_checkout` | Checkout started |
| `purchase` | Successful purchase |

```tsx
// Purchase example
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

## Step 5: Search Console

1. Add site to Search Console
2. Verify via DNS or HTML tag
3. Submit sitemap: `https://example.com/sitemap.xml`
4. Link with GA4: GA4 → Admin → Product Links → Search Console

---

## Checklist

- [ ] GA4 property created
- [ ] GTM container created
- [ ] GTM code added to site
- [ ] GA4 tag configured in GTM
- [ ] E-commerce events tracked
- [ ] Search Console connected
- [ ] Sitemap submitted
- [ ] GA4 and Search Console linked

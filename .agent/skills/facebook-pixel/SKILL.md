---
name: facebook-pixel
description: "Use when setting up Facebook/Instagram ads. Meta Pixel, events, retargeting audiences for Next.js."
---

# Facebook Pixel for Next.js

## When to use

**WHEN LAUNCHING ADS** on Facebook/Instagram.

---

## Step 1: Create Pixel

1. [Meta Events Manager](https://business.facebook.com/events_manager)
2. Connect Data Sources → Web → Meta Pixel
3. Copy Pixel ID

---

## Step 2: Installation

### Environment:
```env
NEXT_PUBLIC_FACEBOOK_PIXEL_ID=123456789
```

### Component:
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

### In layout:
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

## Step 3: Event Tracking

### Helper function:
```tsx
// lib/facebook.ts
export function trackFBEvent(eventName: string, params?: Record<string, any>) {
  if (typeof window.fbq === 'function') {
    window.fbq('track', eventName, params)
  }
}

export function trackFBCustomEvent(eventName: string, params?: Record<string, any>) {
  if (typeof window.fbq === 'function') {
    window.fbq('trackCustom', eventName, params)
  }
}
```

### Standard events:
```tsx
// View content
trackFBEvent('ViewContent', {
  content_name: 'Product Name',
  content_category: 'Category',
  content_ids: ['SKU123'],
  content_type: 'product',
  value: 29.99,
  currency: 'EUR',
})

// Add to cart
trackFBEvent('AddToCart', {
  content_ids: ['SKU123'],
  content_type: 'product',
  value: 29.99,
  currency: 'EUR',
})

// Initiate checkout
trackFBEvent('InitiateCheckout', {
  content_ids: ['SKU123', 'SKU456'],
  num_items: 2,
  value: 59.98,
  currency: 'EUR',
})

// Purchase
trackFBEvent('Purchase', {
  content_ids: ['SKU123'],
  content_type: 'product',
  value: 29.99,
  currency: 'EUR',
})

// Lead (contact form)
trackFBEvent('Lead', {
  content_name: 'Contact Form',
})
```

---

## Step 4: Testing

1. [Meta Pixel Helper](https://chrome.google.com/webstore/detail/meta-pixel-helper) — Chrome extension
2. Events Manager → Test Events → Open Website
3. Verify events are received

---

## Step 5: Conversions API (server-side events)

For more accurate tracking (bypasses ad blockers):

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

## Checklist

- [ ] Pixel created in Events Manager
- [ ] Pixel ID in env
- [ ] Pixel code added to site
- [ ] PageView tracked
- [ ] E-commerce events configured
- [ ] Tested with Pixel Helper
- [ ] (Optional) Conversions API

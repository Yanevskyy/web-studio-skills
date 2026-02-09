---
name: seo-performance
description: "Use for speed optimization. Core Web Vitals: LCP, FID, CLS. Lighthouse audit for Next.js."
---

# SEO Performance (Core Web Vitals)

## When to use

**BEFORE LAUNCH** and **REGULARLY** to maintain Google rankings.

---

## Core Web Vitals

| Metric | What it Measures | Good | Poor |
|--------|-----------------|------|------|
| **LCP** (Largest Contentful Paint) | Load speed | < 2.5s | > 4s |
| **FID** (First Input Delay) | Responsiveness | < 100ms | > 300ms |
| **CLS** (Cumulative Layout Shift) | Visual stability | < 0.1 | > 0.25 |

---

## Step 1: Measurement

### Tools:
- [PageSpeed Insights](https://pagespeed.web.dev/)
- [Lighthouse](chrome://inspect/#devices) in Chrome DevTools
- [Search Console](https://search.google.com/search-console) → Core Web Vitals

### In code (web-vitals):
```bash
npm install web-vitals
```

```tsx
// app/layout.tsx
'use client'

import { useEffect } from 'react'

export function WebVitals() {
  useEffect(() => {
    import('web-vitals').then(({ onCLS, onFID, onLCP }) => {
      onCLS(console.log)
      onFID(console.log)
      onLCP(console.log)
    })
  }, [])
  return null
}
```

---

## Step 2: Optimize LCP

### Images:
```tsx
import Image from 'next/image'

// Hero image
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority // Critical for LCP!
  sizes="100vw"
/>
```

### Fonts:
```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin', 'cyrillic'],
  display: 'swap', // Show text before font loads
  preload: true,
})
```

### Preload critical resources:
```tsx
// app/layout.tsx
export const metadata = {
  other: {
    'link': [
      { rel: 'preload', href: '/hero.jpg', as: 'image' },
      { rel: 'preconnect', href: 'https://fonts.gstatic.com' },
    ],
  },
}
```

---

## Step 3: Optimize FID

### Code splitting:
```tsx
// Lazy load heavy components
import dynamic from 'next/dynamic'

const HeavyComponent = dynamic(() => import('@/components/Heavy'), {
  loading: () => <p>Loading...</p>,
  ssr: false, // If not needed on server
})
```

### Defer non-critical JS:
```tsx
<Script src="/analytics.js" strategy="lazyOnload" />
```

---

## Step 4: Optimize CLS

### Reserve space for images:
```tsx
// ALWAYS specify width and height
<Image
  src="/photo.jpg"
  alt="Photo"
  width={800}
  height={600}
/>
```

### Reserve space for dynamic content:
```css
/* Skeleton for cards */
.skeleton {
  min-height: 200px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  animation: shimmer 1.5s infinite;
}
```

### Fonts without layout shift:
```tsx
const font = Inter({
  display: 'swap',
  adjustFontFallback: true, // Minimizes layout shift
})
```

---

## Step 5: Next.js Optimizations

### next.config.js:
```js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920],
  },
  experimental: {
    optimizeCss: true, // CSS minification
  },
  compress: true,
}
```

### Static generation:
```tsx
// Use SSG where possible
export const dynamic = 'force-static'
export const revalidate = 3600 // ISR every hour
```

---

## Optimization Checklist

### LCP (< 2.5s):
- [ ] Hero image with `priority`
- [ ] Fonts with `display: swap`
- [ ] Preload critical resources
- [ ] SSG/ISR for static pages

### FID (< 100ms):
- [ ] Code splitting for heavy components
- [ ] Defer non-critical scripts
- [ ] Minimize JS bundle

### CLS (< 0.1):
- [ ] All images with width/height
- [ ] Skeleton loaders for dynamic content
- [ ] Font fallback configured

### General:
- [ ] AVIF/WebP for images
- [ ] Gzip/Brotli compression
- [ ] CDN for static assets (Vercel Edge Network)

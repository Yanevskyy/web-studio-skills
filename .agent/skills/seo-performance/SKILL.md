---
name: seo-performance
description: "Используй для оптимизации скорости. Core Web Vitals: LCP, FID, CLS. Lighthouse аудит для Next.js."
---

# SEO Performance (Core Web Vitals)

## Когда использовать

**ПЕРЕД ЗАПУСКОМ** и **РЕГУЛЯРНО** для поддержания позиций в Google.

---

## Core Web Vitals

| Метрика | Что измеряет | Хорошо | Плохо |
|---------|--------------|--------|-------|
| **LCP** (Largest Contentful Paint) | Скорость загрузки | < 2.5s | > 4s |
| **FID** (First Input Delay) | Отзывчивость | < 100ms | > 300ms |
| **CLS** (Cumulative Layout Shift) | Стабильность | < 0.1 | > 0.25 |

---

## Шаг 1: Измерение

### Инструменты:
- [PageSpeed Insights](https://pagespeed.web.dev/)
- [Lighthouse](chrome://inspect/#devices) в Chrome DevTools
- [Search Console](https://search.google.com/search-console) → Core Web Vitals

### В коде (web-vitals):
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

## Шаг 2: Оптимизация LCP

### Изображения:
```tsx
import Image from 'next/image'

// Hero изображение
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  priority // Критически важно для LCP!
  sizes="100vw"
/>
```

### Шрифты:
```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin', 'cyrillic'],
  display: 'swap', // Показать текст до загрузки шрифта
  preload: true,
})
```

### Preload критических ресурсов:
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

## Шаг 3: Оптимизация FID

### Code splitting:
```tsx
// Ленивая загрузка тяжёлых компонентов
import dynamic from 'next/dynamic'

const HeavyComponent = dynamic(() => import('@/components/Heavy'), {
  loading: () => <p>Loading...</p>,
  ssr: false, // Если не нужен на сервере
})
```

### Defer non-critical JS:
```tsx
<Script src="/analytics.js" strategy="lazyOnload" />
```

---

## Шаг 4: Оптимизация CLS

### Резервируй место для изображений:
```tsx
// ВСЕГДА указывай width и height
<Image
  src="/photo.jpg"
  alt="Photo"
  width={800}
  height={600}
/>
```

### Резервируй место для динамического контента:
```css
/* Skeleton для карточек */
.skeleton {
  min-height: 200px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  animation: shimmer 1.5s infinite;
}
```

### Шрифты без сдвига:
```tsx
const font = Inter({
  display: 'swap',
  adjustFontFallback: true, // Минимизирует сдвиг
})
```

---

## Шаг 5: Next.js оптимизации

### next.config.js:
```js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920],
  },
  experimental: {
    optimizeCss: true, // Минификация CSS
  },
  compress: true,
}
```

### Статическая генерация:
```tsx
// Используй SSG где возможно
export const dynamic = 'force-static'
export const revalidate = 3600 // ISR каждый час
```

---

## Чеклист оптимизации

### LCP (< 2.5s):
- [ ] Hero изображение с `priority`
- [ ] Шрифты с `display: swap`
- [ ] Preload критических ресурсов
- [ ] SSG/ISR для статических страниц

### FID (< 100ms):
- [ ] Code splitting для тяжёлых компонентов
- [ ] Defer non-critical scripts
- [ ] Минимизация JS бандла

### CLS (< 0.1):
- [ ] Все изображения с width/height
- [ ] Skeleton loaders для динамики
- [ ] Font fallback настроен

### Общее:
- [ ] AVIF/WebP для изображений
- [ ] Gzip/Brotli сжатие
- [ ] CDN для статики (Vercel Edge Network)

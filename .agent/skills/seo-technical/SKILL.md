---
name: seo-technical
description: "ОБЯЗАТЕЛЬНО используй перед деплоем любого сайта. Чеклист технического SEO для Next.js: мета-теги, Open Graph, schema.org, sitemap, robots.txt, изображения."
---

# Technical SEO для Next.js

## Когда использовать

**ПЕРЕД КАЖДЫМ ДЕПЛОЕМ** — пройди этот чеклист. Пропуск любого пункта = потеря позиций в Google.

---

## Чеклист

### 1. Мета-теги (обязательно)

```tsx
// app/layout.tsx или page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Page Title | Brand Name',
  description: 'Описание страницы 150-160 символов. Включает ключевые слова.',
  keywords: ['ключевое слово 1', 'ключевое слово 2'],
  authors: [{ name: 'Author Name' }],
  robots: {
    index: true,
    follow: true,
  },
}
```

**Проверь:**
- [ ] `title` уникален для каждой страницы (50-60 символов)
- [ ] `description` уникален (150-160 символов)
- [ ] Нет дублей title/description на разных страницах

---

### 2. Open Graph (для соцсетей)

```tsx
export const metadata: Metadata = {
  openGraph: {
    title: 'Заголовок для шеринга',
    description: 'Описание для соцсетей',
    url: 'https://example.com/page',
    siteName: 'Brand Name',
    images: [
      {
        url: 'https://example.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Описание изображения',
      },
    ],
    locale: 'ru_RU',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Заголовок для Twitter',
    description: 'Описание для Twitter',
    images: ['https://example.com/twitter-image.jpg'],
  },
}
```

**Проверь:**
- [ ] OG-изображение 1200x630px
- [ ] Изображение содержит текст/лого (читается в превью)
- [ ] Протестировано: [Facebook Debugger](https://developers.facebook.com/tools/debug/)

---

### 3. Schema.org (JSON-LD)

```tsx
// app/layout.tsx
export default function RootLayout({ children }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Organization', // или LocalBusiness, Product, Article
    name: 'Company Name',
    url: 'https://example.com',
    logo: 'https://example.com/logo.png',
    contactPoint: {
      '@type': 'ContactPoint',
      telephone: '+353-1-234-5678',
      contactType: 'customer service',
    },
    sameAs: [
      'https://facebook.com/company',
      'https://instagram.com/company',
    ],
  }

  return (
    <html>
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body>{children}</body>
    </html>
  )
}
```

**Типы Schema.org по типу сайта:**
| Тип сайта | Schema |
|-----------|--------|
| Компания | `Organization`, `LocalBusiness` |
| Магазин | `Product`, `Offer`, `AggregateRating` |
| Блог | `Article`, `BlogPosting` |
| Услуги | `Service`, `ProfessionalService` |

**Проверь:** [Google Rich Results Test](https://search.google.com/test/rich-results)

---

### 4. Sitemap

```bash
npm install next-sitemap
```

```js
// next-sitemap.config.js
module.exports = {
  siteUrl: 'https://example.com',
  generateRobotsTxt: true,
  changefreq: 'weekly',
  priority: 0.7,
  exclude: ['/admin/*', '/api/*'],
}
```

```json
// package.json
{
  "scripts": {
    "postbuild": "next-sitemap"
  }
}
```

**Проверь:**
- [ ] `sitemap.xml` генерируется при билде
- [ ] Все публичные страницы включены
- [ ] Отправлено в Google Search Console

---

### 5. robots.txt

```txt
# public/robots.txt
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /api/

Sitemap: https://example.com/sitemap.xml
```

**Проверь:**
- [ ] Не блокирует важные страницы
- [ ] Ссылка на sitemap указана

---

### 6. Изображения

```tsx
import Image from 'next/image'

<Image
  src="/photo.jpg"
  alt="Описательный alt-текст с ключевыми словами"
  width={800}
  height={600}
  priority={true} // для above-the-fold изображений
/>
```

**Проверь:**
- [ ] ВСЕ изображения имеют `alt`
- [ ] Alt описывает содержимое (не "image1.jpg")
- [ ] Используется `next/image` для оптимизации
- [ ] Первое изображение имеет `priority`

---

### 7. URL и навигация

**Проверь:**
- [ ] URL читаемые (`/about` не `/page?id=1`)
- [ ] Нет дублей (с www и без, с / и без)
- [ ] Canonical URL указан для всех страниц
- [ ] 404 страница существует и информативна

```tsx
export const metadata: Metadata = {
  alternates: {
    canonical: 'https://example.com/page',
  },
}
```

---

## Финальный чеклист перед деплоем

- [ ] Title уникален на каждой странице
- [ ] Description уникален на каждой странице
- [ ] OG-теги настроены, изображение 1200x630
- [ ] Schema.org добавлена, проверена в Rich Results
- [ ] Sitemap генерируется
- [ ] robots.txt корректен
- [ ] Все изображения с alt
- [ ] Canonical URL указаны
- [ ] 404 страница работает
- [ ] Сайт добавлен в Google Search Console

---
name: seo-technical
description: "MUST USE before deploying any website. Technical SEO checklist for Next.js: meta tags, Open Graph, schema.org, sitemap, robots.txt, images."
---

# Technical SEO for Next.js

## When to use

**BEFORE EVERY DEPLOY** — go through this checklist. Skipping any item = lost Google rankings.

---

## Checklist

### 1. Meta Tags (required)

```tsx
// app/layout.tsx or page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Page Title | Brand Name',
  description: 'Page description 150-160 characters. Includes keywords.',
  keywords: ['keyword 1', 'keyword 2'],
  authors: [{ name: 'Author Name' }],
  robots: {
    index: true,
    follow: true,
  },
}
```

**Check:**
- [ ] `title` is unique per page (50-60 characters)
- [ ] `description` is unique (150-160 characters)
- [ ] No duplicate title/description across pages

---

### 2. Open Graph (for social sharing)

```tsx
export const metadata: Metadata = {
  openGraph: {
    title: 'Share title',
    description: 'Description for social media',
    url: 'https://example.com/page',
    siteName: 'Brand Name',
    images: [
      {
        url: 'https://example.com/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'Image description',
      },
    ],
    locale: 'en_IE',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Twitter title',
    description: 'Twitter description',
    images: ['https://example.com/twitter-image.jpg'],
  },
}
```

**Check:**
- [ ] OG image 1200x630px
- [ ] Image contains text/logo (readable in preview)
- [ ] Tested: [Facebook Debugger](https://developers.facebook.com/tools/debug/)

---

### 3. Schema.org (JSON-LD)

```tsx
// app/layout.tsx
export default function RootLayout({ children }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Organization', // or LocalBusiness, Product, Article
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

**Schema.org types by website type:**
| Site Type | Schema |
|-----------|--------|
| Company | `Organization`, `LocalBusiness` |
| Store | `Product`, `Offer`, `AggregateRating` |
| Blog | `Article`, `BlogPosting` |
| Services | `Service`, `ProfessionalService` |

**Verify:** [Google Rich Results Test](https://search.google.com/test/rich-results)

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

**Check:**
- [ ] `sitemap.xml` generated on build
- [ ] All public pages included
- [ ] Submitted to Google Search Console

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

**Check:**
- [ ] Does not block important pages
- [ ] Sitemap link included

---

### 6. Images

```tsx
import Image from 'next/image'

<Image
  src="/photo.jpg"
  alt="Descriptive alt text with keywords"
  width={800}
  height={600}
  priority={true} // for above-the-fold images
/>
```

**Check:**
- [ ] ALL images have `alt`
- [ ] Alt describes content (not "image1.jpg")
- [ ] Uses `next/image` for optimization
- [ ] First image has `priority`

---

### 7. URLs and Navigation

**Check:**
- [ ] URLs are readable (`/about` not `/page?id=1`)
- [ ] No duplicates (with www and without, with / and without)
- [ ] Canonical URL set for all pages
- [ ] 404 page exists and is informative

```tsx
export const metadata: Metadata = {
  alternates: {
    canonical: 'https://example.com/page',
  },
}
```

---

## Final Pre-Deploy Checklist

- [ ] Title unique on every page
- [ ] Description unique on every page
- [ ] OG tags configured, image 1200x630
- [ ] Schema.org added, verified in Rich Results
- [ ] Sitemap generated
- [ ] robots.txt correct
- [ ] All images have alt
- [ ] Canonical URLs set
- [ ] 404 page works
- [ ] Site added to Google Search Console

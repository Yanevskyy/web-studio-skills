---
name: blog-system
description: "Skill for building a production-ready blog system. Article pages, routing, clickable cards, content strategy, light navigation. Use when adding a blog/journal to a site."
---

# Blog System Excellence

## Philosophy

> **A blog is not a collection of articles. It's the brand's voice that builds trust and loyalty.**

A professional blog must:
- Look like an extension of the main site
- Have full production-system functionality
- Scale easily for new articles
- Meet premium UX standards

---

## Blog System Architecture

### Required Components

```
src/
├── pages/
│   ├── Blog.tsx         # Article listing (cards)
│   └── BlogPost.tsx     # Article detail page
├── App.tsx              # Route /blog/:slug
└── components/
    └── Navigation.tsx   # Light mode for articles
```

### Article Data Structure

```typescript
interface BlogArticle {
  slug: string;          // URL-friendly identifier
  title: string;         // Title (≤ 12 words)
  excerpt: string;       // Brief description (≤ 30 words)
  image: string;         // Hero image
  date: string;          // Publication date
  category: string;      // Category for filtering
  readTime: string;      // "5 min read"
  content: string[];     // Array of paragraphs
}
```

---

## Implementation Checklist

### Listing Page (Blog.tsx)

- [ ] Featured post (main article) larger than others
- [ ] Article cards fully clickable
- [ ] Slug added to each article
- [ ] Link wrapper with hover effects
- [ ] Category and read time visible
- [ ] "Read article" button on featured post
- [ ] Newsletter CTA at end of page

### Article Page (BlogPost.tsx)

- [ ] Hero section with image at 70vh
- [ ] Dark overlay for navigation contrast
- [ ] Meta info (date, category, read time)
- [ ] Content with reveal animations
- [ ] "Back to Journal" button (light on hero)
- [ ] Subscription CTA after article
- [ ] Scroll to top on load

### Navigation (Navigation.tsx)

- [ ] Light mode for `/blog/:slug` pages
- [ ] White logo on hero
- [ ] White menu on hero
- [ ] Smooth transition on scroll

### Routing (App.tsx)

- [ ] BlogPost component imported
- [ ] Route path="/blog/:slug"
- [ ] Placed after /blog

---

## Implementation Patterns

### 1. Clickable Cards with Link

```tsx
// ❌ Wrong — only title is clickable
<article>
  <img src={post.image} />
  <Link to={`/blog/${post.slug}`}>{post.title}</Link>
</article>

// ✅ Correct — entire card is clickable
<Link to={`/blog/${post.slug}`} className="group">
  <article>
    <img 
      src={post.image} 
      className="group-hover:scale-105 transition-transform" 
    />
    <h3 className="group-hover:text-brown transition-colors">
      {post.title}
    </h3>
  </article>
</Link>
```

### 2. Light Navigation for Articles

```tsx
// Navigation.tsx
const isBlogPostPage = location.pathname.startsWith('/blog/');

const useLightColors = (
  isHomePage || 
  location.pathname === '/events' || 
  isBlogPostPage
) && !isScrolled;
```

### 3. Dark Overlay for Hero

```tsx
<section className="min-h-[70vh] relative flex items-end">
  <div className="absolute inset-0">
    <img src={article.image} className="w-full h-full object-cover" />
    <div 
      className="absolute inset-0"
      style={{
        background: `linear-gradient(
          135deg,
          rgba(0, 0, 0, 0.6) 0%,
          rgba(0, 0, 0, 0.4) 40%,
          rgba(0, 0, 0, 0.2) 100%
        )`
      }}
    />
    <div className="absolute inset-0 bg-gradient-to-t from-cream via-cream/60 to-transparent" />
  </div>
  <div className="container relative z-10 pb-20 pt-40">
    {/* Content */}
  </div>
</section>
```

### 4. Reveal Animations for Content

```tsx
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-up');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
  );
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  return () => observer.disconnect();
}, []);

{article.content.map((paragraph, index) => (
  <p 
    key={index} 
    className="reveal opacity-0"
    style={{ animationDelay: `${index * 0.05}s` }}
  >
    {paragraph}
  </p>
))}
```

---

## Content Strategy

### Article Structure

1. **Hook** (first paragraph) — capture attention
2. **Context** — why it matters
3. **Story/Content** — main body
4. **Insight** — key takeaway
5. **Call to Action** — what to do next

### Content Length

| Type | Words | Read Time |
|------|-------|-----------|
| Short | 500-800 | 3-4 min |
| Medium | 1000-1500 | 5-7 min |
| Long (flagship) | 2000-3000 | 8-12 min |

### Categories (examples)

- **Our Story** — brand history, founders
- **Process** — production, behind the scenes
- **Philosophy** — values, approach
- **Ingredients** — materials, suppliers
- **News** — announcements, updates

---

## Anti-Patterns

| Anti-pattern | Why it's bad | Alternative |
|--------------|-------------|-------------|
| **Cards without Link** | Not clickable | Wrap in Link |
| **Only title as link** | Poor UX | Entire card clickable |
| **Dark text on dark photo** | Unreadable | Dark overlay |
| **Standard nav on hero** | Blends in | Light mode |
| **Article without CTA** | Lost conversion | Newsletter, related posts |
| **Too many categories** | Confusing | 4-6 categories max |
| **Dates in ISO format** | Not human-readable | "January 2024" |

---

## Blog SEO

- [ ] Unique `<title>` for each article
- [ ] `<meta description>` from excerpt
- [ ] Open Graph tags
- [ ] Semantic HTML (`<article>`, `<time>`)
- [ ] Alt text for images
- [ ] Structured data (Article schema)

---

## Blog Audit Template

```markdown
## Blog Audit for [Project Name]

### Pages Check
- [ ] Blog listing page exists
- [ ] Blog post page exists
- [ ] Route /blog/:slug configured

### Functionality
- [ ] Cards clickable: _____
- [ ] Navigation light mode: _____
- [ ] Back button works: _____
- [ ] Scroll to top: _____

### Visual
- [ ] Hero overlay contrast: _____
- [ ] Hover effects: _____
- [ ] Mobile responsive: _____

### Content
- [ ] Article count: _____
- [ ] Categories: _____
- [ ] CTA presence: _____

### Issues found:
1. 
2. 

### Recommendations:
1. 
2. 
```

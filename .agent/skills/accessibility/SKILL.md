---
name: accessibility
description: "Use when checking accessibility. WCAG checklist: contrast, ARIA, keyboard navigation for React/Next.js."
---

# Web Accessibility (a11y)

## When to use

**WHEN BUILDING ANY INTERFACE** — accessibility is not optional.

---

## Why it matters

- 15% of the population has a disability
- SEO bonus (Google factors in accessibility)
- Legal requirement in EU and US
- Improves UX for everyone

---

## WCAG 2.1 Checklist

### 1. Text Contrast

| Level | Ratio |
|-------|-------|
| AA (standard) | 4.5:1 for text, 3:1 for headings |
| AAA (ideal) | 7:1 for text, 4.5:1 for headings |

**Tools:**
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)

```tsx
// ❌ Bad
<p className="text-gray-400 bg-gray-200">Low contrast</p>

// ✅ Good
<p className="text-gray-900 bg-white">High contrast</p>
```

---

### 2. Alternative Text

```tsx
// ❌ Bad
<img src="photo.jpg" />
<img src="photo.jpg" alt="image" />

// ✅ Good (informative images)
<img src="team.jpg" alt="Company team meeting at the office" />

// ✅ Good (decorative images)
<img src="decoration.jpg" alt="" role="presentation" />
```

---

### 3. Semantic HTML

```tsx
// ❌ Bad
<div onClick={handleClick}>Button</div>
<div className="header">Header</div>
<div className="nav">Navigation</div>

// ✅ Good
<button onClick={handleClick}>Button</button>
<header>Header</header>
<nav>Navigation</nav>
<main>Main content</main>
<footer>Footer</footer>
```

---

### 4. Headings

```tsx
// ❌ Bad (h2 skipped)
<h1>Title</h1>
<h3>Subtitle</h3>

// ✅ Good
<h1>Page Title</h1>
<h2>Section</h2>
<h3>Subsection</h3>
```

---

### 5. Links and Buttons

```tsx
// ❌ Bad
<a href="/page">Click here</a>
<button>X</button>

// ✅ Good
<a href="/products">View all products</a>
<button aria-label="Close modal window">
  <XIcon />
</button>
```

---

### 6. Forms

```tsx
// ❌ Bad
<input type="email" placeholder="Email" />

// ✅ Good
<div>
  <label htmlFor="email">Email</label>
  <input
    id="email"
    type="email"
    aria-describedby="email-error"
    aria-invalid={!!errors.email}
  />
  {errors.email && (
    <p id="email-error" role="alert">
      {errors.email}
    </p>
  )}
</div>
```

---

### 7. Keyboard Navigation

```tsx
// Visible focus
<button className="focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2">
  Button
</button>

// Skip link
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4"
>
  Skip to main content
</a>

<main id="main-content">
  ...
</main>
```

---

### 8. ARIA Attributes

```tsx
// Modal dialog
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
>
  <h2 id="modal-title">Modal Title</h2>
  ...
</div>

// Dropdown menu
<button
  aria-expanded={isOpen}
  aria-haspopup="menu"
>
  Menu
</button>
<ul role="menu" hidden={!isOpen}>
  <li role="menuitem">Item 1</li>
</ul>

// Loading state
<button disabled={isLoading}>
  {isLoading ? (
    <span aria-live="polite">Loading...</span>
  ) : (
    'Submit'
  )}
</button>
```

---

### 9. Tailwind Utilities

```tsx
// Visually hidden, available for screen readers
<span className="sr-only">Description for screen reader</span>

// Focus styles
<button className="
  focus:outline-none
  focus:ring-2
  focus:ring-offset-2
  focus:ring-primary
">
```

---

## Testing

### Tools:
- **axe DevTools** — Chrome extension
- **WAVE** — [wave.webaim.org](https://wave.webaim.org)
- **Lighthouse** — Accessibility audit
- **NVDA/VoiceOver** — Screen readers

### Manual testing:
1. [ ] Navigate entire site using keyboard only (Tab, Enter, Escape)
2. [ ] Test with VoiceOver (Mac) or NVDA (Windows)
3. [ ] Zoom to 200% — nothing should break

---

## Checklist

- [ ] Text contrast at least 4.5:1
- [ ] All images have alt text
- [ ] Semantic HTML (header, nav, main, footer)
- [ ] Headings in correct order
- [ ] Forms have labels
- [ ] Buttons/links have descriptive text
- [ ] Focus visible on Tab navigation
- [ ] Skip link for navigation
- [ ] Modals with correct ARIA
- [ ] Lighthouse Accessibility > 90

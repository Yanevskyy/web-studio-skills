---
name: responsive-design
description: "Use when building adaptive interfaces. Breakpoints, mobile-first patterns for Tailwind CSS."
---

# Responsive Design for Tailwind CSS

## When to use

**WHEN BUILDING ANY PAGE** — mobile-first approach.

---

## Tailwind Breakpoints

| Prefix | Min Width | Devices |
|--------|-----------|---------|
| (default) | 0px | Mobile |
| `sm:` | 640px | Large phones |
| `md:` | 768px | Tablets |
| `lg:` | 1024px | Laptops |
| `xl:` | 1280px | Desktops |
| `2xl:` | 1536px | Large monitors |

---

## Mobile-First Approach

```tsx
// ❌ Wrong (desktop-first)
<div className="text-lg md:text-base sm:text-sm">

// ✅ Correct (mobile-first)
<div className="text-sm md:text-base lg:text-lg">
```

**Rule:** Start with mobile styles, add styles for larger screens.

---

## Patterns

### 1. Container with Padding

```tsx
// Standard container
<div className="container mx-auto px-4 sm:px-6 lg:px-8">
  {/* Content */}
</div>

// Or with max-width
<div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  {/* Content */}
</div>
```

### 2. Responsive Grid

```tsx
// 1 → 2 → 3 → 4 columns
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### 3. Flexbox with Wrap

```tsx
// Column on mobile → row on desktop
<div className="flex flex-col md:flex-row gap-4 md:gap-8">
  <div className="w-full md:w-1/2">Left side</div>
  <div className="w-full md:w-1/2">Right side</div>
</div>
```

### 4. Hiding Elements

```tsx
// Mobile only
<div className="md:hidden">Mobile menu</div>

// Desktop only
<div className="hidden md:block">Desktop menu</div>
```

### 5. Responsive Typography

```tsx
// Heading
<h1 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold">
  Heading
</h1>

// Paragraph
<p className="text-sm sm:text-base lg:text-lg leading-relaxed">
  Text
</p>
```

### 6. Responsive Spacing

```tsx
// Section
<section className="py-12 sm:py-16 lg:py-24">
  {/* Content */}
</section>

// Card
<div className="p-4 sm:p-6 lg:p-8">
  {/* Content */}
</div>
```

### 7. Responsive Images

```tsx
import Image from 'next/image'

// Different sizes for different screens
<Image
  src="/hero.jpg"
  alt="Hero"
  fill
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  className="object-cover"
/>
```

### 8. Navigation

```tsx
// Mobile: burger, Desktop: horizontal menu
<nav className="flex items-center justify-between">
  <Logo />
  
  {/* Mobile menu */}
  <button className="md:hidden">
    <MenuIcon />
  </button>
  
  {/* Desktop menu */}
  <ul className="hidden md:flex gap-6">
    <li><Link href="/">Home</Link></li>
    <li><Link href="/about">About</Link></li>
  </ul>
</nav>
```

---

## Testing

### Chrome DevTools:
1. F12 → Toggle device toolbar
2. Check all breakpoints: 320px, 640px, 768px, 1024px, 1280px

### Real Devices:
- iPhone SE (375px)
- iPhone 14 (390px)
- iPad (768px)
- MacBook (1440px)

---

## Checklist

- [ ] Mobile-first approach used
- [ ] All breakpoints tested
- [ ] Navigation works on mobile
- [ ] Images are responsive
- [ ] Text is readable on all screens
- [ ] Buttons large enough for touch (min 44px)
- [ ] No horizontal scroll

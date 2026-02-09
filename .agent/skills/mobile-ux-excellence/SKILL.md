---
name: mobile-ux-excellence
description: "Use when reviewing mobile design. Anti-patterns, UX quality, micro-animations, wow-effects. Ensures the mobile version looks great."
---

# Mobile UX Excellence

## When to use

**BEFORE DEPLOY** — verify the mobile version isn't boring and truly impresses.

---

## Anti-Patterns (DON'T do this)

### Navigation
- Standard burger menu without animation
- Menu opens abruptly, no transition
- Small tap targets (< 44px)
- Menu takes full screen without style

### Cards
- Identical rectangular cards in a row
- No hover/tap states
- Static images without effects
- Boring shadows (shadow-md everywhere)

### Typography
- Same text size everywhere
- No visual hierarchy
- Headings without character

### General
- White background everywhere without accents
- No micro-animations
- Loading without skeleton/placeholder
- Buttons that look like Bootstrap defaults

---

## Wow Patterns

### 1. Navigation with Character

```tsx
const [isOpen, setIsOpen] = useState(false)

<button 
  onClick={() => setIsOpen(!isOpen)}
  className="relative z-50 w-10 h-10 flex flex-col justify-center items-center"
>
  <span className={`
    block w-6 h-0.5 bg-current transition-all duration-300
    ${isOpen ? 'rotate-45 translate-y-1' : ''}
  `} />
  <span className={`
    block w-6 h-0.5 bg-current mt-1.5 transition-all duration-300
    ${isOpen ? 'opacity-0' : ''}
  `} />
  <span className={`
    block w-6 h-0.5 bg-current mt-1.5 transition-all duration-300
    ${isOpen ? '-rotate-45 -translate-y-2.5' : ''}
  `} />
</button>

{/* Menu with staggered animation */}
<nav className={`
  fixed inset-0 bg-primary
  transition-all duration-500 ease-out
  ${isOpen ? 'opacity-100 visible' : 'opacity-0 invisible'}
`}>
  {links.map((link, i) => (
    <a 
      key={link.href}
      className="block text-4xl font-bold"
      style={{ 
        transitionDelay: `${i * 100}ms`,
        transform: isOpen ? 'translateY(0)' : 'translateY(20px)',
        opacity: isOpen ? 1 : 0,
      }}
    >
      {link.label}
    </a>
  ))}
</nav>
```

### 2. Cards with Depth

```tsx
<div className="
  group relative
  bg-white rounded-2xl p-6
  transition-all duration-300 ease-out
  hover:translate-y-[-4px]
  hover:shadow-[0_20px_40px_-15px_rgba(0,0,0,0.2)]
">
  <div className="
    absolute inset-0 rounded-2xl opacity-0
    bg-gradient-to-r from-primary/20 to-secondary/20
    transition-opacity duration-300
    group-hover:opacity-100
    -z-10 blur-xl
  " />
  <h3 className="text-xl font-semibold">{title}</h3>
</div>
```

### 3. Parallax Images (framer-motion)

```tsx
import { motion, useScroll, useTransform } from 'framer-motion'

function ParallaxImage({ src, alt }) {
  const ref = useRef(null)
  const { scrollYProgress } = useScroll({
    target: ref,
    offset: ["start end", "end start"]
  })
  const scale = useTransform(scrollYProgress, [0, 1], [1.1, 1])

  return (
    <div ref={ref} className="overflow-hidden rounded-2xl">
      <motion.img src={src} alt={alt} style={{ scale }}
        className="w-full h-full object-cover" />
    </div>
  )
}
```

### 4. Buttons with Life

```tsx
<button className="
  relative overflow-hidden
  bg-primary text-white
  px-8 py-4 rounded-full font-semibold
  transition-all duration-300
  active:scale-95
  hover:shadow-lg hover:shadow-primary/30
">
  <span className="relative z-10">Order Now</span>
  <div className="
    absolute inset-0 -translate-x-full
    bg-gradient-to-r from-transparent via-white/20 to-transparent
    group-hover:animate-shine
  " />
</button>
```

### 5. Skeleton Loaders

```tsx
<div className="animate-pulse">
  <div className="h-48 bg-gradient-to-r from-gray-200 via-gray-100 to-gray-200 
    bg-[length:200%_100%] animate-shimmer rounded-xl" />
</div>
```

---

## Mobile UX Rules

### Thumb Zone

```
+---------------------+
|  Hard to reach      |  <- DON'T put key actions here
+---------------------+
|  Easy reach         |  <- Main content
+---------------------+
|  Natural zone       |  <- CTA buttons, navigation
+---------------------+
```

### Element Sizes
- **Tap targets:** minimum 44x44px
- **Spacing between buttons:** minimum 8px
- **Text:** minimum 16px (never below 14px)

---

## Visual Techniques

### Gradients instead of flat colors
```tsx
<div className="bg-gradient-to-b from-white via-gray-50 to-gray-100" />

// Gradient text
<h1 className="bg-gradient-to-r from-primary to-secondary bg-clip-text text-transparent">
  Headline
</h1>
```

### Glassmorphism (iOS feel)
```tsx
<div className="bg-white/70 backdrop-blur-lg border border-white/20 rounded-2xl shadow-lg">
  {/* Content */}
</div>
```

### Soft Shadows
```tsx
// Instead of shadow-md use custom soft shadows
<div className="shadow-[0_8px_30px_rgba(0,0,0,0.08)]" />
```

---

## "Is This Cool?" Checklist

### First Impression
- [ ] First screen triggers "wow" (not just text + image)
- [ ] There's motion (entrance animations, parallax)
- [ ] Colors aren't boring (not just #fff + #000)

### Interactivity
- [ ] All buttons respond to touch (scale, ripple, color change)
- [ ] Menu is animated, not abrupt
- [ ] Forms are pleasant to fill (autofocus, inline validation)

### Details
- [ ] Skeleton loaders during loading
- [ ] Icons animated or with character
- [ ] No default system elements (select, checkbox)

### Overall Feel
- [ ] Makes you want to scroll and explore
- [ ] Feels "polished"
- [ ] Site doesn't look like a template

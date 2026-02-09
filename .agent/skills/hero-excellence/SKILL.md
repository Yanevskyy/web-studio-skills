---
name: hero-excellence
description: "Skill for creating Hero sections with 'quiet delight'. Patterns, animations, checklists. Use when creating or auditing the main hero section."
---

# Hero Excellence

## Philosophy

> **"Quiet delight"** — when the user thinks "wow" but doesn't understand why.

The Hero section is the first impression. It must:
- Capture attention within 3 seconds
- Convey the brand essence
- Guide toward action
- NOT distract from content

---

## Hero Quality Checklist

### Content
- [ ] Headline ≤ 6 words (ideal: 3-4)
- [ ] Subheadline ≤ 20 words
- [ ] One main CTA (two maximum)
- [ ] CTA visible without scrolling on mobile

### Visual
- [ ] Text contrast ≥ 4.5:1 (WCAG AA)
- [ ] Image optimized (WebP, ≤ 200KB)
- [ ] Image focal point not covered by text
- [ ] Gradient overlay for readability

### Performance
- [ ] LCP ≤ 2.5s (Largest Contentful Paint)
- [ ] Hero image with `priority` loading
- [ ] Fonts preloaded

### Responsiveness
- [ ] Works at 320px width
- [ ] Image changes for mobile (art direction)
- [ ] CTA large enough for tap (min 44x44px)

---

## Hero Section Patterns

### 1. Split Layout
Text left, image right. Classic.

```jsx
<section className="min-h-screen grid grid-cols-1 lg:grid-cols-2">
  {/* Content */}
  <div className="flex flex-col justify-center px-8 lg:px-16 py-20">
    <p className="text-sm uppercase tracking-widest text-muted mb-4">
      Subtitle
    </p>
    <h1 className="text-5xl lg:text-7xl font-bold mb-6">
      Main Headline
    </h1>
    <p className="text-lg text-muted mb-8 max-w-md">
      Description in 1-2 sentences.
    </p>
    <Button>Call to Action</Button>
  </div>
  
  {/* Image */}
  <div className="relative h-[50vh] lg:h-screen">
    <img 
      src="/hero.webp" 
      alt="Hero" 
      className="absolute inset-0 w-full h-full object-cover"
    />
  </div>
</section>
```

**When to use:** Corporate sites, SaaS, agencies.

---

### 2. Full-Screen Image + Overlay
Full-screen image with gradient for text readability.

```jsx
<section className="relative min-h-screen flex items-center">
  <img
    src="/hero.webp"
    alt="Hero"
    className="absolute inset-0 w-full h-full object-cover"
  />
  <div 
    className="absolute inset-0"
    style={{
      background: `linear-gradient(
        135deg,
        rgba(0, 0, 0, 0.7) 0%,
        rgba(0, 0, 0, 0.3) 50%,
        transparent 100%
      )`
    }}
  />
  <div className="container relative z-10 text-white">
    <h1 className="text-6xl font-bold mb-6">Headline</h1>
    <p className="text-xl mb-8 max-w-xl">Description</p>
    <Button variant="outline">Action</Button>
  </div>
</section>
```

**When to use:** Restaurants, hotels, luxury brands.

---

### 3. Parallax Layers
Multi-layer parallax for depth.

```jsx
const [scrollY, setScrollY] = useState(0);

useEffect(() => {
  const handleScroll = () => setScrollY(window.scrollY);
  window.addEventListener('scroll', handleScroll, { passive: true });
  return () => window.removeEventListener('scroll', handleScroll);
}, []);

<section className="relative min-h-screen overflow-hidden">
  <div 
    className="absolute inset-0"
    style={{ transform: `translateY(${scrollY * 0.15}px)` }}
  >
    <img src="/bg.webp" className="w-full h-full object-cover" />
  </div>
  <div 
    className="absolute inset-0"
    style={{
      background: `linear-gradient(
        135deg,
        rgba(250, 248, 245, ${0.85 + scrollY * 0.001}) 0%,
        transparent 100%
      )`
    }}
  />
  <div 
    className="relative z-10 container py-32"
    style={{ transform: `translateY(${scrollY * 0.05}px)` }}
  >
    <h1>Headline</h1>
  </div>
</section>
```

**When to use:** Premium brands, creative sites.

---

### 4. Staged Entrance
Elements appear sequentially.

```css
.reveal { opacity: 0; transform: translateY(20px); }
.reveal.visible { animation: fadeUp 0.8s ease-out forwards; }
@keyframes fadeUp { to { opacity: 1; transform: translateY(0); } }
```

```jsx
<section>
  <p className="reveal" style={{ animationDelay: '0s' }}>Subtitle</p>
  <h1 className="reveal" style={{ animationDelay: '0.1s' }}>Main</h1>
  <p className="reveal" style={{ animationDelay: '0.2s' }}>Description</p>
  <Button className="reveal" style={{ animationDelay: '0.3s' }}>CTA</Button>
</section>
```

**Settings:** Delay: 0.1s, Duration: 0.6-0.8s, Easing: ease-out

---

### 5. Centered Minimal
Maximum minimalism, essence only.

```jsx
<section className="min-h-screen flex items-center justify-center text-center px-4">
  <div className="max-w-3xl">
    <h1 className="text-6xl md:text-8xl font-bold mb-6">One Word</h1>
    <p className="text-xl text-muted mb-10">Short description in one line.</p>
    <Button size="lg">Action</Button>
  </div>
</section>
```

**When to use:** Landing pages, announcements, minimalist brands.

---

## "Quiet" Effects

### Principles
1. **No abrupt movements** — everything smooth
2. **Micro-amplitude** — movements 2-10px max
3. **Long duration** — 0.6s minimum
4. **Proper easing** — ease-out or cubic-bezier

### Floating Elements
```css
@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  25% { transform: translateY(-8px) rotate(2deg); }
  75% { transform: translateY(-10px) rotate(1deg); }
}
.floating { animation: float 8s ease-in-out infinite; }
```

### Reveal on Scroll
```jsx
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) entry.target.classList.add('visible');
      });
    },
    { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
  );
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  return () => observer.disconnect();
}, []);
```

---

## Anti-Patterns

| Anti-pattern | Why it's bad | Alternative |
|--------------|-------------|-------------|
| **Sliders/carousels** | -20% conversion, ignored | One strong image |
| **Auto-play video with sound** | Annoying, users leave | Video muted or on click |
| **Too much text** | Nobody reads it | Headline ≤ 6 words |
| **Multiple CTAs** | Choice paralysis | One main CTA |
| **Stock photos** | Distrust | Real photos or illustrations |
| **Abrupt animations** | Looks cheap | Smooth, 0.6s+ |
| **Low contrast** | Unreadable | Overlay or shadow |

---

## Hero Audit Template

```markdown
## Hero Audit for [Project Name]

### Content
- [ ] Headline: _____ words (target: ≤ 6)
- [ ] Subheadline: _____ words (target: ≤ 20)
- [ ] CTA count: _____ (target: 1-2)

### Visual
- [ ] Image format: _____
- [ ] Image size: _____ KB
- [ ] Contrast ratio: _____

### Performance
- [ ] LCP: _____ s

### Issues found:
1. 
2. 

### Recommendations:
1. 
2. 
```

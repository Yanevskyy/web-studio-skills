---
name: design-system
description: "Use when creating a new project or refactoring an existing one. Sets design tokens for Tailwind: colors, fonts, spacing. Ensures design consistency."
---

# Design System for Tailwind CSS

## When to use

**AT THE START OF EVERY PROJECT** — set up design tokens before building components. This prevents inconsistent design.

---

## tailwind.config.js Structure

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      // 1. COLORS
      colors: {
        // Brand colors (name by purpose, not shade)
        primary: {
          DEFAULT: '#8B7355',
          light: '#A68B6A',
          dark: '#6B5A45',
        },
        secondary: {
          DEFAULT: '#2C3E50',
          light: '#34495E',
          dark: '#1A252F',
        },
        // Neutrals
        background: '#FFFBF5',
        surface: '#F5F0E8',
        border: '#E5DDD0',
        // Text
        text: {
          primary: '#2C3E50',
          secondary: '#6B7280',
          muted: '#9CA3AF',
        },
        // Status
        success: '#22C55E',
        warning: '#F59E0B',
        error: '#EF4444',
      },

      // 2. TYPOGRAPHY
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Playfair Display', 'Georgia', 'serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        // Scale 1.25 (Major Third)
        xs: ['0.64rem', { lineHeight: '1rem' }],
        sm: ['0.8rem', { lineHeight: '1.25rem' }],
        base: ['1rem', { lineHeight: '1.5rem' }],
        lg: ['1.25rem', { lineHeight: '1.75rem' }],
        xl: ['1.563rem', { lineHeight: '2rem' }],
        '2xl': ['1.953rem', { lineHeight: '2.25rem' }],
        '3xl': ['2.441rem', { lineHeight: '2.5rem' }],
        '4xl': ['3.052rem', { lineHeight: '3rem' }],
        '5xl': ['3.815rem', { lineHeight: '1' }],
      },

      // 3. SPACING (8px grid)
      spacing: {
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },

      // 4. BORDER RADIUS
      borderRadius: {
        DEFAULT: '0.5rem',
        lg: '1rem',
        xl: '1.5rem',
        '2xl': '2rem',
      },

      // 5. SHADOWS
      boxShadow: {
        soft: '0 2px 15px -3px rgba(0, 0, 0, 0.07)',
        medium: '0 4px 25px -5px rgba(0, 0, 0, 0.1)',
        hard: '0 10px 40px -10px rgba(0, 0, 0, 0.15)',
      },

      // 6. ANIMATIONS
      animation: {
        'fade-in': 'fadeIn 0.5s ease-out',
        'fade-up': 'fadeUp 0.5s ease-out',
        'slide-in': 'slideIn 0.3s ease-out',
      },
      keyframes: {
        fadeIn: {
          '0%': { opacity: '0' },
          '100%': { opacity: '1' },
        },
        fadeUp: {
          '0%': { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
        slideIn: {
          '0%': { transform: 'translateX(-100%)' },
          '100%': { transform: 'translateX(0)' },
        },
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}
```

---

## CSS Variables for Theming

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Light theme */
    --color-background: 255 251 245;
    --color-surface: 245 240 232;
    --color-text-primary: 44 62 80;
    --color-primary: 139 115 85;
  }

  .dark {
    /* Dark theme */
    --color-background: 26 32 44;
    --color-surface: 45 55 72;
    --color-text-primary: 237 242 247;
    --color-primary: 166 139 106;
  }
}
```

```js
// tailwind.config.js — using CSS variables
colors: {
  background: 'rgb(var(--color-background) / <alpha-value>)',
  surface: 'rgb(var(--color-surface) / <alpha-value>)',
  'text-primary': 'rgb(var(--color-text-primary) / <alpha-value>)',
  primary: 'rgb(var(--color-primary) / <alpha-value>)',
}
```

---

## Consistency Rules

### Colors
- [ ] Use only config colors (no hardcoded `#123456` in components)
- [ ] Name by purpose: `primary`, `background`, not `brown`, `cream`
- [ ] Check contrast: text on background must be readable (4.5:1 minimum)

### Typography
- [ ] Use only sizes from `fontSize`
- [ ] Headings: `font-serif`, body: `font-sans`
- [ ] No more than 2-3 font sizes per page

### Spacing
- [ ] Use 8px grid: `p-2` (8px), `p-4` (16px), `p-8` (32px)
- [ ] Between sections: `py-16` or `py-24`
- [ ] Inside cards: `p-6` or `p-8`

### Components
- [ ] Buttons: same padding, border-radius, hover effects
- [ ] Cards: same shadows, spacing
- [ ] Forms: same input styles

---

## New Project Checklist

1. [ ] Define brand colors (get from designer/client)
2. [ ] Choose fonts (Google Fonts)
3. [ ] Configure `tailwind.config.js`
4. [ ] Create base components: Button, Card, Input
5. [ ] Document tokens (or show client in Storybook)

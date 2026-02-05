---
name: design-system
description: "Используй при создании нового проекта или рефакторинге существующего. Устанавливает дизайн-токены для Tailwind: цвета, шрифты, отступы. Гарантирует консистентность дизайна."
---

# Design System для Tailwind CSS

## Когда использовать

**В НАЧАЛЕ КАЖДОГО ПРОЕКТА** — настрой дизайн-токены до написания компонентов. Это предотвращает "плывущий" дизайн.

---

## Структура tailwind.config.js

```js
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      // 1. ЦВЕТА
      colors: {
        // Бренд-цвета (именуйте по назначению, не по оттенку)
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
        // Нейтральные
        background: '#FFFBF5',
        surface: '#F5F0E8',
        border: '#E5DDD0',
        // Текст
        text: {
          primary: '#2C3E50',
          secondary: '#6B7280',
          muted: '#9CA3AF',
        },
        // Статусы
        success: '#22C55E',
        warning: '#F59E0B',
        error: '#EF4444',
      },

      // 2. ТИПОГРАФИКА
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        serif: ['Playfair Display', 'Georgia', 'serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        // Масштаб 1.25 (Major Third)
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

      // 3. ОТСТУПЫ (8px сетка)
      spacing: {
        // Используйте стандартные + кастомные
        '18': '4.5rem',
        '88': '22rem',
        '128': '32rem',
      },

      // 4. СКРУГЛЕНИЯ
      borderRadius: {
        DEFAULT: '0.5rem',
        lg: '1rem',
        xl: '1.5rem',
        '2xl': '2rem',
      },

      // 5. ТЕНИ
      boxShadow: {
        soft: '0 2px 15px -3px rgba(0, 0, 0, 0.07)',
        medium: '0 4px 25px -5px rgba(0, 0, 0, 0.1)',
        hard: '0 10px 40px -10px rgba(0, 0, 0, 0.15)',
      },

      // 6. АНИМАЦИИ
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

## CSS Variables для темизации

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    /* Светлая тема */
    --color-background: 255 251 245;
    --color-surface: 245 240 232;
    --color-text-primary: 44 62 80;
    --color-primary: 139 115 85;
  }

  .dark {
    /* Тёмная тема */
    --color-background: 26 32 44;
    --color-surface: 45 55 72;
    --color-text-primary: 237 242 247;
    --color-primary: 166 139 106;
  }
}
```

```js
// tailwind.config.js — использование CSS variables
colors: {
  background: 'rgb(var(--color-background) / <alpha-value>)',
  surface: 'rgb(var(--color-surface) / <alpha-value>)',
  'text-primary': 'rgb(var(--color-text-primary) / <alpha-value>)',
  primary: 'rgb(var(--color-primary) / <alpha-value>)',
}
```

---

## Правила консистентности

### Цвета
- [ ] Используй только цвета из конфига (никаких `#123456` в компонентах)
- [ ] Именуй по назначению: `primary`, `background`, не `brown`, `cream`
- [ ] Проверяй контраст: текст на фоне должен быть читаем (4.5:1 минимум)

### Типографика
- [ ] Используй только размеры из `fontSize`
- [ ] Заголовки: `font-serif`, текст: `font-sans`
- [ ] Не больше 2-3 размеров шрифта на странице

### Отступы
- [ ] Используй 8px сетку: `p-2` (8px), `p-4` (16px), `p-8` (32px)
- [ ] Между секциями: `py-16` или `py-24`
- [ ] Внутри карточек: `p-6` или `p-8`

### Компоненты
- [ ] Кнопки: одинаковые паддинги, скругления, hover-эффекты
- [ ] Карточки: одинаковые тени, отступы
- [ ] Формы: одинаковые стили инпутов

---

## Чеклист нового проекта

1. [ ] Определи бренд-цвета (получи от дизайнера/клиента)
2. [ ] Выбери шрифты (Google Fonts)
3. [ ] Настрой `tailwind.config.js`
4. [ ] Создай базовые компоненты: Button, Card, Input
5. [ ] Задокументируй токены (или покажи клиенту в Storybook)

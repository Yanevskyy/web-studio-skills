---
name: mobile-ux-excellence
description: "Используй для проверки мобильного дизайна. Анти-шаблоны, UX удобство, микро-анимации, wow-эффекты. Гарантирует, что мобильная версия выглядит круто."
---

# Mobile UX Excellence

## Когда использовать

**ПЕРЕД ДЕПЛОЕМ** — проверь, что мобильная версия не скучная и действительно впечатляет.

---

## ❌ Анти-шаблоны (НЕ делай так)

### Навигация
- ❌ Стандартный бургер-меню без анимации
- ❌ Меню открывается резко, без transition
- ❌ Мелкие tap-таргеты (< 44px)
- ❌ Навигация занимает весь экран банально

### Карточки
- ❌ Одинаковые прямоугольные карточки в ряд
- ❌ Нет hover/tap состояний
- ❌ Статичные изображения без эффектов
- ❌ Скучные тени (shadow-md везде)

### Типографика
- ❌ Одинаковый размер текста везде
- ❌ Нет визуальной иерархии
- ❌ Заголовки без характера

### Общее
- ❌ Белый фон везде без акцентов
- ❌ Нет микро-анимаций
- ❌ Загрузка без skeleton/placeholder
- ❌ Кнопки выглядят как из Bootstrap

---

## ✅ Wow-паттерны

### 1. Навигация с характером

```tsx
// Animated mobile menu
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

### 2. Карточки с глубиной

```tsx
// Card with hover lift and glow
<div className="
  group relative
  bg-white rounded-2xl p-6
  transition-all duration-300 ease-out
  hover:translate-y-[-4px]
  hover:shadow-[0_20px_40px_-15px_rgba(0,0,0,0.2)]
">
  {/* Subtle gradient border on hover */}
  <div className="
    absolute inset-0 rounded-2xl opacity-0
    bg-gradient-to-r from-primary/20 to-secondary/20
    transition-opacity duration-300
    group-hover:opacity-100
    -z-10 blur-xl
  " />
  
  {/* Content */}
  <h3 className="text-xl font-semibold">{title}</h3>
</div>
```

### 3. Изображения с эффектом

```tsx
// Image with subtle zoom on scroll (using framer-motion)
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
      <motion.img
        src={src}
        alt={alt}
        style={{ scale }}
        className="w-full h-full object-cover"
      />
    </div>
  )
}
```

### 4. Кнопки с жизнью

```tsx
// Button with ripple effect
<button className="
  relative overflow-hidden
  bg-primary text-white
  px-8 py-4 rounded-full
  font-semibold
  transition-all duration-300
  active:scale-95
  hover:shadow-lg hover:shadow-primary/30
">
  <span className="relative z-10">Заказать</span>
  {/* Shine effect */}
  <div className="
    absolute inset-0 -translate-x-full
    bg-gradient-to-r from-transparent via-white/20 to-transparent
    group-hover:animate-shine
  " />
</button>

// In tailwind.config.js
animation: {
  shine: 'shine 1.5s ease-in-out infinite',
},
keyframes: {
  shine: {
    '100%': { transform: 'translateX(100%)' },
  },
},
```

### 5. Skeleton loaders

```tsx
// Shimmer skeleton
<div className="animate-pulse">
  <div className="h-48 bg-gradient-to-r from-gray-200 via-gray-100 to-gray-200 
    bg-[length:200%_100%] animate-shimmer rounded-xl" />
</div>

// In tailwind.config.js
animation: {
  shimmer: 'shimmer 1.5s infinite',
},
keyframes: {
  shimmer: {
    '0%': { backgroundPosition: '-200% 0' },
    '100%': { backgroundPosition: '200% 0' },
  },
},
```

### 6. Scroll-triggered animations

```tsx
// Fade up on scroll (CSS only)
.fade-up {
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.6s ease-out;
}

.fade-up.visible {
  opacity: 1;
  transform: translateY(0);
}

// With Intersection Observer
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible')
        }
      })
    },
    { threshold: 0.1 }
  )
  
  document.querySelectorAll('.fade-up').forEach(el => observer.observe(el))
}, [])
```

---

## 📐 Mobile UX правила

### Thumb Zone (зона большого пальца)

```
┌─────────────────────┐
│   ⚠️ Hard to reach  │  <- Важные действия НЕ здесь
├─────────────────────┤
│   ✅ Easy reach     │  <- Основной контент
├─────────────────────┤
│   ✅ Natural zone   │  <- CTA кнопки, навигация
└─────────────────────┘
```

### Размеры элементов
- **Tap targets:** минимум 44×44px
- **Spacing между кнопками:** минимум 8px
- **Текст:** минимум 16px (никогда меньше 14px)

### Жесты
- **Swipe to dismiss** для модалов
- **Pull to refresh** где уместно
- **Long press** для контекстных действий

---

## 🎨 Визуальные приёмы

### Градиенты вместо плоских цветов
```tsx
// Subtle gradient background
<div className="bg-gradient-to-b from-white via-gray-50 to-gray-100" />

// Gradient text
<h1 className="
  bg-gradient-to-r from-primary to-secondary
  bg-clip-text text-transparent
">
  Заголовок
</h1>
```

### Glassmorphism (для iOS-feel)
```tsx
<div className="
  bg-white/70 backdrop-blur-lg
  border border-white/20
  rounded-2xl shadow-lg
">
  {/* Content */}
</div>
```

### Soft shadows
```tsx
// Вместо shadow-md используй кастомные мягкие тени
<div className="shadow-[0_8px_30px_rgba(0,0,0,0.08)]" />
```

---

## ✅ Чеклист "Это круто?"

### Первое впечатление
- [ ] Первый экран вызывает "вау" (не просто текст + картинка)
- [ ] Есть движение (анимации появления, параллакс)
- [ ] Цвета не скучные (не просто #fff + #000)

### Интерактивность
- [ ] Все кнопки реагируют на touch (scale, ripple, color change)
- [ ] Меню анимировано, не резкое
- [ ] Формы приятно заполнять (автофокус, валидация inline)

### Детали
- [ ] Skeleton loaders при загрузке
- [ ] Иконки анимированы или с характером
- [ ] Нет стандартных системных элементов (select, checkbox)

### Общее ощущение
- [ ] Хочется скроллить и изучать
- [ ] Чувствуется "полировка"
- [ ] Сайт не похож на шаблон

---

## Финальный вопрос

Перед деплоем спроси себя:

> **"Если бы я увидел этот мобильный сайт впервые — я бы сказал 'круто' или 'ну ок'?"**

Если "ну ок" — возвращайся и добавляй wow-элементы.

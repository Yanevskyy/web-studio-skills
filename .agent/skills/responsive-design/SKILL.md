---
name: responsive-design
description: "Используй при создании адаптивных интерфейсов. Breakpoints, mobile-first, паттерны для Tailwind CSS."
---

# Responsive Design для Tailwind CSS

## Когда использовать

**ПРИ СОЗДАНИИ ЛЮБОЙ СТРАНИЦЫ** — mobile-first подход.

---

## Breakpoints Tailwind

| Префикс | Минимум | Устройства |
|---------|---------|------------|
| (default) | 0px | Мобильные |
| `sm:` | 640px | Большие телефоны |
| `md:` | 768px | Планшеты |
| `lg:` | 1024px | Ноутбуки |
| `xl:` | 1280px | Десктопы |
| `2xl:` | 1536px | Большие мониторы |

---

## Mobile-First подход

```tsx
// ❌ Неправильно (desktop-first)
<div className="text-lg md:text-base sm:text-sm">

// ✅ Правильно (mobile-first)
<div className="text-sm md:text-base lg:text-lg">
```

**Правило:** Начинай с мобильной версии, добавляй стили для больших экранов.

---

## Паттерны

### 1. Контейнер с отступами

```tsx
// Стандартный контейнер
<div className="container mx-auto px-4 sm:px-6 lg:px-8">
  {/* Контент */}
</div>

// Или с max-width
<div className="w-full max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
  {/* Контент */}
</div>
```

### 2. Адаптивная сетка

```tsx
// 1 → 2 → 3 → 4 колонки
<div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-6">
  {items.map(item => <Card key={item.id} {...item} />)}
</div>
```

### 3. Flexbox с переносом

```tsx
// Колонка на мобильном → ряд на десктопе
<div className="flex flex-col md:flex-row gap-4 md:gap-8">
  <div className="w-full md:w-1/2">Левая часть</div>
  <div className="w-full md:w-1/2">Правая часть</div>
</div>
```

### 4. Скрытие элементов

```tsx
// Только на мобильном
<div className="md:hidden">Мобильное меню</div>

// Только на десктопе
<div className="hidden md:block">Десктопное меню</div>
```

### 5. Адаптивная типографика

```tsx
// Заголовок
<h1 className="text-2xl sm:text-3xl md:text-4xl lg:text-5xl font-bold">
  Заголовок
</h1>

// Параграф
<p className="text-sm sm:text-base lg:text-lg leading-relaxed">
  Текст
</p>
```

### 6. Адаптивные отступы

```tsx
// Секция
<section className="py-12 sm:py-16 lg:py-24">
  {/* Контент */}
</section>

// Карточка
<div className="p-4 sm:p-6 lg:p-8">
  {/* Контент */}
</div>
```

### 7. Адаптивные изображения

```tsx
import Image from 'next/image'

// Разные размеры для разных экранов
<Image
  src="/hero.jpg"
  alt="Hero"
  fill
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  className="object-cover"
/>
```

### 8. Навигация

```tsx
// Mobile: бургер, Desktop: горизонтальное меню
<nav className="flex items-center justify-between">
  <Logo />
  
  {/* Мобильное меню */}
  <button className="md:hidden">
    <MenuIcon />
  </button>
  
  {/* Десктопное меню */}
  <ul className="hidden md:flex gap-6">
    <li><Link href="/">Home</Link></li>
    <li><Link href="/about">About</Link></li>
  </ul>
</nav>
```

---

## Тестирование

### Chrome DevTools:
1. F12 → Toggle device toolbar
2. Проверь все breakpoints: 320px, 640px, 768px, 1024px, 1280px

### Реальные устройства:
- iPhone SE (375px)
- iPhone 14 (390px)
- iPad (768px)
- MacBook (1440px)

---

## Чеклист

- [ ] Mobile-first подход
- [ ] Все breakpoints проверены
- [ ] Навигация работает на мобильном
- [ ] Изображения адаптивные
- [ ] Текст читаем на всех экранах
- [ ] Кнопки достаточно большие для touch (min 44px)
- [ ] Нет горизонтального скролла

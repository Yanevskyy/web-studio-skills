---
name: accessibility
description: "Используй для проверки доступности. WCAG чеклист: контраст, ARIA, навигация с клавиатуры для React/Next.js."
---

# Web Accessibility (a11y)

## Когда использовать

**ПРИ СОЗДАНИИ ЛЮБОГО ИНТЕРФЕЙСА** — доступность не опциональна.

---

## Почему важно

- 15% населения имеют инвалидность
- SEO-бонус (Google учитывает доступность)
- Требование закона в ЕС и США
- Улучшает UX для всех

---

## Чеклист WCAG 2.1

### 1. Контраст текста

| Уровень | Соотношение |
|---------|-------------|
| AA (стандарт) | 4.5:1 для текста, 3:1 для заголовков |
| AAA (идеал) | 7:1 для текста, 4.5:1 для заголовков |

**Инструменты:**
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/)

```tsx
// ❌ Плохо
<p className="text-gray-400 bg-gray-200">Низкий контраст</p>

// ✅ Хорошо
<p className="text-gray-900 bg-white">Высокий контраст</p>
```

---

### 2. Альтернативный текст

```tsx
// ❌ Плохо
<img src="photo.jpg" />
<img src="photo.jpg" alt="image" />

// ✅ Хорошо (информативные изображения)
<img src="team.jpg" alt="Команда компании на встрече в офисе" />

// ✅ Хорошо (декоративные изображения)
<img src="decoration.jpg" alt="" role="presentation" />
```

---

### 3. Семантический HTML

```tsx
// ❌ Плохо
<div onClick={handleClick}>Кнопка</div>
<div className="header">Header</div>
<div className="nav">Navigation</div>

// ✅ Хорошо
<button onClick={handleClick}>Кнопка</button>
<header>Header</header>
<nav>Navigation</nav>
<main>Main content</main>
<footer>Footer</footer>
```

---

### 4. Заголовки

```tsx
// ❌ Плохо (пропущен h2)
<h1>Заголовок</h1>
<h3>Подзаголовок</h3>

// ✅ Хорошо
<h1>Заголовок страницы</h1>
<h2>Секция</h2>
<h3>Подсекция</h3>
```

---

### 5. Ссылки и кнопки

```tsx
// ❌ Плохо
<a href="/page">Кликните здесь</a>
<button>X</button>

// ✅ Хорошо
<a href="/products">Смотреть все товары</a>
<button aria-label="Закрыть модальное окно">
  <XIcon />
</button>
```

---

### 6. Формы

```tsx
// ❌ Плохо
<input type="email" placeholder="Email" />

// ✅ Хорошо
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

### 7. Навигация с клавиатуры

```tsx
// Фокус виден
<button className="focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2">
  Кнопка
</button>

// Skip link
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4"
>
  Перейти к основному контенту
</a>

<main id="main-content">
  ...
</main>
```

---

### 8. ARIA атрибуты

```tsx
// Модальное окно
<div
  role="dialog"
  aria-modal="true"
  aria-labelledby="modal-title"
>
  <h2 id="modal-title">Заголовок модала</h2>
  ...
</div>

// Выпадающее меню
<button
  aria-expanded={isOpen}
  aria-haspopup="menu"
>
  Меню
</button>
<ul role="menu" hidden={!isOpen}>
  <li role="menuitem">Пункт 1</li>
</ul>

// Загрузка
<button disabled={isLoading}>
  {isLoading ? (
    <span aria-live="polite">Загрузка...</span>
  ) : (
    'Отправить'
  )}
</button>
```

---

### 9. Tailwind utilities

```tsx
// Скрыто визуально, доступно для screen readers
<span className="sr-only">Описание для screen reader</span>

// Фокус стили
<button className="
  focus:outline-none
  focus:ring-2
  focus:ring-offset-2
  focus:ring-primary
">
```

---

## Тестирование

### Инструменты:
- **axe DevTools** — Chrome extension
- **WAVE** — [wave.webaim.org](https://wave.webaim.org)
- **Lighthouse** — Accessibility audit
- **NVDA/VoiceOver** — Screen readers

### Ручное тестирование:
1. [ ] Пройди весь сайт только клавиатурой (Tab, Enter, Escape)
2. [ ] Проверь с VoiceOver (Mac) или NVDA (Windows)
3. [ ] Увеличь масштаб до 200% — ничего не должно ломаться

---

## Чеклист

- [ ] Контраст текста минимум 4.5:1
- [ ] Все изображения с alt
- [ ] Семантический HTML (header, nav, main, footer)
- [ ] Заголовки в правильном порядке
- [ ] Формы с label
- [ ] Кнопки/ссылки с понятным текстом
- [ ] Фокус виден при навигации Tab
- [ ] Skip link для навигации
- [ ] Модалы с правильными ARIA
- [ ] Lighthouse Accessibility > 90

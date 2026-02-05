---
name: hero-excellence
description: "Скилл для создания Hero секций с 'тихим восторгом'. Паттерны, анимации, чеклисты. Используй при создании или аудите главной секции."
---

# Hero Excellence

## Философия

> **"Тихий восторг"** — когда пользователь думает "вау", но не понимает почему.

Hero секция — это первое впечатление. Она должна:
- Захватить внимание за 3 секунды
- Передать суть бренда
- Направить к действию
- НЕ отвлекать от контента

---

## Чеклист качества Hero

### Контент
- [ ] Заголовок ≤ 6 слов (идеально 3-4)
- [ ] Подзаголовок ≤ 20 слов
- [ ] Один главный CTA (максимум два)
- [ ] CTA виден без скролла на мобильном

### Визуал
- [ ] Контраст текста ≥ 4.5:1 (WCAG AA)
- [ ] Изображение оптимизировано (WebP, ≤ 200KB)
- [ ] Фокус изображения не перекрывается текстом
- [ ] Gradient overlay для читаемости

### Производительность
- [ ] LCP ≤ 2.5s (Largest Contentful Paint)
- [ ] Hero изображение с `priority` loading
- [ ] Шрифты предзагружены

### Адаптивность
- [ ] Работает на 320px ширины
- [ ] Изображение меняется для мобильных (art direction)
- [ ] CTA достаточно большой для тапа (min 44x44px)

---

## Паттерны Hero секций

### 1. Split Layout
Текст слева, изображение справа. Классика.

```jsx
<section className="min-h-screen grid grid-cols-1 lg:grid-cols-2">
  {/* Content */}
  <div className="flex flex-col justify-center px-8 lg:px-16 py-20">
    <p className="text-sm uppercase tracking-widest text-muted mb-4">
      Подзаголовок
    </p>
    <h1 className="text-5xl lg:text-7xl font-bold mb-6">
      Главный заголовок
    </h1>
    <p className="text-lg text-muted mb-8 max-w-md">
      Описание в 1-2 предложения.
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

**Когда использовать:** Корпоративные сайты, SaaS, агентства.

---

### 2. Full-Screen Image + Overlay
Изображение на весь экран с градиентом для текста.

```jsx
<section className="relative min-h-screen flex items-center">
  {/* Background Image */}
  <img
    src="/hero.webp"
    alt="Hero"
    className="absolute inset-0 w-full h-full object-cover"
  />
  
  {/* Gradient Overlay */}
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
  
  {/* Content */}
  <div className="container relative z-10 text-white">
    <h1 className="text-6xl font-bold mb-6">Заголовок</h1>
    <p className="text-xl mb-8 max-w-xl">Описание</p>
    <Button variant="outline">Действие</Button>
  </div>
</section>
```

**Когда использовать:** Рестораны, отели, люксовые бренды.

---

### 3. Parallax Layers (как Noble)
Многослойный parallax для глубины.

```jsx
const [scrollY, setScrollY] = useState(0);

useEffect(() => {
  const handleScroll = () => setScrollY(window.scrollY);
  window.addEventListener('scroll', handleScroll, { passive: true });
  return () => window.removeEventListener('scroll', handleScroll);
}, []);

<section className="relative min-h-screen overflow-hidden">
  {/* Layer 1: Background - moves slowest */}
  <div 
    className="absolute inset-0"
    style={{ transform: `translateY(${scrollY * 0.15}px)` }}
  >
    <img src="/bg.webp" className="w-full h-full object-cover" />
  </div>
  
  {/* Layer 2: Gradient overlay - shifts with scroll */}
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
  
  {/* Layer 3: Content - moves faster */}
  <div 
    className="relative z-10 container py-32"
    style={{ transform: `translateY(${scrollY * 0.05}px)` }}
  >
    <h1>Заголовок</h1>
  </div>
</section>
```

**Когда использовать:** Премиум бренды, креативные сайты.

---

### 4. Staged Entrance
Элементы появляются поочерёдно.

```jsx
// CSS
.reveal {
  opacity: 0;
  transform: translateY(20px);
}

.reveal.visible {
  animation: fadeUp 0.8s ease-out forwards;
}

@keyframes fadeUp {
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

// JSX
<section>
  <p className="reveal" style={{ animationDelay: '0s' }}>Подзаголовок</p>
  <h1 className="reveal" style={{ animationDelay: '0.1s' }}>Главный</h1>
  <p className="reveal" style={{ animationDelay: '0.2s' }}>Описание</p>
  <Button className="reveal" style={{ animationDelay: '0.3s' }}>CTA</Button>
</section>
```

**Настройки:**
- Delay между элементами: 0.1s
- Duration: 0.6-0.8s
- Easing: ease-out или cubic-bezier(0.16, 1, 0.3, 1)

---

### 5. Centered Minimal
Максимальный минимализм, только суть.

```jsx
<section className="min-h-screen flex items-center justify-center text-center px-4">
  <div className="max-w-3xl">
    <h1 className="text-6xl md:text-8xl font-bold mb-6">
      Одно слово
    </h1>
    <p className="text-xl text-muted mb-10">
      Короткое описание в одну строку.
    </p>
    <Button size="lg">Действие</Button>
  </div>
</section>
```

**Когда использовать:** Лендинги, анонсы, минималистичные бренды.

---

## "Тихие" эффекты

### Принципы
1. **Никаких резких движений** — всё плавно
2. **Микро-амплитуда** — движения 2-10px максимум
3. **Длинные duration** — 0.6s минимум
4. **Правильный easing** — ease-out или cubic-bezier

### Floating Elements
Лёгкое покачивание декоративных элементов.

```css
@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  25% { transform: translateY(-8px) rotate(2deg); }
  50% { transform: translateY(-4px) rotate(-1deg); }
  75% { transform: translateY(-10px) rotate(1deg); }
}

.floating {
  animation: float 8s ease-in-out infinite;
}
```

### Gradient Shift
Градиент плавно меняется при скролле.

```jsx
<div 
  style={{
    background: `linear-gradient(
      ${135 + scrollY * 0.1}deg,
      hsl(${30 + scrollY * 0.05}, 70%, 60%),
      hsl(${50 + scrollY * 0.05}, 80%, 70%)
    )`
  }}
/>
```

### Reveal on Scroll
Элементы появляются при скролле.

```jsx
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    },
    { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
  );
  
  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  return () => observer.disconnect();
}, []);
```

### Scroll Indicator
Тонкий индикатор скролла.

```jsx
<div className="absolute bottom-8 left-1/2 -translate-x-1/2">
  <div className="w-px h-12 bg-black/20 relative overflow-hidden">
    <div 
      className="absolute top-0 left-0 w-full h-1/3 bg-black/60"
      style={{ animation: 'scrollLine 2s ease-in-out infinite' }}
    />
  </div>
</div>

/* CSS */
@keyframes scrollLine {
  0% { transform: translateY(-100%); }
  50% { transform: translateY(0%); }
  100% { transform: translateY(300%); }
}
```

---

## Anti-Patterns ❌

### НЕ делай это в Hero:

| Anti-pattern | Почему плохо | Альтернатива |
|--------------|--------------|--------------|
| **Слайдеры/карусели** | -20% конверсия, игнорируются | Одно сильное изображение |
| **Авто-play видео со звуком** | Раздражает, уходят | Видео muted или по клику |
| **Много текста** | Никто не читает | ≤ 6 слов заголовок |
| **Несколько CTA** | Паралич выбора | Один главный CTA |
| **Стоковые фото** | Недоверие | Реальные фото или иллюстрации |
| **Резкие анимации** | Дешёвый вид | Плавные, 0.6s+ |
| **Низкий контраст** | Нечитаемо | Overlay или тень |

---

## По типу бизнеса

### E-commerce
- Продукт в центре внимания
- Цена видна
- CTA: "Купить" / "В каталог"
- Бейдж "Бестселлер" / "Новинка"

### Ресторан / Кафе
- Атмосферное фото (еда, интерьер)
- Тёплые тона
- CTA: "Забронировать" / "Меню"
- Часы работы видны

### Корпоративный / B2B
- Чистый, профессиональный
- Статистика или достижения
- CTA: "Связаться" / "Узнать больше"
- Trust badges

### Люксовый бренд
- Минимум элементов
- Много воздуха
- Мелкий, изящный шрифт
- CTA неброский

---

## Аудит существующего Hero

При анализе Hero задай вопросы:

1. **Понятно ли за 3 секунды, что это за сайт?**
2. **Есть ли чёткий следующий шаг (CTA)?**
3. **Загружается ли быстро (< 2.5s)?**
4. **Работает ли на мобильном?**
5. **Вызывает ли эмоцию?**

Если хотя бы один ответ "нет" — нужна переработка.

---

## Примеры для вдохновения

- **Apple** — минимализм, продукт как герой
- **Stripe** — градиенты, анимация, технологичность
- **Airbnb** — фото-центричный, эмоциональный
- **Linear** — тёмный, футуристичный, анимированный

---

## Готовый шаблон проверки

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

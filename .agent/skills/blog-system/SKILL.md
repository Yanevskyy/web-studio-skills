---
name: blog-system
description: "Скилл для создания production-ready блог-системы. Страницы статей, роутинг, кликабельные карточки, контент-стратегия, светлая навигация. Используй при добавлении блога/журнала на сайт."
---

# Blog System Excellence

## Философия

> **Блог — это не набор статей. Это голос бренда, который строит доверие и лояльность.**

Профессиональный блог должен:
- Выглядеть как продолжение основного сайта
- Иметь всю функциональность production-системы
- Легко масштабироваться для новых статей
- Соответствовать UX-стандартам премиум-сайтов

---

## Архитектура блог-системы

### Обязательные компоненты

```
src/
├── pages/
│   ├── Blog.tsx         # Список статей (карточки)
│   └── BlogPost.tsx     # Детальная страница статьи
├── App.tsx              # Роут /blog/:slug
└── components/
    └── Navigation.tsx   # Light mode для статей
```

### Структура данных статьи

```typescript
interface BlogArticle {
  slug: string;          // URL-friendly идентификатор
  title: string;         // Заголовок (≤ 12 слов)
  excerpt: string;       // Краткое описание (≤ 30 слов)
  image: string;         // Hero изображение
  date: string;          // Дата публикации
  category: string;      // Категория для фильтрации
  readTime: string;      // "5 min read"
  content: string[];     // Массив параграфов
}
```

---

## Чеклист реализации

### Страница списка (Blog.tsx)

- [ ] Featured post (главная статья) крупнее остальных
- [ ] Карточки статей кликабельны полностью
- [ ] Slug добавлен к каждой статье
- [ ] Link обёртка с hover-эффектами
- [ ] Категория и время чтения видны
- [ ] Кнопка "Read article" на featured post
- [ ] Newsletter CTA в конце страницы

### Страница статьи (BlogPost.tsx)

- [ ] Hero секция с изображением на 70vh
- [ ] Dark overlay для контраста с навигацией
- [ ] Мета-информация (дата, категория, время чтения)
- [ ] Контент с reveal-анимациями
- [ ] Кнопка "Back to Journal" (светлая на hero)
- [ ] CTA подписки после статьи
- [ ] Scroll to top при загрузке

### Навигация (Navigation.tsx)

- [ ] Light mode для страниц `/blog/:slug`
- [ ] Логотип белый на hero
- [ ] Меню белое на hero
- [ ] Плавный переход при скролле

### Роутинг (App.tsx)

- [ ] Импорт BlogPost компонента
- [ ] Route path="/blog/:slug"
- [ ] Размещение после /blog

---

## Паттерны реализации

### 1. Кликабельные карточки с Link

```tsx
// ❌ Неправильно — только заголовок кликабельный
<article>
  <img src={post.image} />
  <Link to={`/blog/${post.slug}`}>{post.title}</Link>
</article>

// ✅ Правильно — вся карточка кликабельная
<Link to={`/blog/${post.slug}`} className="group">
  <article>
    <img 
      src={post.image} 
      className="group-hover:scale-105 transition-transform" 
    />
    <h3 className="group-hover:text-brown transition-colors">
      {post.title}
    </h3>
  </article>
</Link>
```

### 2. Light Navigation для статей

```tsx
// Navigation.tsx
const isBlogPostPage = location.pathname.startsWith('/blog/');

const useLightColors = (
  isHomePage || 
  location.pathname === '/events' || 
  isBlogPostPage
) && !isScrolled;
```

### 3. Dark Overlay для Hero

```tsx
// BlogPost.tsx — Hero секция
<section className="min-h-[70vh] relative flex items-end">
  <div className="absolute inset-0">
    <img src={article.image} className="w-full h-full object-cover" />
    
    {/* Dark overlay для навигации */}
    <div 
      className="absolute inset-0"
      style={{
        background: `linear-gradient(
          135deg,
          rgba(0, 0, 0, 0.6) 0%,
          rgba(0, 0, 0, 0.4) 40%,
          rgba(0, 0, 0, 0.2) 100%
        )`
      }}
    />
    
    {/* Bottom gradient to page background */}
    <div className="absolute inset-0 bg-gradient-to-t from-cream via-cream/60 to-transparent" />
  </div>
  
  <div className="container relative z-10 pb-20 pt-40">
    {/* Content */}
  </div>
</section>
```

### 4. Reveal-анимации для контента

```tsx
// Intersection Observer паттерн
useEffect(() => {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-up');
          observer.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.1, rootMargin: '0px 0px -50px 0px' }
  );

  document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
  return () => observer.disconnect();
}, []);

// Применение с staggered delay
{article.content.map((paragraph, index) => (
  <p 
    key={index} 
    className="reveal opacity-0"
    style={{ animationDelay: `${index * 0.05}s` }}
  >
    {paragraph}
  </p>
))}
```

### 5. Back Button светлый

```tsx
<Link
  to="/blog"
  className="inline-flex items-center gap-2 text-white/80 hover:text-white transition-colors"
>
  <ArrowLeft size={16} /> Back to Journal
</Link>
```

---

## Контент-стратегия

### Структура статьи

1. **Hook** (первый параграф) — захватить внимание
2. **Context** — почему это важно
3. **Story/Content** — основное содержание
4. **Insight** — ключевой вывод
5. **Call to Action** — что делать дальше

### Длина контента

| Тип | Слов | Время чтения |
|-----|------|--------------|
| Короткая | 500-800 | 3-4 min |
| Средняя | 1000-1500 | 5-7 min |
| Длинная (flagship) | 2000-3000 | 8-12 min |

### Категории (примеры)

- **Our Story** — история бренда, основатели
- **Process** — производство, закулисье
- **Philosophy** — ценности, подход
- **Ingredients** — материалы, поставщики
- **News** — новости, анонсы

---

## Anti-Patterns ❌

| Anti-pattern | Почему плохо | Альтернатива |
|--------------|--------------|--------------|
| **Карточки без Link** | Не кликабельны | Обернуть в Link |
| **Только заголовок-ссылка** | Плохой UX | Вся карточка кликабельная |
| **Тёмный текст на тёмном фото** | Нечитаемо | Dark overlay |
| **Стандартная навигация на hero** | Сливается | Light mode |
| **Статья без CTA** | Потеря конверсии | Newsletter, related posts |
| **Слишком много категорий** | Путаница | 4-6 категорий максимум |
| **Даты в формате ISO** | Не читаемо | "January 2024" |

---

## SEO для блога

- [ ] Уникальный `<title>` для каждой статьи
- [ ] `<meta description>` из excerpt
- [ ] Open Graph теги
- [ ] Semantic HTML (`<article>`, `<time>`)
- [ ] Alt-текст для изображений
- [ ] Structured data (Article schema)

---

## Тестирование

### Функциональное

1. Открыть `/blog` — карточки кликабельны?
2. Кликнуть на статью — открывается `/blog/:slug`?
3. Навигация белая на hero?
4. "Back to Journal" работает?
5. Scroll to top при переходе?

### Визуальное

1. Контраст текста на hero достаточный?
2. Hover-эффекты на карточках?
3. Мобильная версия адаптивна?
4. Анимации плавные?

---

## Добавление новой статьи

```typescript
// Добавить в массив articles в BlogPost.tsx
{
  slug: 'new-article-slug',           // URL-friendly
  title: 'Article Title Here',        // ≤ 12 слов
  excerpt: 'Brief description...',    // ≤ 30 слов
  image: '/images/article-image.webp',
  date: 'February 2024',
  category: 'Category',
  readTime: '5 min read',
  content: [
    "First paragraph...",
    "Second paragraph...",
    // ...
  ]
}

// Добавить карточку в Blog.tsx (если не из shared data)
{
  slug: 'new-article-slug',
  title: 'Article Title Here',
  excerpt: 'Brief description...',
  image: '/images/article-image.webp',
  date: 'February 2024',
  category: 'Category',
  readTime: '5 min read',
}
```

---

## Шаблон аудита блога

```markdown
## Blog Audit for [Project Name]

### Pages Check
- [ ] Blog listing page exists
- [ ] Blog post page exists
- [ ] Route /blog/:slug configured

### Functionality
- [ ] Cards clickable: _____
- [ ] Navigation light mode: _____
- [ ] Back button works: _____
- [ ] Scroll to top: _____

### Visual
- [ ] Hero overlay contrast: _____
- [ ] Hover effects: _____
- [ ] Mobile responsive: _____

### Content
- [ ] Article count: _____
- [ ] Categories: _____
- [ ] CTA presence: _____

### Issues found:
1. 
2. 

### Recommendations:
1. 
2. 
```

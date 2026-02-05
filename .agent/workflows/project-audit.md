---
description: Полный аудит проекта по всем скиллам студии
---

# Project Audit Workflow

> Комплексная проверка проекта по всем 15 скиллам

## Подготовка

1. Изучи структуру проекта (package.json, src/, public/)
2. Определи тип проекта (корпоративный сайт / магазин)

## Аудит по скиллам

### Дизайн

3. **design-system** — tailwind.config.js, консистентность токенов
4. **responsive-design** — breakpoints, mobile-first
5. **accessibility** — контраст, alt-теги, семантика
6. **mobile-ux-excellence** — wow-эффекты, thumb zone

### SEO

7. **seo-technical** — meta-теги, OG, schema, sitemap
8. **seo-performance** — Core Web Vitals, LCP/CLS

### Deploy

9. **vercel-deploy** — готовность к деплою, env vars

### Email

10. **email-integration** — контактные формы работают

### Analytics

11. **google-analytics** — GA4/GTM установлен
12. **facebook-pixel** — Pixel установлен

### E-commerce (если применимо)

13. **stripe-integration** — платежи настроены
14. **ecommerce-database** — БД спроектирована

## Составление отчёта

15. Для каждого скилла отметь:
    - ✅ OK
    - ⚠️ Требует внимания
    - ❌ Критическая проблема

16. Составь список задач по приоритету:
    1. Критические (блокируют запуск)
    2. Важные (влияют на качество)
    3. Улучшения (nice to have)

## Результат

Создай implementation_plan.md с:
- Обнаруженными проблемами
- Планом исправления
- Оценкой времени

---
name: vercel-deploy
description: "Используй для настройки автоматического деплоя. Git push = сайт обновился. Включает настройку доменов, переменных окружения, preview deployments."
---

# Vercel Deploy для Next.js

## Когда использовать

**ПРИ ПЕРВОМ ДЕПЛОЕ ПРОЕКТА** — настрой один раз, дальше всё автоматически.

---

## Шаг 1: Подключение репозитория

### Вариант A: Через Vercel Dashboard (рекомендуется)

1. Зайди на [vercel.com](https://vercel.com)
2. "Add New Project"
3. "Import Git Repository" → выбери GitHub репо
4. Vercel автоматически определит Next.js
5. "Deploy"

### Вариант B: Через CLI

```bash
npm i -g vercel
vercel login
vercel
```

**Результат:** Каждый `git push` в `main` = автоматический деплой.

---

## Шаг 2: Переменные окружения

### В Vercel Dashboard:
Settings → Environment Variables

```
NEXT_PUBLIC_SITE_URL=https://example.com
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
DATABASE_URL=postgresql://...
```

### Правила:
- `NEXT_PUBLIC_*` — доступны на клиенте
- Без префикса — только на сервере
- Разные значения для Production / Preview / Development

---

## Шаг 3: Домен

### Добавление домена:
Settings → Domains → Add Domain

### DNS настройки (у регистратора):

**Вариант A: Основной домен**
```
Type: A
Name: @
Value: 76.76.21.21
```

**Вариант B: С www**
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### Редирект www → без www:
Vercel делает автоматически после добавления обоих вариантов.

---

## Шаг 4: Preview Deployments

**Автоматически:** Каждый Pull Request получает уникальный URL.

Пример: `https://project-git-feature-branch-username.vercel.app`

### Использование:
1. Создай PR
2. Vercel создаст preview
3. Тестируй на preview URL
4. Merge → деплой в production

---

## Шаг 5: Оптимизация билда

### vercel.json (опционально)

```json
{
  "buildCommand": "npm run build",
  "outputDirectory": ".next",
  "framework": "nextjs",
  "regions": ["dub1"],
  "headers": [
    {
      "source": "/api/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "no-store" }
      ]
    },
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" }
      ]
    }
  ],
  "redirects": [
    {
      "source": "/old-page",
      "destination": "/new-page",
      "permanent": true
    }
  ]
}
```

### Регионы (для скорости):
- `dub1` — Дублин (Европа)
- `iad1` — Вашингтон (США)
- `sfo1` — Сан-Франциско

---

## Шаг 6: Rollback

**Если что-то сломалось:**

1. Vercel Dashboard → Deployments
2. Найди предыдущий успешный деплой
3. "⋮" → "Promote to Production"

**Или через CLI:**
```bash
vercel rollback
```

---

## Чеклист деплоя

### Первый деплой:
- [ ] Репозиторий подключён к Vercel
- [ ] Environment variables настроены
- [ ] Домен добавлен и DNS настроен
- [ ] SSL сертификат активен (автоматически)
- [ ] Preview deployments работают

### Каждый деплой:
- [ ] `git push` триггерит билд
- [ ] Билд проходит без ошибок
- [ ] Проверь production URL после деплоя

---

## Troubleshooting

| Проблема | Решение |
|----------|---------|
| Билд падает | Проверь логи в Vercel → Deployments |
| 404 на страницах | Проверь `next.config.js` и роутинг |
| Env переменные не работают | Передеплой после добавления переменных |
| Домен не работает | Подожди 24-48ч для DNS propagation |

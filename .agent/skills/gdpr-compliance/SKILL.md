---
name: gdpr-compliance
description: "Чеклист GDPR/CCPA для сайтов в ЕС. Обязательные страницы, Cookie Banner, согласия. Используй перед деплоем в production."
---

# GDPR Compliance

## Назначение

Этот скилл гарантирует соответствие сайта законам о защите персональных данных (GDPR, CCPA, ePrivacy Directive).

---

## Обязательные страницы

### 1. Privacy Policy (Политика конфиденциальности)

**Путь:** `/privacy`

**Должна содержать:**
- [ ] Кто собирает данные (название компании, контакты)
- [ ] Какие данные собираются
- [ ] Цели сбора данных
- [ ] Правовое основание обработки
- [ ] Срок хранения данных
- [ ] Права пользователя (доступ, удаление, исправление)
- [ ] Информация о передаче данных третьим лицам
- [ ] Контакт DPO (Data Protection Officer) если применимо
- [ ] Дата последнего обновления

---

### 2. Cookie Policy (Политика cookies)

**Путь:** `/cookie`

**Должна содержать:**
- [ ] Что такое cookies
- [ ] Типы используемых cookies:
  - Необходимые (essential)
  - Функциональные
  - Аналитические (Google Analytics)
  - Рекламные (Facebook Pixel)
- [ ] Как управлять cookies
- [ ] Ссылки на политики третьих сторон
- [ ] Дата последнего обновления

---

### 3. Terms of Service (Условия использования)

**Путь:** `/terms`

**Должна содержать:**
- [ ] Описание услуг
- [ ] Правила использования
- [ ] Ограничение ответственности
- [ ] Интеллектуальная собственность
- [ ] Применимое право (обычно Ireland/EU)
- [ ] Порядок разрешения споров
- [ ] Контактная информация

---

## Cookie Consent Banner

### Требования

Баннер должен появляться при первом посещении и:

- [ ] Блокировать non-essential cookies до получения согласия
- [ ] Предоставлять выбор (Accept All / Reject All / Customize)
- [ ] Не использовать тёмные паттерны (кнопка "Reject" должна быть видимой)
- [ ] Сохранять выбор пользователя
- [ ] Позволять изменить выбор позже

### Рекомендуемые решения

```jsx
// Для React/Next.js
// npm install react-cookie-consent

import CookieConsent from 'react-cookie-consent';

<CookieConsent
  location="bottom"
  buttonText="Accept All"
  declineButtonText="Reject"
  enableDeclineButton
  onAccept={() => {
    // Enable analytics
    gtag('consent', 'update', { analytics_storage: 'granted' });
  }}
  onDecline={() => {
    // Keep analytics disabled
  }}
>
  We use cookies to improve your experience.{' '}
  <a href="/cookie">Learn more</a>
</CookieConsent>
```

---

## Google Analytics Consent Mode

При использовании GA4 обязательно настрой Consent Mode:

```jsx
// В GTM или напрямую
gtag('consent', 'default', {
  'analytics_storage': 'denied',
  'ad_storage': 'denied',
  'wait_for_update': 500
});

// После согласия пользователя
gtag('consent', 'update', {
  'analytics_storage': 'granted'
});
```

---

## Footer требования

В футере должны быть ссылки на:

```jsx
<footer>
  // ... other content ...
  <div className="legal-links">
    <Link to="/privacy">Privacy Policy</Link>
    <Link to="/cookie">Cookie Policy</Link>
    <Link to="/terms">Terms of Service</Link>
  </div>
</footer>
```

---

## Мобильная версия Footer

Footer на мобильных устройствах:

- [ ] Должен использовать 2+ колонки (не одна длинная)
- [ ] Legal ссылки могут быть inline (flex row)
- [ ] Уменьшенные отступы на мобильном
- [ ] Логотип меньше на мобильном

**Пример:**
```jsx
// Mobile: 2 columns, Legal links inline
<div className="grid grid-cols-2 md:grid-cols-4 gap-8">
  <div className="col-span-2 md:col-span-1">
    {/* Logo */}
  </div>
  <div className="col-span-1">
    {/* Navigation */}
  </div>
  <div className="col-span-1">
    {/* Contact */}
  </div>
  <div className="col-span-2 md:col-span-1">
    {/* Legal - inline on mobile */}
    <ul className="flex flex-wrap gap-4 md:block md:space-y-3">
      <li><Link to="/privacy">Privacy</Link></li>
      <li><Link to="/cookie">Cookies</Link></li>
      <li><Link to="/terms">Terms</Link></li>
    </ul>
  </div>
</div>
```

---

## Чеклист перед запуском

### Страницы
- [ ] Privacy Policy создана и содержит все пункты
- [ ] Cookie Policy создана и содержит все пункты  
- [ ] Terms of Service создана и содержит все пункты
- [ ] Все страницы доступны из Footer
- [ ] Footer оптимизирован для мобильных

### Cookie Banner
- [ ] Баннер появляется при первом посещении
- [ ] Есть кнопки Accept / Reject / Customize
- [ ] Non-essential cookies блокируются до согласия
- [ ] Выбор сохраняется в localStorage/cookie
- [ ] GA4 использует Consent Mode

### Контактная форма
- [ ] Чекбокс согласия с Privacy Policy
- [ ] Ссылка на Privacy Policy рядом с чекбоксом

---

## Штрафы за несоблюдение

> [!CAUTION]
> GDPR штрафы: до €20 млн или 4% годового оборота (что больше)

Это не рекомендация, а требование закона для всех сайтов, обслуживающих пользователей в ЕС.

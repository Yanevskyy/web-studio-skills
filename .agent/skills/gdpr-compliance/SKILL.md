---
name: gdpr-compliance
description: "GDPR/CCPA checklist for EU websites. Required pages, Cookie Banner, consent. Use before deploying to production."
---

# GDPR Compliance

## Purpose

This skill ensures the website complies with data protection laws (GDPR, CCPA, ePrivacy Directive).

---

## Required Pages

### 1. Privacy Policy

**Path:** `/privacy`

**Must contain:**
- [ ] Who collects data (company name, contacts)
- [ ] What data is collected
- [ ] Purpose of data collection
- [ ] Legal basis for processing
- [ ] Data retention period
- [ ] User rights (access, deletion, correction)
- [ ] Third-party data sharing information
- [ ] DPO (Data Protection Officer) contact if applicable
- [ ] Date of last update

---

### 2. Cookie Policy

**Path:** `/cookie`

**Must contain:**
- [ ] What cookies are
- [ ] Types of cookies used:
  - Essential (necessary)
  - Functional
  - Analytics (Google Analytics)
  - Advertising (Facebook Pixel)
- [ ] How to manage cookies
- [ ] Links to third-party policies
- [ ] Date of last update

---

### 3. Terms of Service

**Path:** `/terms`

**Must contain:**
- [ ] Description of services
- [ ] Usage rules
- [ ] Limitation of liability
- [ ] Intellectual property
- [ ] Applicable law (usually Ireland/EU)
- [ ] Dispute resolution procedure
- [ ] Contact information

---

## Cookie Consent Banner

### Requirements

Banner must appear on first visit and:

- [ ] Block non-essential cookies until consent is given
- [ ] Provide choice (Accept All / Reject All / Customize)
- [ ] Not use dark patterns ("Reject" button must be visible)
- [ ] Save user's choice
- [ ] Allow changing choice later

### Recommended solution

```jsx
// For React/Next.js
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

When using GA4, Consent Mode is required:

```jsx
// In GTM or directly
gtag('consent', 'default', {
  'analytics_storage': 'denied',
  'ad_storage': 'denied',
  'wait_for_update': 500
});

// After user consent
gtag('consent', 'update', {
  'analytics_storage': 'granted'
});
```

---

## Footer Requirements

Footer must include links to:

```jsx
<footer>
  {/* ... other content ... */}
  <div className="legal-links">
    <Link to="/privacy">Privacy Policy</Link>
    <Link to="/cookie">Cookie Policy</Link>
    <Link to="/terms">Terms of Service</Link>
  </div>
</footer>
```

---

## Mobile Footer

> [!WARNING]
> **Common Mistake:** Using `flex gap-16` for 3+ columns causes horizontal overflow on mobile (375px).
> Always use `grid` for footer navigation columns, not `flex` with large gaps.

Footer on mobile devices:

- [ ] **MUST use grid** for 3+ navigation columns (Navigate, Connect, Legal)
- [ ] Legal column spans full width on mobile (`col-span-2`)
- [ ] Legal links inline on mobile (`flex flex-wrap`)
- [ ] Reduced padding on mobile
- [ ] Smaller logo on mobile

### Recommended Footer Structure (3 columns)

```jsx
{/* Footer content wrapper */}
<div className="flex flex-col gap-12 md:flex-row md:justify-between">
  {/* Identity - Logo and description */}
  <div className="space-y-4 md:max-w-xs">
    {/* Logo */}
    {/* Description */}
  </div>

  {/* Navigation columns - MUST use grid, NOT flex! */}
  <div className="grid grid-cols-2 gap-8 md:flex md:gap-20">
    {/* Navigate column */}
    <div className="space-y-4">
      <p className="text-xs uppercase tracking-[0.15em] text-muted">Navigate</p>
      <ul className="space-y-2">
        <li><Link href="/about">About</Link></li>
        <li><Link href="/services">Services</Link></li>
      </ul>
    </div>

    {/* Connect column */}
    <div className="space-y-4">
      <p className="text-xs uppercase tracking-[0.15em] text-muted">Connect</p>
      <ul className="space-y-2">
        <li><Link href="/contact">Contact</Link></li>
      </ul>
    </div>

    {/* Legal column - spans full width on mobile */}
    <div className="space-y-4 col-span-2 md:col-span-1">
      <p className="text-xs uppercase tracking-[0.15em] text-muted">Legal</p>
      {/* Inline on mobile, vertical on desktop */}
      <ul className="flex flex-wrap gap-x-6 gap-y-2 md:block md:space-y-2">
        <li><Link href="/privacy">Privacy Policy</Link></li>
        <li><Link href="/cookies">Cookie Policy</Link></li>
        <li><Link href="/terms">Terms of Service</Link></li>
      </ul>
    </div>
  </div>
</div>
```

### Why grid instead of flex?

| Approach | Mobile (375px) | Result |
|----------|----------------|--------|
| `flex gap-16` | 3 cols × 64px gaps = overflow | Broken layout, horizontal scroll |
| `grid grid-cols-2` | 2 cols + Legal full width | Clean, no overflow |

### Mobile Layout Visualization

```
┌─────────────────────────────┐
│         Logo                │
│      Description            │
├──────────────┬──────────────┤
│   Navigate   │   Connect    │
│   • About    │   • Contact  │
│   • Services │              │
├──────────────┴──────────────┤
│            Legal            │
│  Privacy · Cookies · Terms  │
└─────────────────────────────┘
```

---

## Studio Credit (Clarity Web)

- [ ] Add "Made by Clarity Web" to the bottom of the footer
- [ ] Link to https://clarityweb.ie
- [ ] Style: subtle, smaller font size, muted color

```jsx
{/* Bottom Bar */}
<div className="flex flex-col md:flex-row justify-between items-center gap-4">
  <p className="text-xs text-soft-grey">
    &copy; {currentYear} ClientName. All rights reserved.
  </p>
  <div className="flex items-center gap-6">
    {/* Other links */}
    <span className="text-soft-grey/50">|</span>
    <a
      href="https://clarityweb.ie"
      target="_blank"
      rel="noopener noreferrer"
      className="text-xs text-soft-grey/60 hover:text-beige transition-colors duration-300"
    >
      Made by Clarity Web
    </a>
  </div>
</div>
```

---

## Pre-Launch Checklist

### Pages
- [ ] Privacy Policy created with all required items
- [ ] Cookie Policy created with all required items
- [ ] Terms of Service created with all required items
- [ ] All pages accessible from Footer
- [ ] Footer optimized for mobile

### Cookie Banner
- [ ] Banner appears on first visit
- [ ] Accept / Reject / Customize buttons present
- [ ] Non-essential cookies blocked until consent
- [ ] Choice saved in localStorage/cookie
- [ ] GA4 uses Consent Mode

### Contact Form
- [ ] Checkbox for consent to Privacy Policy
- [ ] Link to Privacy Policy near checkbox

---

## Penalties for Non-Compliance

> [!CAUTION]
> GDPR fines: up to EUR 20 million or 4% of annual turnover (whichever is greater)

This is not a recommendation, but a legal requirement for all websites serving EU users.

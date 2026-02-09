---
name: semantic-ux-audit
description: "Use before release or when adding new sections/pages. Finds logical UX errors that regular linters miss. Checks every button on every page without exceptions."
---

# Semantic UX Audit

## When to use
**REQUIRED** before release or when adding new sections/pages.
This audit helps find logical errors that regular linters miss.
**IMPORTANT:** Don't save resources. Check **absolutely every** button on **absolutely every** page without exceptions.

---

## Philosophy
Users don't read code. They scan headings and look for buttons that solve their task. If a heading says "Services" but a button leads to "Portfolio" — that's a UX error, even if the link works.

---

## Audit Methodology

### 1. "Header-Button Match" Rule
For each section, check the chain:
`Section Heading` -> `Button Text` -> `Target Page`

| Pattern | Example | Verdict |
|---------|---------|---------|
| **Direct match** | Heading "Our Events" -> Button "View Events" -> Link `/events` | **Excellent** |
| **Indirect but logical** | Heading "Our Story" -> Button "Learn More" -> Link `/about` | **Good** |
| **Semantic gap** | Heading "Private Events" -> Button "See our work" -> Link `/portfolio` | **ERROR** (User wants to book a service, not view photos) |
| **False promise** | Heading "Contact Us" -> Button "Email" -> Link `mailto:` (no form) | **Warning** (If a form was promised) |

### 2. User Intent Types

Determine what the user wants in each block:

1. **Transactional (Buy/Order):**
    - Keywords: *Buy, Order, Book, Reserve, Get Quote*
    - Goal: Cart, Checkout, Order form, Contact
    - Error: Leading to informational page (About, FAQ)

2. **Informational (Learn):**
    - Keywords: *Learn, Read, Story, About, History*
    - Goal: About, Blog, FAQ
    - Error: Leading directly to checkout or payment form

3. **Navigational (Find):**
    - Keywords: *Find us, Location, Visit*
    - Goal: Contact, Google Maps
    - Error: Leading to homepage

### 3. Section Review Checklist

For each content section, ask 3 questions:
1. **What does the heading say?** (Example: "We do weddings")
2. **What does the button promise?** (Example: "Learn more")
3. **Where does the link actually go?** (Example: "/portfolio")

**If 1 and 3 don't match semantically — it's a bug.**

---

## Step-by-Step Process

1. **Full page inventory (Strict Mode):**
    - **REQUIRED:** Compile a complete list of all files in `pages` (or `app`) directory.
    - **FORBIDDEN:** Check only "main" pages.
    - **FORBIDDEN:** Ignore utility pages (404, Privacy, Terms, Auth).
    - Use `ls` or `find` to see *every* file. The audit is considered failed if even one page is skipped.

2. **Homepage walkthrough:**
    Go top to bottom and check every CTA:
    - *Hero:* Where does the main CTA lead? Does it match the main value proposition?
    - *Feature Block:* Does the button lead to details about this specific feature?
    - *Footer:* Do all footer links go where expected?

3. **Dead-end analysis:**
    Are there pages with no way forward (except "Back")?
    - *Example:* "Thank you for your order" page without a "Home" button.
    - *Solution:* Add a navigation exit.

---

## Common Semantic Errors

| Error | Why it's bad | How to fix |
|-------|-------------|-----------|
| "Services" button leads to "Contact" | User wants to read, not call | Lead to `/services`, add CTA there |
| "Read More" in team section leads to `/about` | Too broad | Lead to `/about#team` section |
| "Order Now" opens a PDF menu | Breaks "Order" expectation | Name button "View Menu" |
| Inactive breadcrumbs | User can't tell where they are | Make parent categories clickable |

---

## Auditor's Final Question

> "Have I checked every page from the file list? Am I certain that no button, even the most hidden one, leads to a semantic dead-end?"

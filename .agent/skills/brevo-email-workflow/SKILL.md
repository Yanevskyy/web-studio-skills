---
name: brevo-email-workflow
description: "Complete workflow for setting up Brevo transactional email in a Next.js + Vercel project. Use when adding contact forms, booking forms, or any transactional email that requires both admin notification and client confirmation. Covers Brevo account setup, domain verification (SPF/DKIM/DMARC), API route with logging, HTML email templates, and testing."
---

# Brevo Email Workflow — Next.js + Vercel

End-to-end workflow for setting up transactional email via Brevo (formerly Sendinblue) in a Next.js App Router project deployed on Vercel. Follow steps in order.

## Prerequisites

Before starting, ensure you have:
- A **custom domain** (e.g. `example.com`) with DNS access
- A **Next.js App Router** project
- A **Vercel** project linked to the repo

---

## Step 1: Brevo Account and API Key

1. Register at [brevo.com](https://www.brevo.com) (free plan: 300 emails/day)
2. Go to **Settings -> SMTP & API -> API Keys**
3. Click **Generate a new API key**, copy it immediately

> NEVER commit the API key to source code. It goes into environment variables only.

---

## Step 2: Domain Verification (CRITICAL)

Without this, emails will be rejected by strict providers (Mail.ru, Yahoo, some corporate servers) with `550 spam message rejected`.

1. In Brevo: **Settings -> Senders, Domains & Dedicated IPs -> Domains -> Add a domain**
2. Enter your domain (e.g. `example.com`)
3. Brevo will give you DNS records to add. Add ALL of these:

| Record | Type | Purpose |
|--------|------|---------|
| SPF | TXT | Authorizes Brevo to send on behalf of your domain |
| DKIM | TXT | Cryptographic signature proving email authenticity |
| DMARC | TXT | Policy for handling failed SPF/DKIM checks |
| Brevo code | TXT | Verifies domain ownership |

4. Add records in your DNS provider (Cloudflare, Namecheap, etc.)
5. Wait 5-30 minutes, then click **Verify** in Brevo
6. Also add a **Sender**: Settings -> Senders -> Add a sender -> use `hello@yourdomain.com`

**Verification checklist:**
- [ ] SPF record added and verified
- [ ] DKIM record added and verified
- [ ] DMARC record added and verified
- [ ] Brevo verification code added and verified
- [ ] Sender email created (e.g. `hello@yourdomain.com`)

---

## Step 3: Environment Variables

### 3a. Create `.env.local` (local development)

```env
BREVO_API_KEY=xkeysib-your-actual-key-here
ADMIN_EMAIL=admin@example.com
```

### 3b. Create `.env.example` (template for other developers)

```env
# Brevo API key for sending transactional emails
# Get yours at: https://app.brevo.com/settings/keys/api
BREVO_API_KEY=your-brevo-api-key-here

# Admin email — receives all form submissions
ADMIN_EMAIL=your-admin-email@example.com
```

### 3c. Add to Vercel (production)

Go to **Vercel Dashboard -> Project -> Settings -> Environment Variables** and add:
- `BREVO_API_KEY` = your actual key
- `ADMIN_EMAIL` = the admin's real email

> After adding env vars in Vercel, you must **redeploy** for them to take effect.

### 3d. Add `.env.local` to `.gitignore`

Verify `.env.local` is in `.gitignore`. If not, add it.

---

## Step 4: Centralized Site Config

Create `lib/config.ts` with all contact details. Read sensitive data from env vars:

```typescript
export const siteConfig = {
  name: "Business Name",
  businessName: "Business Full Name",
  email: process.env.ADMIN_EMAIL || "fallback@example.com",
  phone: "+353 87 000 0000",
  phoneTel: "+353870000000",
  whatsappUrl: "https://wa.me/353870000000",
  address: "Full Address, City, Country",
  url: "https://yourdomain.com",
}
```

**Rules:**
- `email` MUST read from `process.env.ADMIN_EMAIL`
- Phone, address, URL: store here, not hardcoded across pages
- All pages and API routes import from this single config

---

## Step 5: API Route

Create `app/api/contact/route.ts`. See [reference.md](reference.md) for the full template.

**Architecture rules (learned from production):**

1. **Read `adminEmail` at request time** — not at module level. Module-level constants may not pick up Vercel runtime env vars:
   ```typescript
   // INSIDE the POST handler, not at top level
   const adminEmail = process.env.ADMIN_EMAIL || siteConfig.email
   ```

2. **Independent try/catch for each email** — if admin email fails, client still gets confirmation:
   ```typescript
   try { await sendEmail(adminPayload) } catch (err) { adminError = err }
   try { await sendEmail(clientPayload) } catch (err) { clientError = err }
   ```

3. **Detailed logging with `[Contact]` prefix** — visible in Vercel Functions logs:
   ```typescript
   console.log("[Contact] Admin email target:", adminEmail)
   console.log("[Contact] Admin email SUCCESS:", JSON.stringify(result))
   console.error("[Contact] Client email FAILED:", error)
   ```

4. **Dynamic logo URL from request headers** — the deployment domain may differ from the configured domain:
   ```typescript
   function getLogoUrl(request: Request): string {
     const host = request.headers.get("host") || "yourdomain.com"
     const proto = request.headers.get("x-forwarded-proto") || "https"
     return `${proto}://${host}/images/logo.png`
   }
   ```

5. **Return `_debug` in response** — helps diagnose without Vercel logs access:
   ```typescript
   return NextResponse.json({
     success: true,
     _debug: { adminTo, adminOk, adminMessageId, clientOk, clientMessageId, logoUrl }
   })
   ```

---

## Step 6: HTML Email Templates

### Constraints (email clients are NOT browsers)

- **Inline styles only** — no `<style>` tags, no CSS classes
- **Table layout only** — no flexbox, no grid (Outlook)
- **No CSS variables** — use hex values directly
- **Absolute URLs for images** — use dynamic `logoUrl` from Step 5
- **Buttons = styled `<a>` tags** — not `<button>`
- **Use `role="presentation"`** on layout tables

### Structure for both emails

```
Logo (centered image)
─── divider ───
Content (heading, table, text)
Action buttons (mailto, WhatsApp links)
─── divider ───
Footer (business name, address, confidentiality note)
```

### Admin notification email includes:
- Client details table: Name, Email (mailto link), Phone (tel link), Type, Format
- Message section (conditional — only shown if provided)
- "Reply to Client" button (`mailto:` to client's email)

### Client confirmation email includes:
- Greeting with client name
- "Your request received" message with response time
- Request summary (type, format, phone)
- Two action buttons: "Write on WhatsApp" + "Reply to [Name]" (`mailto:` to admin email)
- Signature block
- Confidentiality footer

See [reference.md](reference.md) for complete HTML templates.

---

## Step 7: Contact Form

### Required form fields
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| Name | text | Yes | Full name |
| Email | email | Yes | Client email for confirmation |
| Phone | tel | Yes | Primary follow-up channel |
| Consultation Type | select | No | Pre-filled default is fine |
| Preferred Format | select | No | Pre-filled default is fine |
| Message | textarea | **No** | Label: "Anything you'd like me to know?" |

**Why phone is required:** Admin's workflow is receive inquiry -> call person -> schedule.
**Why message is optional:** Reduces friction. Clients just want to book, not describe symptoms.

### Success state must include:
- Personalized thank-you ("Thank you, {name}")
- What happens next ("I will be in touch within 24 hours")
- Alternative contact: WhatsApp link + phone number

---

## Step 8: Testing Checklist

Run through this after deploying:

```
- [ ] Submit form on deployed site
- [ ] Check Vercel logs: Functions -> /api/contact -> look for [Contact] lines
- [ ] Verify admin email received (check spam folder)
- [ ] Verify client email received (check spam folder)
- [ ] Test with DIFFERENT email than ADMIN_EMAIL (avoids deduplication)
- [ ] Test with Gmail, Outlook, and one strict provider (Mail.ru, Yahoo)
- [ ] Verify logo displays in email
- [ ] Verify WhatsApp button opens correct chat
- [ ] Verify "Reply" button opens mailto with correct address
- [ ] Check _debug object in API response (browser DevTools -> Network tab)
```

---

## Lessons Learned (Pitfalls)

| Problem | Cause | Solution |
|---------|-------|----------|
| Admin email not received | `ADMIN_EMAIL` read at module level, not at request time | Read `process.env.ADMIN_EMAIL` inside the POST handler |
| Logo broken in email | Domain points to different server than Vercel | Use dynamic `getLogoUrl(request)` from request headers |
| Mail.ru rejects with 550 | Missing SPF/DKIM/DMARC records | Complete Step 2 domain verification |
| Only one email arrives when testing | Same address for admin and client | Always test with a different email |
| Client email silent failure | Both emails in one try/catch — first failure kills second | Independent try/catch per email |
| Secrets in source code | Hardcoded API keys or emails | ALL secrets in env vars, verified in `.env.example` |
| Env vars not working on Vercel | Added after last deploy | Redeploy after adding env vars |
| Form submits with empty required fields | Select pre-filled with first option looks "chosen" | Validate on both client (HTML `required`) and server |

---

## Quick Start (Copy-Paste Order)

For a new project, create files in this order:

1. `.env.local` and `.env.example`
2. `lib/config.ts`
3. `app/api/contact/route.ts` (copy from [reference.md](reference.md))
4. `components/ui/input.tsx`, `select.tsx`, `textarea.tsx`, `button.tsx`
5. `app/contact/page.tsx`
6. Place `logo.png` in `public/images/`
7. Configure Brevo: domain + sender + API key
8. Add env vars to Vercel
9. Deploy and test with the checklist above

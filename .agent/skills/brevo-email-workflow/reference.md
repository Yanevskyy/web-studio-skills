# Brevo Email — Code Reference

Full code templates ready for copy-paste. Adapt business name, colors, and field names to the project.

---

## 1. `lib/config.ts`

```typescript
// Centralized site configuration
// Contact details are read from environment variables where possible.

export const siteConfig = {
  name: "Owner Name",
  businessName: "Business Name",
  email: process.env.ADMIN_EMAIL || "fallback@example.com",
  phone: "+353 87 000 0000",
  phoneTel: "+353870000000",
  whatsappUrl: "https://wa.me/353870000000",
  address: "Full Address, City, Country, Eircode",
  url: "https://yourdomain.com",
}
```

---

## 2. `.env.local`

```env
BREVO_API_KEY=xkeysib-your-key-here
ADMIN_EMAIL=admin@example.com
```

## 3. `.env.example`

```env
# Brevo API key for sending transactional emails
# Get yours at: https://app.brevo.com/settings/keys/api
BREVO_API_KEY=your-brevo-api-key-here

# Admin email — receives all form submissions
ADMIN_EMAIL=your-admin-email@example.com
```

---

## 4. `app/api/contact/route.ts`

Complete API route with independent error handling, logging, and dynamic logo URL.

```typescript
import { NextResponse } from "next/server"
import { siteConfig } from "@/lib/config"

const BREVO_API_URL = "https://api.brevo.com/v3/smtp/email"
const SENDER_EMAIL = "hello@yourdomain.com"  // Must be verified in Brevo
const SENDER_NAME = siteConfig.businessName

interface ContactFormData {
  name: string
  email: string
  phone: string
  consultationType: string
  preferredFormat: string
  message: string
}

// Derive logo URL from request headers (works on any deployment host)
function getLogoUrl(request: Request): string {
  const host = request.headers.get("host") || "yourdomain.com"
  const proto = request.headers.get("x-forwarded-proto") || "https"
  return `${proto}://${host}/images/logo.png`
}

// Send email via Brevo API
async function sendEmail(payload: {
  sender: { name: string; email: string }
  to: { name?: string; email: string }[]
  subject: string
  htmlContent: string
}) {
  const apiKey = process.env.BREVO_API_KEY
  if (!apiKey) {
    throw new Error("BREVO_API_KEY environment variable is not set")
  }

  const response = await fetch(BREVO_API_URL, {
    method: "POST",
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
      "api-key": apiKey,
    },
    body: JSON.stringify(payload),
  })

  if (!response.ok) {
    const errorBody = await response.text()
    throw new Error(`Brevo API error (${response.status}): ${errorBody}`)
  }

  return response.json()
}

export async function POST(request: Request) {
  // Read admin email at request time (not module level)
  const adminEmail = process.env.ADMIN_EMAIL || siteConfig.email
  const logoUrl = getLogoUrl(request)

  console.log("[Contact] === New submission ===")
  console.log("[Contact] Admin email target:", adminEmail)
  console.log("[Contact] Logo URL:", logoUrl)

  try {
    const data: ContactFormData = await request.json()

    // Validation: name, email, phone required; message optional
    if (!data.name || !data.email || !data.phone) {
      return NextResponse.json(
        { error: "Name, email, and phone number are required." },
        { status: 400 }
      )
    }

    console.log("[Contact] Client name:", data.name)
    console.log("[Contact] Client email:", data.email)
    console.log("[Contact] Client phone:", data.phone)

    // Track results independently
    let adminResult = null
    let clientResult = null
    let adminError: string | null = null
    let clientError: string | null = null

    // 1. Admin notification (independent try/catch)
    try {
      console.log("[Contact] Sending admin email to:", adminEmail)
      adminResult = await sendEmail({
        sender: { name: SENDER_NAME, email: SENDER_EMAIL },
        to: [{ name: siteConfig.name, email: adminEmail }],
        subject: `New inquiry from ${data.name}`,
        htmlContent: buildAdminEmailHtml(data, logoUrl),
      })
      console.log("[Contact] Admin email SUCCESS:", JSON.stringify(adminResult))
    } catch (err) {
      adminError = err instanceof Error ? err.message : String(err)
      console.error("[Contact] Admin email FAILED:", adminError)
    }

    // 2. Client confirmation (independent try/catch)
    try {
      console.log("[Contact] Sending client email to:", data.email)
      clientResult = await sendEmail({
        sender: { name: SENDER_NAME, email: SENDER_EMAIL },
        to: [{ name: data.name, email: data.email }],
        subject: `Thank you for your inquiry — ${siteConfig.businessName}`,
        htmlContent: buildClientEmailHtml(data, adminEmail, logoUrl),
      })
      console.log("[Contact] Client email SUCCESS:", JSON.stringify(clientResult))
    } catch (err) {
      clientError = err instanceof Error ? err.message : String(err)
      console.error("[Contact] Client email FAILED:", clientError)
    }

    // Both failed
    if (adminError && clientError) {
      return NextResponse.json(
        { error: "Something went wrong. Please try again or email us directly." },
        { status: 500 }
      )
    }

    if (adminError) {
      console.warn("[Contact] Admin email failed but client email sent OK")
    }

    return NextResponse.json({
      success: true,
      _debug: {
        adminTo: adminEmail,
        adminOk: !adminError,
        adminMessageId: adminResult?.messageId || null,
        clientOk: !clientError,
        clientMessageId: clientResult?.messageId || null,
        logoUrl,
      },
    })
  } catch (error) {
    console.error("[Contact] Unexpected error:", error)
    return NextResponse.json(
      { error: "Something went wrong. Please try again or email us directly." },
      { status: 500 }
    )
  }
}

// --- Email HTML builders ---
// Adapt colors, fonts, and copy to match the project's design system.
// All styles must be inline. Use table layout only. No CSS variables.

function buildAdminEmailHtml(data: ContactFormData, logoUrl: string): string {
  return `
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /></head>
<body style="margin: 0; padding: 0; background-color: #faf9f7;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color: #faf9f7;">
    <tr>
      <td align="center" style="padding: 40px 16px;">
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 4px;">
          <tr>
            <td align="center" style="padding: 32px 40px 24px;">
              <img src="${logoUrl}" alt="${siteConfig.businessName}" width="160" style="display: block; height: auto; border: 0;" />
            </td>
          </tr>
          <tr><td style="padding: 0 40px;"><div style="height: 1px; background-color: #ddd;"></div></td></tr>
          <tr>
            <td style="padding: 28px 40px 8px; font-family: Georgia, serif; font-size: 22px; color: #333; font-weight: normal;">
              New inquiry from ${data.name}
            </td>
          </tr>
          <tr>
            <td style="padding: 16px 40px 0;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-family: Georgia, serif; font-size: 15px; color: #333;">
                <tr>
                  <td style="padding: 10px 0; color: #888; width: 130px; vertical-align: top;">Name</td>
                  <td style="padding: 10px 0;">${data.name}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #888; vertical-align: top;">Email</td>
                  <td style="padding: 10px 0;"><a href="mailto:${data.email}" style="color: #6b7c6f;">${data.email}</a></td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #888; vertical-align: top;">Phone</td>
                  <td style="padding: 10px 0;"><a href="tel:${data.phone}" style="color: #6b7c6f;">${data.phone}</a></td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #888; vertical-align: top;">Type</td>
                  <td style="padding: 10px 0;">${data.consultationType}</td>
                </tr>
                <tr>
                  <td style="padding: 10px 0; color: #888; vertical-align: top;">Format</td>
                  <td style="padding: 10px 0;">${data.preferredFormat}</td>
                </tr>
              </table>
            </td>
          </tr>
          ${data.message ? `
          <tr><td style="padding: 24px 40px 0;"><div style="height: 1px; background-color: #ddd;"></div></td></tr>
          <tr><td style="padding: 20px 40px 0; font-family: Georgia, serif; font-size: 14px; color: #888;">Message:</td></tr>
          <tr><td style="padding: 8px 40px 0; font-family: Georgia, serif; font-size: 15px; line-height: 1.7; color: #333; white-space: pre-wrap;">${data.message}</td></tr>
          ` : ""}
          <tr>
            <td align="center" style="padding: 32px 40px 8px;">
              <a href="mailto:${data.email}?subject=Re: Your inquiry"
                 style="display: inline-block; padding: 12px 28px; background-color: #6b7c6f; color: #ffffff; font-family: Georgia, serif; font-size: 15px; text-decoration: none; border-radius: 4px;">
                Reply to Client
              </a>
            </td>
          </tr>
          <tr><td style="padding: 32px 40px 0;"><div style="height: 1px; background-color: #ddd;"></div></td></tr>
          <tr>
            <td style="padding: 20px 40px 32px; font-family: Georgia, serif; font-size: 12px; color: #888; line-height: 1.6;">
              ${siteConfig.businessName}<br />${siteConfig.address}
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`
}

function buildClientEmailHtml(
  data: ContactFormData,
  adminEmail: string,
  logoUrl: string
): string {
  return `
<!DOCTYPE html>
<html lang="en">
<head><meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /></head>
<body style="margin: 0; padding: 0; background-color: #faf9f7;">
  <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color: #faf9f7;">
    <tr>
      <td align="center" style="padding: 40px 16px;">
        <table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width: 600px; width: 100%; background-color: #ffffff; border-radius: 4px;">
          <tr>
            <td align="center" style="padding: 32px 40px 24px;">
              <a href="${siteConfig.url}" style="text-decoration: none;">
                <img src="${logoUrl}" alt="${siteConfig.businessName}" width="160" style="display: block; height: auto; border: 0;" />
              </a>
            </td>
          </tr>
          <tr><td style="padding: 0 40px;"><div style="height: 1px; background-color: #ddd;"></div></td></tr>
          <tr>
            <td style="padding: 28px 40px 0; font-family: Georgia, serif; font-size: 16px; line-height: 1.8; color: #333;">
              Dear ${data.name},
            </td>
          </tr>
          <tr>
            <td style="padding: 16px 40px 0; font-family: Georgia, serif; font-size: 16px; line-height: 1.8; color: #333;">
              Thank you for reaching out. I have received your inquiry
              and will be in touch within 24 hours.
            </td>
          </tr>
          <tr>
            <td style="padding: 24px 40px 0;">
              <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="font-family: Georgia, serif; font-size: 14px; color: #888; background-color: #faf9f7; border-radius: 4px;">
                <tr><td style="padding: 12px 16px 4px;"><strong style="color: #333;">Your request:</strong> ${data.consultationType} &middot; ${data.preferredFormat}</td></tr>
                <tr><td style="padding: 4px 16px 12px;"><strong style="color: #333;">Phone:</strong> ${data.phone}</td></tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="padding: 16px 40px 0; font-family: Georgia, serif; font-size: 16px; line-height: 1.8; color: #333;">
              If you have any questions, please get in touch:
            </td>
          </tr>
          <tr>
            <td align="center" style="padding: 32px 40px 0;">
              <table role="presentation" cellpadding="0" cellspacing="0">
                <tr>
                  <td align="center" style="padding: 0 8px;">
                    <a href="${siteConfig.whatsappUrl}"
                       style="display: inline-block; padding: 12px 24px; background-color: #6b7c6f; color: #ffffff; font-family: Georgia, serif; font-size: 15px; text-decoration: none; border-radius: 4px;">
                      Write on WhatsApp
                    </a>
                  </td>
                  <td align="center" style="padding: 0 8px;">
                    <a href="mailto:${adminEmail}?subject=Question about my inquiry"
                       style="display: inline-block; padding: 12px 24px; background-color: #ffffff; color: #6b7c6f; font-family: Georgia, serif; font-size: 15px; text-decoration: none; border-radius: 4px; border: 1px solid #6b7c6f;">
                      Reply by Email
                    </a>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          <tr>
            <td style="padding: 32px 40px 0; font-family: Georgia, serif; font-size: 16px; line-height: 1.8; color: #333;">
              Warm regards,<br />${siteConfig.name}<br />
              <span style="color: #888; font-size: 14px;">${siteConfig.businessName}</span>
            </td>
          </tr>
          <tr><td style="padding: 32px 40px 0;"><div style="height: 1px; background-color: #ddd;"></div></td></tr>
          <tr>
            <td style="padding: 20px 40px 12px; font-family: Georgia, serif; font-size: 12px; color: #888; line-height: 1.6;">
              ${siteConfig.businessName}<br />${siteConfig.address}
            </td>
          </tr>
          <tr>
            <td style="padding: 0 40px 32px; font-family: Georgia, serif; font-size: 12px; color: #888; line-height: 1.6;">
              This is an automated confirmation. All information shared is treated with the strictest confidence.
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`
}
```

---

## 5. Contact Form (simplified excerpt)

```tsx
"use client"

import React, { useState } from "react"
import { siteConfig } from "@/lib/config"

export default function ContactPage() {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    consultationType: "initial",
    preferredFormat: "in-person",
    message: "",
  })
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [isSubmitted, setIsSubmitted] = useState(false)
  const [submitError, setSubmitError] = useState("")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSubmitting(true)
    setSubmitError("")

    try {
      const response = await fetch("/api/contact", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(formData),
      })

      if (!response.ok) {
        const data = await response.json()
        throw new Error(data.error || "Something went wrong.")
      }

      setIsSubmitted(true)
    } catch (error) {
      setSubmitError(
        error instanceof Error
          ? error.message
          : "Something went wrong. Please try again or email us directly."
      )
    } finally {
      setIsSubmitting(false)
    }
  }

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    setFormData(prev => ({ ...prev, [e.target.name]: e.target.value }))
  }

  if (isSubmitted) {
    return (
      <div>
        <p>Thank you, {formData.name}.</p>
        <p>Your request has been received. I will be in touch within 24 hours.</p>
        <p>If you need to reach me sooner:</p>
        <a href={siteConfig.whatsappUrl}>Write on WhatsApp</a>
        <a href={`tel:${siteConfig.phoneTel}`}>Call {siteConfig.phone}</a>
      </div>
    )
  }

  return (
    <form onSubmit={handleSubmit}>
      <input name="name" type="text" required placeholder="Full name"
             value={formData.name} onChange={handleChange} />

      <input name="email" type="email" required placeholder="your@email.com"
             value={formData.email} onChange={handleChange} />

      <input name="phone" type="tel" required placeholder="+353 87 000 0000"
             value={formData.phone} onChange={handleChange} />

      {/* Consultation Type and Format selects — adapt to project */}

      <textarea name="message" rows={4} placeholder="Optional"
                value={formData.message} onChange={handleChange} />

      {submitError && <p role="alert">{submitError}</p>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? "Sending..." : "Send Request"}
      </button>
    </form>
  )
}
```

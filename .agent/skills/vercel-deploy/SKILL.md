---
name: vercel-deploy
description: "Use when setting up automatic deploys. Git push = site updated. Includes domain setup, environment variables, preview deployments."
---

# Vercel Deploy for Next.js

## When to use

**ON FIRST PROJECT DEPLOY** — set up once, everything is automatic after.

---

## Step 1: Connect Repository

### Option A: Via Vercel Dashboard (recommended)

1. Go to [vercel.com](https://vercel.com)
2. "Add New Project"
3. "Import Git Repository" → select GitHub repo
4. Vercel auto-detects Next.js
5. "Deploy"

### Option B: Via CLI

```bash
npm i -g vercel
vercel login
vercel
```

**Result:** Every `git push` to `main` = automatic deploy.

---

## Step 2: Environment Variables

### In Vercel Dashboard:
Settings → Environment Variables

```
NEXT_PUBLIC_SITE_URL=https://example.com
STRIPE_SECRET_KEY=sk_live_xxx
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
DATABASE_URL=postgresql://...
```

### Rules:
- `NEXT_PUBLIC_*` — available on client
- Without prefix — server only
- Different values for Production / Preview / Development

---

## Step 3: Domain

### Adding a domain:
Settings → Domains → Add Domain

### DNS settings (at registrar):

**Option A: Root domain**
```
Type: A
Name: @
Value: 76.76.21.21
```

**Option B: With www**
```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
```

### Redirect www → non-www:
Vercel does it automatically after adding both variants.

---

## Step 4: Preview Deployments

**Automatic:** Every Pull Request gets a unique URL.

Example: `https://project-git-feature-branch-username.vercel.app`

### Usage:
1. Create PR
2. Vercel creates preview
3. Test on preview URL
4. Merge → deploy to production

---

## Step 5: Build Optimization

### vercel.json (optional)

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

### Regions (for speed):
- `dub1` — Dublin (Europe)
- `iad1` — Washington (US)
- `sfo1` — San Francisco

---

## Step 6: Rollback

**If something breaks:**

1. Vercel Dashboard → Deployments
2. Find previous successful deploy
3. "..." → "Promote to Production"

**Or via CLI:**
```bash
vercel rollback
```

---

## Deploy Checklist

### First deploy:
- [ ] Repository connected to Vercel
- [ ] Environment variables configured
- [ ] Domain added and DNS configured
- [ ] SSL certificate active (automatic)
- [ ] Preview deployments working

### Every deploy:
- [ ] `git push` triggers build
- [ ] Build completes without errors
- [ ] Check production URL after deploy

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails | Check logs in Vercel → Deployments |
| 404 on pages | Check `next.config.js` and routing |
| Env vars not working | Redeploy after adding variables |
| Domain not working | Wait 24-48h for DNS propagation |

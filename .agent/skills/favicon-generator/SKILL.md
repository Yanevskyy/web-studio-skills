---
name: favicon-generator
description: "Generate favicons from a project logo for Next.js App Router projects. Covers symbol extraction, PNG generation (apple-icon, light/dark 32x32), SVG with theme support, Next.js metadata config, and cleanup of v0/placeholder icons. Use when adding favicons, replacing placeholder icons, or when the user mentions favicon, site icon, or browser tab icon."
---

# Favicon Generator — Next.js App Router

End-to-end workflow for generating favicons from a project logo. Uses Sharp (available in any Next.js project) for image processing. Follow steps in order.

## Output Files

| File | Size | Purpose |
|------|------|---------|
| `public/apple-icon.png` | 180x180 | iOS home screen, Safari bookmarks |
| `public/icon-light-32x32.png` | 32x32 | Browser tab — light theme |
| `public/icon-dark-32x32.png` | 32x32 | Browser tab — dark theme |
| `public/icon.svg` | 180x180 viewBox | Modern browsers, auto light/dark |

---

## Step 1: Audit Existing Icons

Search and document the current state:

```
Checklist:
- [ ] List all icon files in public/ (glob: *icon*, *favicon*, *.ico)
- [ ] Read metadata.icons config in app/layout.tsx
- [ ] Grep for placeholder/v0 icon references in *.tsx files
- [ ] Locate project logo (usually public/images/logo.png)
```

**What to look for:**
- v0/Vercel default icons (black bg, white "v0" text) — must be replaced
- `placeholder-*.{png,svg,jpg}` files — candidates for deletion
- Any `.ico` files — not needed in modern Next.js (use PNG + SVG)

---

## Step 2: Analyze the Logo

Run Sharp metadata to get dimensions:

```bash
node -e "require('sharp')('public/images/logo.png').metadata().then(m => console.log(m.width + 'x' + m.height, 'hasAlpha:', m.hasAlpha))"
```

**Decision tree:**

- **Square logo (1:1 ratio)** → Use as-is, skip to Step 3
- **Horizontal logo with text** → Need to crop the symbol portion (left side typically)
- **Text-only logo** → Use first letter or monogram as favicon, or ask user for a symbol

**Identify brand colors** from `globals.css` or `tailwind.config`:
- Paper/background color (for apple-icon bg) — e.g. `#faf9f7`
- Accent/primary color — for reference

---

## Step 3: Extract Symbol and Generate PNGs

Use the generation script from [reference.md](reference.md). Adapt these parameters:

| Parameter | How to determine |
|-----------|-----------------|
| `symbolWidth` | Width of the symbol portion in the logo (use the height as guide for square crop) |
| `paperBg` | Paper/background color from CSS tokens — `{ r, g, b }` |
| `brightnessMultiplier` | `1.6` works for most green/earth-tone logos. Increase for darker logos. |
| `saturationMultiplier` | `0.6` — desaturate slightly for dark mode readability |

**Run the script**, then **visually verify all 3 PNGs**:

```
Verification:
- [ ] apple-icon.png: symbol centered on solid background, 180x180
- [ ] icon-light-32x32.png: colored symbol on transparent bg, recognizable at 32px
- [ ] icon-dark-32x32.png: lightened symbol, visible on dark backgrounds
```

---

## Step 4: Create SVG Favicon with Theme Support

Use the SVG template from [reference.md](reference.md). The SVG embeds both light and dark PNGs as base64 data-URIs, switching via CSS `prefers-color-scheme` media query.

**Key constraint:** SVG favicons with embedded `<image>` elements using data-URIs are well-supported in Chrome, Firefox, Edge, Safari 16+. Older Safari falls back to the PNG favicons.

---

## Step 5: Configure Next.js Metadata

In `app/layout.tsx`, ensure `metadata.icons` matches this pattern:

```typescript
icons: {
  icon: [
    {
      url: '/icon-light-32x32.png',
      media: '(prefers-color-scheme: light)',
    },
    {
      url: '/icon-dark-32x32.png',
      media: '(prefers-color-scheme: dark)',
    },
    {
      url: '/icon.svg',
      type: 'image/svg+xml',
    },
  ],
  apple: '/apple-icon.png',
},
```

If the project already has this config (common in v0 scaffolds), just replace the files — no code changes needed.

---

## Step 6: Clean Up

1. **Delete unused placeholder files** — only after confirming they are not referenced:

```bash
# Search for references first
grep -r "placeholder" --include="*.tsx" --include="*.ts" app/ components/ lib/
```

Common files to delete:
- `public/placeholder-logo.png`
- `public/placeholder-logo.svg`
- `public/placeholder-user.jpg`
- `public/placeholder.jpg`
- `public/placeholder.svg`

2. **Remove any `.ico` files** if present — not needed with PNG + SVG setup.

---

## Step 7: Verify

```
Final checklist:
- [ ] npm run build — no errors
- [ ] Open site in browser — correct icon in tab
- [ ] Toggle system theme (light/dark) — icon switches
- [ ] Check apple-icon: Safari → Add to Reading List or iOS simulator
- [ ] No v0/Vercel icons remaining
- [ ] No placeholder files remaining in public/
```

---

## Lessons Learned

| Problem | Cause | Solution |
|---------|-------|----------|
| Apple icon has white corners on iOS | Transparent background | Use solid paper/white bg for apple-icon |
| Dark mode icon invisible | Same colored icon on dark bg | Use `modulate({ brightness: 1.6, saturation: 0.6 })` |
| SVG favicon not showing | Browser caches old favicon | Hard refresh (Cmd+Shift+R) or clear cache |
| Sharp not found | Not installed | It ships with Next.js — just `require('sharp')` |
| Cropped symbol looks off-center | Logo has uneven whitespace | Use `.trim()` after `.extract()` then re-pad |
| icon.svg too large | High-res PNGs embedded | Resize embedded PNGs to 180x180 max |
| `extract_area: bad extract area` | Crop dimensions exceed image bounds | Ensure crop width/height <= image dimensions |

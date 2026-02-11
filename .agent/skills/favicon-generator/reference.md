# Favicon Generator — Reference

## Complete Generation Script

This Node.js script generates all favicon files from a logo. Requires Sharp (ships with Next.js).

**Before running:** Adjust the configuration block at the top to match your project.

```javascript
const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

// ============================================================
// CONFIGURATION — Adjust for each project
// ============================================================

const CONFIG = {
  // Path to the project logo
  logoPath: 'public/images/logo.png',

  // Output paths
  outputDir: 'public',

  // Symbol extraction: how to crop the symbol from the logo
  // For a horizontal logo with text, the symbol is usually on the left.
  // Set to null if the logo is already square / is the symbol itself.
  symbolCrop: {
    left: 0,
    top: 0,
    // width and height will be set dynamically (use logo height for square crop)
    useHeightAsWidth: true, // Crop a square using the logo's height
  },

  // Background color for apple-icon (must be opaque, no transparency)
  // Use the project's paper/background color
  paperBg: { r: 250, g: 249, b: 247 }, // #faf9f7

  // Dark mode adjustments for icon-dark-32x32.png
  darkMode: {
    brightness: 1.6,    // Brighten for visibility on dark backgrounds
    saturation: 0.6,    // Slightly desaturate for softer appearance
  },

  // Apple icon: symbol size within the 180x180 frame (rest is padding)
  appleIconSymbolSize: 160,
  appleIconPadding: 10,
};

// ============================================================
// GENERATION — Usually no changes needed below
// ============================================================

async function generateFavicons() {
  const logo = sharp(CONFIG.logoPath);
  const metadata = await logo.metadata();
  console.log(`Logo: ${metadata.width}x${metadata.height}, hasAlpha: ${metadata.hasAlpha}`);

  // Step 1: Extract symbol
  let symbolBuffer;

  if (CONFIG.symbolCrop) {
    const cropWidth = CONFIG.symbolCrop.useHeightAsWidth
      ? metadata.height - 1 // -1 to avoid edge overflow
      : CONFIG.symbolCrop.width;
    const cropHeight = metadata.height - 1;

    symbolBuffer = await sharp(CONFIG.logoPath)
      .extract({
        left: CONFIG.symbolCrop.left,
        top: CONFIG.symbolCrop.top,
        width: cropWidth,
        height: cropHeight,
      })
      .toBuffer();
    console.log(`Extracted symbol: ${cropWidth}x${cropHeight}`);
  } else {
    symbolBuffer = await sharp(CONFIG.logoPath).toBuffer();
    console.log('Using full logo as symbol');
  }

  // Step 2: Generate apple-icon.png (180x180, opaque background)
  const { appleIconSymbolSize: symSize, appleIconPadding: pad, paperBg } = CONFIG;

  await sharp(symbolBuffer)
    .resize(symSize, symSize, {
      fit: 'contain',
      background: { ...paperBg, alpha: 1 },
    })
    .flatten({ background: paperBg })
    .extend({
      top: pad, bottom: pad, left: pad, right: pad,
      background: { ...paperBg, alpha: 1 },
    })
    .png()
    .toFile(path.join(CONFIG.outputDir, 'apple-icon.png'));

  console.log('Created apple-icon.png (180x180)');

  // Step 3: Generate icon-light-32x32.png (transparent background)
  await sharp(symbolBuffer)
    .resize(32, 32, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toFile(path.join(CONFIG.outputDir, 'icon-light-32x32.png'));

  console.log('Created icon-light-32x32.png (32x32)');

  // Step 4: Generate icon-dark-32x32.png (brightened for dark backgrounds)
  await sharp(symbolBuffer)
    .resize(32, 32, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .modulate({
      brightness: CONFIG.darkMode.brightness,
      saturation: CONFIG.darkMode.saturation,
    })
    .png()
    .toFile(path.join(CONFIG.outputDir, 'icon-dark-32x32.png'));

  console.log('Created icon-dark-32x32.png (32x32)');

  // Step 5: Generate icon.svg with embedded light/dark PNGs
  const lightPng = await sharp(symbolBuffer)
    .resize(180, 180, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .png()
    .toBuffer();

  const darkPng = await sharp(symbolBuffer)
    .resize(180, 180, {
      fit: 'contain',
      background: { r: 0, g: 0, b: 0, alpha: 0 },
    })
    .modulate({
      brightness: CONFIG.darkMode.brightness,
      saturation: CONFIG.darkMode.saturation,
    })
    .png()
    .toBuffer();

  const svg = `<svg width="180" height="180" viewBox="0 0 180 180" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
  <style>
    .light-icon { display: block; }
    .dark-icon { display: none; }
    @media (prefers-color-scheme: dark) {
      .light-icon { display: none; }
      .dark-icon { display: block; }
    }
  </style>
  <image class="light-icon" width="180" height="180" href="data:image/png;base64,${lightPng.toString('base64')}"/>
  <image class="dark-icon" width="180" height="180" href="data:image/png;base64,${darkPng.toString('base64')}"/>
</svg>`;

  fs.writeFileSync(path.join(CONFIG.outputDir, 'icon.svg'), svg);
  console.log(`Created icon.svg (${Math.round(svg.length / 1024)}KB)`);

  // Step 6: Verify all outputs
  console.log('\n--- Verification ---');
  const files = ['apple-icon.png', 'icon-light-32x32.png', 'icon-dark-32x32.png'];
  for (const file of files) {
    const filePath = path.join(CONFIG.outputDir, file);
    const meta = await sharp(filePath).metadata();
    console.log(`${file}: ${meta.width}x${meta.height} ✓`);
  }
  const svgSize = fs.statSync(path.join(CONFIG.outputDir, 'icon.svg')).size;
  console.log(`icon.svg: ${Math.round(svgSize / 1024)}KB ✓`);

  console.log('\nAll favicons generated successfully.');
}

generateFavicons().catch(console.error);
```

### How to run

Copy the script above, adjust the CONFIG section, then run:

```bash
node -e "$(cat << 'SCRIPT'
// ... paste script here ...
SCRIPT
)"
```

Or save as a temp file and run:

```bash
node /tmp/generate-favicons.js
```

---

## Next.js Metadata Configuration

Add this to `app/layout.tsx` inside the `metadata` export:

```typescript
export const metadata: Metadata = {
  // ... other metadata ...
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
}
```

**How browsers use these:**
- Chrome/Edge/Firefox: prefer `icon.svg` (auto light/dark via CSS)
- Safari < 16: falls back to PNG with `media` attribute matching system theme
- iOS: uses `apple-icon.png` for home screen bookmarks

---

## Common Paper/Background Colors

| Style | Color | RGB |
|-------|-------|-----|
| Pure white | `#ffffff` | `{ r: 255, g: 255, b: 255 }` |
| Warm paper | `#faf9f7` | `{ r: 250, g: 249, b: 247 }` |
| Cool paper | `#f8f9fa` | `{ r: 248, g: 249, b: 250 }` |
| Cream | `#fdf8f0` | `{ r: 253, g: 248, b: 240 }` |

---

## Dark Mode Brightness Guide

| Logo tone | brightness | saturation | Notes |
|-----------|-----------|------------|-------|
| Dark green/earth | 1.6 | 0.6 | Tested — good results |
| Medium blue/purple | 1.4 | 0.7 | Slightly less brightening |
| Already light pastel | 1.1 | 0.9 | Minimal adjustment needed |
| Very dark (near black) | 2.0 | 0.5 | Maximum brightening |

Always verify visually. If the result looks washed out, reduce brightness. If too saturated, reduce saturation further.

---

## Files to Delete After Generation

Common v0/Vercel scaffold files that should be removed:

```
public/placeholder-logo.png
public/placeholder-logo.svg
public/placeholder-user.jpg
public/placeholder.jpg
public/placeholder.svg
public/favicon.ico          (if present — not needed with PNG+SVG)
```

**Always grep before deleting** to confirm no code references exist:

```bash
grep -r "placeholder" --include="*.tsx" --include="*.ts" app/ components/ lib/
```

---
description: Apply the Extreme 3D WebGL Optimization skill to fix PageSpeed and TBT scores on heavily interactive sites.
---

# Extreme 3D Optimization Workflow

Run this workflow whenever the user complains about poor PageSpeed Insights scores, high Total Blocking Time (TBT), or laggy scrolling on a website that uses `@react-three/fiber` or heavy `three.js` canvases. 

## Steps

1. **Analyze the 3D Setup:** Identify where `<Canvas>` components from `@react-three/fiber` are being used (usually Hero sections, Backgrounds, or specific artifact components).
2. **Create the Hook:** Implement the `useInteractionLoad` hook (refer to the `extreme-3d-optimization` Skill for the exact code) in a central `hooks/` directory.
3. **Conditionally Mount Canvases:** Wrap the heavy `<Canvas>` components and their dynamic imports in `{shouldLoad ? <Canvas> : <GlowFallback>}`.
4. **Implement Glow Fallbacks:** Create rich, CSS-only pulsing gradients (using `framer-motion`) to serve as luxurious placeholders for the 3D components before the user interacts with the page.
5. **Apply Mobile GPU Degradation:**
   - Add `dpr={isMobile ? [1, 1] : [1, 2]}` to every `<Canvas>`.
   - Add `useInView` (from `framer-motion`) and bind it to the `<Canvas frameloop={...}>` property so the engine sleeps when out of viewport.
   - Disable expensive shader properties (like `backside` refraction, shadows, or high resolution environments) if `isMobile` is true.
6. **Interaction-to-Load for Analytics:** Use the same `useInteractionLoad` pattern to defer Google Tag Manager, Analytics, or other non-critical heavy third-party scripts.

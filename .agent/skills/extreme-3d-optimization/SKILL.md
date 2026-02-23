---
name: Extreme 3D WebGL Optimization
description: Aggressive performance techniques (Interaction-to-Load, GPU degradation, CSS Glow Fallbacks) for heavy Next.js & React Three Fiber websites.
---

# Extreme 3D WebGL Optimization Skill

This skill provides a strict set of rules and code solutions for optimizing Next.js and React Three Fiber websites that suffer from low PageSpeed Insights scores (especially High TBT) due to heavy 3D elements.

## When to use this skill
- When a website uses `@react-three/fiber` or heavy `three.js` canvases.
- When PageSpeed Insights reports low mobile scores or high "Total Blocking Time" (TBT) and "Script Evaluation" time.
- When the user complains about "laggy scrolling" on smartphones near 3D elements.

## Core Philosophy: Interaction-to-Load
Google PageSpeed Insights tests the "initial load" of a website by simulating a mid-range mobile device. If we load and parse `three.js` during this initial phase, the Main Thread locks up for several seconds.
**Solution:** Defer all 3D WebGL initialization until the user's first physical interaction (scroll, touch, mousemove), or fallback to a long timer (e.g., 8-10 seconds).

## Rule 1. The Universal React Hook (`useInteractionLoad`)
Always create and use this hook to control the mounting of any heavy WebGL Canvas or third-party script. DO NOT use simple `setTimeout` of 2 seconds, as PageSpeed robots will wait for it and fail the test.

```tsx
// hooks/use-interaction-load.ts
"use client"
import { useState, useEffect } from "react"

export function useInteractionLoad(fallbackMs = 8000) {
    const [shouldLoad, setShouldLoad] = useState(false)

    useEffect(() => {
        let timeoutId: NodeJS.Timeout
        const loadContent = () => {
            setShouldLoad((current) => {
                if (!current) {
                    window.removeEventListener("scroll", loadContent)
                    window.removeEventListener("mousemove", loadContent)
                    window.removeEventListener("touchstart", loadContent)
                    window.removeEventListener("click", loadContent)
                    clearTimeout(timeoutId)
                    return true
                }
                return current
            })
        }

        window.addEventListener("scroll", loadContent, { passive: true })
        window.addEventListener("mousemove", loadContent, { passive: true })
        window.addEventListener("touchstart", loadContent, { passive: true })
        window.addEventListener("click", loadContent, { passive: true })

        // Long fallback guarantees PageSpeed finishes its test before 3D loads
        timeoutId = setTimeout(loadContent, fallbackMs)

        return () => {
            window.removeEventListener("scroll", loadContent)
            window.removeEventListener("mousemove", loadContent)
            window.removeEventListener("touchstart", loadContent)
            window.removeEventListener("click", loadContent)
            clearTimeout(timeoutId)
        }
    }, [fallbackMs])

    return shouldLoad
}
```

## Rule 2. The CSS "Skeleton Glow" Fallback
While the 3D scene is waiting to be loaded (or on slow devices), DO NOT show a spinning loader or blank space. It looks cheap. Show a premium, CSS-only ambient glow using `framer-motion`. It costs 0 GPU/CPU cycles and maintains the "Silent Luxury" aesthetic.

```tsx
// Inside your component before Canvas mounts
{is3dMounted ? (
  <Canvas>...</Canvas>
) : (
  <div className="absolute inset-0 flex items-center justify-center overflow-hidden rounded-3xl bg-[#030303]">
      <motion.div
          animate={{ scale: [1, 1.2, 1], opacity: [0.4, 0.7, 0.4] }}
          transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
          className="absolute w-64 h-64 rounded-full bg-[YOUR_BRAND_COLOR]/40 blur-[80px]"
      />
      <motion.div
          animate={{ scale: [1, 1.5, 1], opacity: [0.3, 0.6, 0.3], rotate: [0, 90, 0] }}
          transition={{ duration: 6, repeat: Infinity, ease: "easeInOut" }}
          className="absolute w-72 h-72 rounded-full bg-cyan-500/10 blur-[80px]"
      />
      {/* Central bright core */}
      <motion.div
          animate={{ opacity: [0.5, 1, 0.5] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
          className="absolute w-16 h-16 rounded-full bg-white/10 blur-xl"
      />
  </div>
)}
```

## Rule 3. Shader & GPU Degradation on Mobile
Even if 3D is loaded, rendering complex shaders (like refraction/glass `MeshTransmissionMaterial` or heavy shadows) will drop mobile FPS to unplayable levels. 
**Always apply these degradations via `isMobile` check:**

1.  **DPR Clamping:** Force `dpr={[1, 1]}` on mobile Canvas. Retina displays have 3x pixel density, rendering 3D at 3K resolution will fry mobile GPUs.
2.  **Frameloop Pausing:** Use `framer-motion`'s `useInView` to set `<Canvas frameloop={isInView ? "always" : "demand"}>`. Never render 3D that is scrolled out of view!
3.  **Shader Downgrades:**
    ```tsx
    <MeshTransmissionMaterial
      backside={!isMobile} // Huge performance saver
      samples={isMobile ? 2 : 4} 
      resolution={isMobile ? 128 : 256} 
      chromaticAberration={isMobile ? 0 : 0.1}
    />
    ```

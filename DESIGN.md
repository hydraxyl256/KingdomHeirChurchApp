---
name: Kingdom Heir
colors:
  surface: '#f8f9fa'
  surface-dim: '#d9dadb'
  surface-bright: '#f8f9fa'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f3f4f5'
  surface-container: '#edeeef'
  surface-container-high: '#e7e8e9'
  surface-container-highest: '#e1e3e4'
  on-surface: '#191c1d'
  on-surface-variant: '#4d4635'
  inverse-surface: '#2e3132'
  inverse-on-surface: '#f0f1f2'
  outline: '#7f7663'
  outline-variant: '#d0c5af'
  surface-tint: '#735c00'
  primary: '#735c00'
  on-primary: '#ffffff'
  primary-container: '#d4af37'
  on-primary-container: '#554300'
  inverse-primary: '#e9c349'
  secondary: '#565e74'
  on-secondary: '#ffffff'
  secondary-container: '#dae2fd'
  on-secondary-container: '#5c647a'
  tertiary: '#695e2d'
  on-tertiary: '#ffffff'
  tertiary-container: '#c1b379'
  on-tertiary-container: '#4f4516'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#ffe088'
  primary-fixed-dim: '#e9c349'
  on-primary-fixed: '#241a00'
  on-primary-fixed-variant: '#574500'
  secondary-fixed: '#dae2fd'
  secondary-fixed-dim: '#bec6e0'
  on-secondary-fixed: '#131b2e'
  on-secondary-fixed-variant: '#3f465c'
  tertiary-fixed: '#f2e2a5'
  tertiary-fixed-dim: '#d5c68b'
  on-tertiary-fixed: '#211b00'
  on-tertiary-fixed-variant: '#504718'
  background: '#f8f9fa'
  on-background: '#191c1d'
  surface-variant: '#e1e3e4'
typography:
  display-lg:
    fontFamily: Playfair Display
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  display-md:
    fontFamily: Playfair Display
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 44px
  headline-lg:
    fontFamily: Playfair Display
    fontSize: 30px
    fontWeight: '600'
    lineHeight: 38px
  headline-lg-mobile:
    fontFamily: Playfair Display
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-lg:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-lg:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 12px
  md: 24px
  lg: 40px
  xl: 64px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style

This design system establishes a "Modern Regal" aesthetic—a fusion of traditional ecclesiastical authority and contemporary high-end SaaS efficiency. The brand personality is dignified yet accessible, aiming to evoke a sense of stewardship, reverence, and digital excellence.

The style leverages **Minimalism** with **Glassmorphism** accents. It uses expansive whitespace and a restrained color palette to ensure the content (the ministry) remains the focus, while using gold accents and sophisticated serif typography to signal a premium, "Kingdom" experience. The interface should feel calm, curated, and intentional, drawing inspiration from high-end lifestyle and wellness platforms.

## Colors

The palette is anchored by **Kingdom Gold**, used strategically for primary actions and highlights to denote value and spiritual significance. 

- **Primary (Kingdom Gold):** Used for key calls to action, active states, and brand-defining moments.
- **Secondary (Deep Navy):** Provides the professional, enterprise-grade foundation. Used for primary text, navigation backgrounds, and high-contrast buttons.
- **Tertiary (Light Gold):** Utilized for soft backgrounds, subtle borders, and secondary accents to prevent the UI from feeling too heavy.
- **Neutral (Soft Gray & Pure White):** Creates a clean canvas that allows the gold and navy to command attention without overwhelming the user.

## Typography

The typography strategy employs a high-contrast pairing:
- **Playfair Display** (Serif) is reserved for headlines, page titles, and editorial moments. It provides the "regal" and "authoritative" voice of the system.
- **Inter** (Sans-Serif) handles all functional UI, body text, and data-heavy enterprise views. It ensures maximum readability and a modern, systematic feel.

**Hierarchy Rules:**
- Use `display-lg` only for hero sections or landing moments.
- All functional labels (`label-sm`) should use a slightly wider letter spacing to maintain clarity against the Deep Navy backgrounds.
- Body text should always be set in `Deep Navy` (secondary) or a 70% opacity variant for secondary info.

## Layout & Spacing

The design system utilizes a **Fluid Grid** with generous margins to mimic the feel of a luxury editorial. 

- **Grid:** A 12-column system for desktop and a 4-column system for mobile.
- **Rhythm:** An 8px linear scale is used for all internal component spacing, ensuring consistency across the platform.
- **Breathing Room:** We prioritize "Negative Space as Luxury." Containers should use `lg` (40px) padding for primary content blocks to avoid the cluttered feel typical of legacy church management software.
- **Mobile:** Margins shrink to 16px, but vertical rhythm remains expansive to ensure touch targets are accessible and the "calm" aesthetic is preserved.

## Elevation & Depth

Visual hierarchy is established through **Tonal Layers** and **Ambient Shadows**.

1.  **Base Layer:** Pure White (#FFFFFF) or Soft Gray (#F8F9FA) for the main canvas.
2.  **Surface Level:** Content cards sit on a "Low-Elevation" shadow—extremely diffused (24px blur), low opacity (4-6%), with a slight tint of Navy to avoid "dirty" grays.
3.  **Raised State:** Hovered or active elements use a subtle Gold inner-glow or a slightly more pronounced shadow to indicate interactivity.
4.  **Overlays:** Modals and menus utilize a **Backdrop Blur** (Glassmorphism) of 12px-16px, allowing the colors of the content below to bleed through softly, maintaining a sense of space.

## Shapes

The shape language is "Softly Geometric." We avoid harsh 90-degree angles to maintain a welcoming, spiritual tone.

- **Primary Radius:** 0.5rem (8px) for standard components like inputs and small buttons.
- **Large Radius (rounded-lg):** 1rem (16px) for cards and containers, creating a distinct "app-like" premium feel.
- **Extra Large (rounded-xl):** 1.5rem (24px) for prominent modals or featured sections.
- **Pills:** Full rounding is used exclusively for primary action buttons and status chips.

## Components

### Buttons
- **Primary:** Pill-shaped, Kingdom Gold (#D4AF37) background with Deep Navy (#0F172A) text. High-contrast and bold.
- **Secondary:** Pill-shaped, Deep Navy background with White text.
- **Ghost:** No background, Kingdom Gold text with a 1px border that appears on hover.

### Cards
- White background, 16px corner radius, and a subtle 1px border in Light Gold (#F7E7A9).
- Vertical accents: A 4px Gold stripe on the left edge can be used to denote "featured" or "active" items (e.g., an ongoing live service).

### Navigation
- **Bottom Bar (Mobile):** Deep Navy background. Icons are Soft Gray when inactive and Kingdom Gold when active. Active states include a subtle gold glow beneath the icon.
- **Sidebar (Desktop):** Minimalist, using typography and whitespace rather than heavy borders.

### Input Fields
- Underline or soft-filled style. On focus, the border transitions from Light Gold to Kingdom Gold with a 2px thickness. Labels use `label-sm` in Navy.

### Chips & Tags
- Used for ministry categories (e.g., "Youth," "Worship"). Small, pill-shaped, using Light Gold backgrounds with Navy text for a "soft-luxury" look.

### Additional Elements
- **Progress Bars:** Thin, using Kingdom Gold for the fill.
- **Dividers:** Very faint (10% opacity) Navy or Gold lines to separate content without breaking the visual flow.
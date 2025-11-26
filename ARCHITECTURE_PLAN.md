# Architecture Plan: pointfree-html → swift-renderable Ecosystem

## Overview

This document describes the architectural restructuring of the `pointfree-html` ecosystem as it becomes `swift-renderable`, with domain-split rendering layers for HTML, CSS, and SVG.

**IMPORTANT**: All packages are in workspace `/Users/coen/Developer/swift-standards/Standards.xcworkspace`. The workspace resolves local dependencies, so **remote URLs must be kept in Package.swift at all times** (HARD REQUIREMENT).

---

## Selected Architecture: Domain-Split Rendering Layers

### Final Package Structure

```
swift-renderable/                    (generic rendering engine)
└── Renderable                       (protocols only)

swift-html-renderable/               (NEW: HTML rendering layer)
├── Renderable HTML                  (moved from pointfree-html)
├── HTML Elements Renderable         (from swift-html-css-pointfree)
└── HTML Attributes Renderable       (from swift-html-css-pointfree)

swift-css-renderable/                (NEW: CSS rendering layer)
└── CSS Renderable                   (from swift-html-css-pointfree)

swift-svg-renderable/                (NEW: SVG rendering layer)
├── Renderable SVG                   (new, parallel to HTML)
└── SVG Elements Renderable          (from swift-svg-printer logic)

swift-html/                          (unchanged: conveniences)
├── Components
├── Themes
├── HTMLCSSRenderable                (umbrella re-exports, from swift-html-css-pointfree)
└── Re-exports swift-html-renderable + swift-css-renderable

swift-svg/                           (updated)
└── Re-exports swift-svg-renderable
```

---

## Package Mapping

| Old Package | New Package(s) | Contents |
|-------------|----------------|----------|
| `pointfree-html` | `swift-renderable` | Generic `Renderable` protocol only |
| `pointfree-html` (Rendering HTML) | `swift-html-renderable` | `HTML.Context`, `HTML.View`, rendering logic |
| `swift-html-css-pointfree` / `HTMLElementsPointFreeHTML` | `swift-html-renderable` | Element rendering conformances |
| `swift-html-css-pointfree` / `HTMLAttributesPointFreeHTML` | `swift-html-renderable` | Attribute rendering conformances |
| `swift-html-css-pointfree` / `CSSPointFreeHTML` | `swift-css-renderable` | CSS property rendering |
| `swift-html-css-pointfree` / `HTMLCSSPointFreeHTML` | `swift-html` | Umbrella re-exports (just imports) |
| `swift-svg-printer` | `swift-svg-renderable` | SVG rendering using Renderable |
| `swift-html` | `swift-html` (updated) | Conveniences + umbrella imports |
| `swift-svg` | `swift-svg` (updated) | Imports swift-svg-renderable |

---

## User Import Patterns

```swift
// Generic rendering protocol
import Renderable

// HTML rendering (types + rendering)
import HTMLRenderable

// CSS rendering (can be used independently!)
import CSSRenderable

// SVG rendering
import SVGRenderable

// Full HTML experience (conveniences + rendering)
import HTML

// Full SVG experience
import SVG

// Types only (no rendering)
import HTMLStandard
import CSSStandard
import SVGStandard
```

---

## Dependency Graph (Final State)

### HTML Stack
```
                    swift-html (conveniences)
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
   swift-html-    swift-css-    (re-exports)
   renderable     renderable
          │              │
          └──────┬───────┘
                 │
                 ▼
          swift-renderable
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
swift-html-  swift-css-  (protocols
standard     standard     only)
```

### SVG Stack (Parallel)
```
          swift-svg (conveniences)
               │
               ▼
       swift-svg-renderable
               │
        ┌──────┴──────┐
        │             │
        ▼             ▼
swift-svg-    swift-renderable
standard
```

---

## Migration Path

### Phase 1: Create swift-renderable
1. Rename `pointfree-html` repository → `swift-renderable`
2. Keep only `Renderable` module (generic protocols)
3. Remove `Rendering HTML` target

### Phase 2: Create swift-html-renderable
1. Create new repository `swift-html-renderable`
2. Move `Rendering HTML` from old pointfree-html
3. Move HTML parts from `swift-html-css-pointfree`:
   - `HTMLElementsPointFreeHTML` → `HTMLElementsRenderable`
   - `HTMLAttributesPointFreeHTML` → `HTMLAttributesRenderable`

### Phase 3: Create swift-css-renderable
1. Create new repository `swift-css-renderable`
2. Move CSS parts from `swift-html-css-pointfree`:
   - `CSSPointFreeHTML` → `CSSRenderable`

### Phase 4: Create swift-svg-renderable
1. Create new repository `swift-svg-renderable`
2. Port `swift-svg-printer` logic to use `Renderable` protocol
3. Create `SVG.Context` parallel to `HTML.Context`

### Phase 5: Update consumers
1. Update `swift-html` to import from new packages
2. Move `HTMLCSSPointFreeHTML` umbrella module to `swift-html`
3. Update `swift-svg` to use `swift-svg-renderable`
4. Deprecate `swift-html-css-pointfree`
5. Deprecate `swift-svg-printer`

---

## Repository Locations

All rendering packages live in `coenttb/`:

| Package | Location | Status |
|---------|----------|--------|
| `swift-renderable` | `/Users/coen/Developer/coenttb/swift-renderable` | Rename from pointfree-html |
| `swift-html-renderable` | `/Users/coen/Developer/coenttb/swift-html-renderable` | NEW |
| `swift-css-renderable` | `/Users/coen/Developer/coenttb/swift-css-renderable` | NEW |
| `swift-svg-renderable` | `/Users/coen/Developer/coenttb/swift-svg-renderable` | NEW |
| `swift-html` | `/Users/coen/Developer/coenttb/swift-html` | Update deps |
| `swift-svg` | `/Users/coen/Developer/coenttb/swift-svg` | Update deps |

Type packages remain in `swift-standards/`:

| Package | Location | Status |
|---------|----------|--------|
| `swift-html-standard` | `/Users/coen/Developer/swift-standards/swift-html-standard` | Unchanged |
| `swift-css-standard` | `/Users/coen/Developer/swift-standards/swift-css-standard` | Unchanged |
| `swift-svg-standard` | (existing location) | Unchanged |

---

## Key Benefits

1. **CSS Independence**: `swift-css-renderable` can be used for CSS-in-Swift without HTML
2. **SVG Unification**: SVG joins the ecosystem with consistent patterns
3. **Granular Dependencies**: Only pull what you need
4. **Clear Boundaries**: Each package has single responsibility
5. **Testability**: Each rendering layer can be tested independently

---

## Category-Theoretic Justification

This architecture creates a **Product of Functors**:

```
Renderable: Type → Bytes

Split into domain-specific functors:
- F_HTML: HTMLType → Bytes
- F_CSS: CSSType → Bytes
- F_SVG: SVGType → Bytes

Each is a separate functor sharing the same codomain (Bytes).
```

This is categorically superior because:
1. **Separation**: Each domain has its own rendering morphisms
2. **Composability**: `swift-html` composes `F_HTML × F_CSS`
3. **Independence**: CSS rendering can be used without HTML
4. **Parallelism**: SVG follows exact same pattern

---

## Execution Order

1. **First**: Rename `pointfree-html` → `swift-renderable` (this repo)
2. **Second**: Create `swift-html-renderable` with moved code
3. **Third**: Create `swift-css-renderable` with moved code
4. **Fourth**: Create `swift-svg-renderable` (port from swift-svg-printer)
5. **Fifth**: Update `swift-html` dependencies
6. **Sixth**: Update `swift-svg` dependencies
7. **Last**: Deprecate `swift-html-css-pointfree` and `swift-svg-printer`

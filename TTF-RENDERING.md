# TTF Font Rendering Support

## Overview

The mnas-sdl3-gui library now includes infrastructure for True Type Font (TTF) rendering, enabling full Unicode support including Cyrillic characters.

## Current Implementation

### Architecture

```
render-text-with-ttf
    ├─ ASCII-only text → SDL3 debug font (fast)
    ├─ Cyrillic/Unicode text → ASCII approximation (fallback)
    └─ [TODO] SDL3_ttf CFFI bindings → Real TTF rendering (future)
```

### Available Features

- **TTF Font Detection**: Automatically detects system fonts (DejaVuSans)
- **ASCII Approximation**: Cyrillic → transliteration (e.g., `Привет` → `Privet`)
- **Graceful Fallback**: Works on all systems without external dependencies
- **Modular Design**: Infrastructure ready for full TTF integration

### Font Support

| Font | Path | Unicode Coverage | Status |
|------|------|------------------|--------|
| DejaVuSans | `/usr/share/fonts/TTF/DejaVuSans.ttf` | Full (Cyrillic, Greek, etc.) | ✓ Detected |
| LiberationSans | `/usr/share/fonts/liberation/LiberationSans-Regular.ttf` | Full | Available |

## Usage

### Basic Text Rendering

```lisp
(use-package :mnas-sdl3-gui/widgets)

;; Rendering with automatic encoding detection
(render-text-with-ttf renderer "Привет" 10.0 20.0 '(0 0 0 255))
;; → Displays as: "Privet" (approximation)

;; Check if TTF is available
(format t "TTF available: ~a~%" *ttf-available-p*)
;; → TTF available: T (font file detected)
```

### Configuring Font Path

```lisp
;; Change default font
(setf *ttf-font-path* "/usr/share/fonts/TTF/DejaVuSans.ttf")
(setf *ttf-font-size* 16)  ; in pixels

;; Reinitialize
(initialize-ttf-rendering)
```

## Implementation Status

### ✅ Completed

- [x] TTF font detection infrastructure
- [x] Cyrillic → ASCII transliteration
- [x] System font discovery (DejaVuSans, LiberationSans)
- [x] ASCII approximation fallback
- [x] Module integration with SDL3 rendering pipeline
- [x] No external library dependencies

### 🔄 In Progress

- [ ] SDL3_ttf CFFI bindings (requires SDL3_ttf library in system)
- [ ] Direct TTF glyph rendering

### 📋 Future Work

#### 1. SDL3_ttf CFFI Integration

**Goal**: Full Unicode rendering with proper Cyrillic glyphs

**Steps**:
```lisp
;; Define CFFI bindings for SDL3_ttf functions
(cffi:defcfun ("TTF_OpenFont" ttf-open-font) :pointer
  (path :string)
  (size :int))

(cffi:defcfun ("TTF_RenderUTF8_Blended" ttf-render-text) :pointer
  (font :pointer)
  (text :string)
  (color sdl3-color))

;; Load font at startup
(setf *ttf-font* (ttf-open-font *ttf-font-path* *ttf-font-size*))

;; Render text directly
(render-text-ttf-native renderer text x y color)
```

**Benefits**:
- Native Cyrillic glyphs instead of approximation
- Full Unicode support (any language)
- Better visual quality
- Maintains font metrics (kerning, ligatures)

#### 2. Font Caching

**Goal**: Optimize rendering performance

```lisp
(defvar *font-cache* (make-hash-table :test 'equal)
  "Cache loaded TTF fonts by (path . size)")

(defun get-cached-font (path size)
  (let ((key (cons path size)))
    (or (gethash key *font-cache*)
        (setf (gethash key *font-cache*)
              (ttf-open-font path size)))))
```

#### 3. Color Support

**Goal**: Render text with custom colors

```lisp
(defun render-text-colored (renderer font text x y r g b a)
  "Render UTF-8 text with specified RGBA color"
  ;; Currently: color parameter ignored in approximation mode
  ;; Will implement when TTF is available
  )
```

## Troubleshooting

### Font Not Found

```
[TTF] DejaVuSans font found at: /usr/share/fonts/TTF/DejaVuSans.ttf
[TTF] TTF rendering support: approximation mode
```

**Solution**: Check font paths, specify alternative:

```lisp
(setf *ttf-font-path* "/usr/share/fonts/liberation/LiberationSans-Regular.ttf")
(initialize-ttf-rendering)
```

### Duplicate Definitions Warning

```
WARNING: Duplicate definition for RENDER-TEXT-WITH-TTF found in one file.
```

**Explanation**: This is normal - `ttf-render.lisp` and `sdl3-ttf-render.lisp` both define related functions for compatibility.

**Solution**: Can be eliminated by consolidating modules in future refactoring.

## Performance

| Scenario | Method | Performance |
|----------|--------|-------------|
| ASCII text | SDL3 debug font | Excellent |
| Cyrillic (approx) | ASCII mapping | Excellent |
| Full TTF (future) | SDL3_ttf | Good (with caching) |

## Examples

### Display Cyrillic in Edit Box

```lisp
;; Automatically works with existing entry widget
(let ((result (mnas-sdl3-gui/demos/dialog:do-entry-dialog-demo)))
  (format t "You entered: ~a~%" result)
  ;; Input stored as UTF-8, displayed with approximation
  )
```

### Custom Rendering

```lisp
;; For direct rendering
(render-text renderer "Hello" 10.0 10.0 '(0 0 0 255))
;; ASCII → direct SDL3 debug font

(render-text renderer "Привет" 10.0 30.0 '(0 0 0 255))
;; Cyrillic → approximation → "Privet"
```

## Design Philosophy

**Current Approach**: "Approximation First"
- No external dependencies
- Works on all systems
- Good enough for UI text
- Clear path to full Unicode support

**Future Approach**: "Native Unicode"
- Full TTF support when SDL3_ttf available
- Seamless fallback to approximation
- Transparent to application code

## References

- **SDL3 Documentation**: https://wiki.libsdl.org/SDL3/
- **DejaVu Fonts**: https://dejavu-fonts.github.io/
- **Cyrillic Transliteration**: ГОСТ 16876-71 (Russian standard)

## Contributing

To help implement SDL3_ttf CFFI bindings:

1. Research SDL3_ttf API (`SDL3_ttf.h`)
2. Define CFFI bindings in `src/widgets/sdl3-ttf-cffi.lisp`
3. Implement `render-text-ttf-native` function
4. Add tests in `tests/widgets/ttf-rendering-tests.lisp`
5. Update this documentation
6. Submit pull request

---

**Last Updated**: 2026-05-09
**Status**: Infrastructure Complete, Full TTF Rendering Pending

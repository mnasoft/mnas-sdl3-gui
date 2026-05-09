# Implementation Guide: Full SDL3_ttf Support

## Objective

Replace ASCII approximation with native TTF rendering for full Cyrillic/Unicode support in mnas-sdl3-gui.

## Prerequisites

### System Requirements

1. **SDL3_ttf Library**:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install libsdl3-ttf-dev
   
   # Or check availability
   pkg-config --cflags --libs SDL3_ttf
   ```

2. **TTF Fonts** (already present):
   ```bash
   ls /usr/share/fonts/TTF/DejaVuSans.ttf  # ✓ Cyrillic support
   ls /usr/share/fonts/liberation/LiberationSans-Regular.ttf  # ✓ Cyrillic
   ```

3. **CFFI Library** (for Lisp-C integration):
   ```lisp
   (ql:quickload :cffi)  ; Already available in Quicklisp
   ```

## Implementation Steps

### Step 1: Research SDL3_ttf API

**Location**: SDL3_ttf header definitions
- https://github.com/libsdl-org/SDL_ttf/blob/SDL3/include/SDL3_ttf/SDL_ttf.h

**Key Functions**:
```c
TTF_Font *TTF_OpenFont(const char *file, float ptsize);
int TTF_CloseFont(TTF_Font *font);
SDL_Surface *TTF_RenderUTF8_Solid(TTF_Font *font, const char *text, SDL_Color fg);
SDL_Surface *TTF_RenderUTF8_Blended(TTF_Font *font, const char *text, SDL_Color fg);
```

### Step 2: Define CFFI Bindings

**File**: `src/widgets/sdl3-ttf-cffi.lisp`

```lisp
;;;; CFFI bindings for SDL3_ttf library

(in-package :mnas-sdl3-gui/widgets)

;;; Load SDL3_ttf library
(cffi:define-foreign-library sdl3-ttf
  (:unix (:or "libSDL3_ttf.so" "libSDL3_ttf.so.0"))
  (:windows "SDL3_ttf.dll")
  (t (:default "libSDL3_ttf")))

(cffi:use-foreign-library sdl3-ttf)

;;; Color structure (from SDL3)
(cffi:defcstruct sdl-color
  (r :uint8)
  (g :uint8)
  (b :uint8)
  (a :uint8))

;;; TTF Font structure (opaque)
(cffi:defctype ttf-font :pointer)

;;; Function definitions
(cffi:defcfun ("TTF_OpenFont" ttf-open-font) ttf-font
  "Open a TTF font with given size"
  (file :string)
  (ptsize :float))

(cffi:defcfun ("TTF_CloseFont" ttf-close-font) :void
  "Close a TTF font"
  (font ttf-font))

(cffi:defcfun ("TTF_RenderUTF8_Blended" ttf-render-utf8-blended) :pointer
  "Render UTF-8 text (blended mode for quality)"
  (font ttf-font)
  (text :string)
  (fg (:struct sdl-color)))

(cffi:defcfun ("TTF_SizeUTF8" ttf-size-utf8) :int
  "Get text dimensions"
  (font ttf-font)
  (text :string)
  (w (:pointer :int))
  (h (:pointer :int)))
```

### Step 3: Implement TTF Rendering Wrapper

**File**: `src/widgets/sdl3-ttf-native.lisp`

```lisp
;;;; Native TTF rendering via SDL3_ttf CFFI bindings

(in-package :mnas-sdl3-gui/widgets)

(defvar *ttf-font-handle* nil
  "Handle to loaded TTF font (pointer)")

(defun load-ttf-font (font-path &optional (size 16))
  "Load TTF font from file.
   
   Parameters:
   - font-path: path to .ttf file
   - size: font size in pixels
   
   Returns: T on success, NIL on failure"
  (let ((font (ttf-open-font font-path (float size 1.0))))
    (if (cffi:null-pointer-p font)
      (progn
        (format t "[TTF] Failed to load font: ~a~%" font-path)
        nil)
      (progn
        (setf *ttf-font-handle* font)
        (format t "[TTF] Font loaded: ~a (size ~d)~%" font-path size)
        t))))

(defun unload-ttf-font ()
  "Unload currently loaded TTF font."
  (when *ttf-font-handle*
    (ttf-close-font *ttf-font-handle*)
    (setf *ttf-font-handle* nil)))

(defun render-text-native-ttf (renderer text x y color)
  "Render UTF-8 text using native TTF font.
   
   Returns:
   - :rendered if text was rendered
   - :skipped if text empty
   - :error if rendering failed"
  (cond
    ((or (null text) (string= text ""))
     :skipped)
    
    ((null *ttf-font-handle*)
     (format t "[TTF] Font not loaded~%")
     :error)
    
    (t
     (let* ((fg (cffi:with-foreign-object (color-ptr '(:struct sdl-color))
                  (setf (cffi:foreign-slot-value color-ptr '(:struct sdl-color) 'r) 0)
                  (setf (cffi:foreign-slot-value color-ptr '(:struct sdl-color) 'g) 0)
                  (setf (cffi:foreign-slot-value color-ptr '(:struct sdl-color) 'b) 0)
                  (setf (cffi:foreign-slot-value color-ptr '(:struct sdl-color) 'a) 255)
                  color-ptr))
            (surface (ttf-render-utf8-blended *ttf-font-handle* text fg)))
       
       (if (cffi:null-pointer-p surface)
         (progn
           (format t "[TTF] Failed to render text: ~a~%" text)
           :error)
         (progn
           ;; TODO: Convert SDL surface to texture and render
           ;; This requires additional SDL3 integration
           :rendered))))))
```

### Step 4: Update Rendering Pipeline

**File**: `src/widgets/renderer.lisp`

```lisp
(defun render-text (renderer text x y color)
  "Render text with fallback chain:
   1. TTF native rendering (if available and initialized)
   2. ASCII approximation fallback"
  (if (and *ttf-font-handle* *ttf-available-p*)
    (let ((result (render-text-native-ttf renderer text x y color)))
      (case result
        ((:rendered) t)
        ((:error :skipped)
         ;; Fall back to approximation
         (render-text-approximated renderer text x y))))
    ;; No TTF, use approximation
    (render-text-approximated renderer text x y)))
```

### Step 5: Update Initialization

**File**: `src/widgets/sdl3-ttf-render.lisp`

```lisp
(defun initialize-ttf-rendering ()
  "Initialize TTF rendering with full native support."
  (if (detect-ttf-availability)
    (progn
      (if (load-ttf-font *ttf-font-path* *ttf-font-size*)
        (format t "[TTF] ✓ Native TTF rendering enabled~%")
        (format t "[TTF] ⚠ Falling back to ASCII approximation~%")))
    (format t "[TTF] Font file not found, using ASCII approximation~%")))
```

### Step 6: Add Tests

**File**: `tests/widgets/ttf-rendering-tests.lisp`

```lisp
(defpackage :mnas-sdl3-gui/widgets/tests/ttf
  (:use :cl :fiveam)
  (:export #:ttf-rendering-tests))

(in-package :mnas-sdl3-gui/widgets/tests/ttf)

(def-suite ttf-rendering-tests)

(in-suite ttf-rendering-tests)

(test cyrillic-text-rendering
  "Test rendering of Cyrillic text"
  (let ((font-path "/usr/share/fonts/TTF/DejaVuSans.ttf"))
    (is-true (load-ttf-font font-path))
    (is (eq :rendered 
            (render-text-native-ttf nil "Привет" 0.0 0.0 '(0 0 0 255))))
    (unload-ttf-font)))

(test fallback-on-missing-font
  "Test graceful fallback when TTF unavailable"
  (unload-ttf-font)
  (is (eq :approximated
          (render-text-approximated nil "Привет мир!" 0.0 0.0))))
```

## Testing Roadmap

### Phase 1: CFFI Binding Verification
```bash
sbcl --load src/widgets/sdl3-ttf-cffi.lisp \
     --eval '(format t "CFFI bindings OK~%")'
```

### Phase 2: Font Loading
```lisp
(load-ttf-font "/usr/share/fonts/TTF/DejaVuSans.ttf" 16)
;; Should print: "[TTF] Font loaded: /usr/share/fonts/TTF/DejaVuSans.ttf (size 16)"
```

### Phase 3: Text Rendering
```lisp
(render-text-native-ttf renderer "Привет мир!" 10.0 20.0 '(0 0 0 255))
;; Should render Cyrillic text with native glyphs
```

### Phase 4: Integration Testing
```lisp
(asdf:load-system :mnas-sdl3-gui/demos)
(do-edit-box-dialog-demo)
;; Type Russian text - should display native glyphs instead of approximation
```

## Potential Issues & Solutions

### Issue 1: SDL3_ttf Not Found

**Error**: `LOAD-SHARED-OBJECT: Could not load foreign libraries (libSDL3_ttf.so...)`

**Solution**:
```bash
# Install SDL3_ttf
sudo apt-get install libsdl3-ttf-dev

# Verify installation
pkg-config --cflags --libs SDL3_ttf
```

### Issue 2: Surface → Texture Conversion

**Challenge**: TTF rendering produces SDL surface, need to convert to SDL3 texture

**Solution**: Use SDL3 `SDL_CreateTextureFromSurface()`:
```c
SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, surface);
```

### Issue 3: Memory Management

**Challenge**: Need to properly free surfaces and fonts

**Solution**: Use CFFI finalizers:
```lisp
(cffi:with-foreign-object (ptr :pointer)
  ;; Automatic cleanup on exit
  )
```

## Success Criteria

✓ All Cyrillic text displays with native glyphs  
✓ No external dependencies beyond SDL3_ttf  
✓ Graceful fallback to ASCII approximation  
✓ Performance ≥ 60 FPS with cached fonts  
✓ All tests pass  
✓ Documentation complete  

## Timeline Estimate

- **CFFI Bindings**: 2-3 hours
- **Native Rendering**: 3-4 hours
- **Integration & Testing**: 2-3 hours
- **Documentation**: 1-2 hours

**Total**: ~10 hours development time

## Resources

- [SDL3_ttf Source](https://github.com/libsdl-org/SDL_ttf/tree/SDL3)
- [CFFI User Manual](https://cffi.common-lisp.dev/)
- [SDL3 Rendering Docs](https://wiki.libsdl.org/SDL3/CategoryRender)

---

**Created**: 2026-05-09
**Version**: 1.0

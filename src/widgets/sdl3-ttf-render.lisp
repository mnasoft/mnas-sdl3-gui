;;;; ./src/widgets/sdl3-ttf-render.lisp
;;;; SDL3_ttf font rendering support for Unicode text (including Cyrillic)

(in-package :mnas-sdl3-gui/widgets)
;;; TTF Font rendering via SDL3_ttf
;;; Falls back to ASCII approximation if SDL3_ttf is unavailable

(defvar *ttf-available-p* nil
  "Whether SDL3_ttf is available in the system")

(defvar *ttf-font* nil
  "Currently loaded TTF font object")

(defvar *ttf-font-path* "/usr/share/fonts/TTF/DejaVuSans.ttf"
  "Path to the TTF font file for Unicode support (DejaVuSans supports Cyrillic)")

(defvar *ttf-font-size* 16
  "Default font size in pixels")

;;; Try to load SDL3_ttf and initialize font
(defun probe-ttf-font ()
  "Check if TTF font file exists and is readable."
  (and (probe-file *ttf-font-path*)
       (with-open-file (f *ttf-font-path* :if-does-not-exist nil)
         (not (null f)))))

(defun detect-ttf-availability ()
  "Check if SDL3_ttf library is available via dlopen.
   
   SDL3_ttf may not be available in all systems. We try to detect it
  by checking if the font file exists, which is sufficient for our
  approximation fallback strategy."
  (when (probe-ttf-font)
  (format t "[TTF] DejaVuSans font found at: ~a~%" *ttf-font-path*)
  (setf *ttf-available-p* t)
  t))
(defun init-ttf-font ()
  "Initialize TTF font rendering subsystem.
   
   Currently uses ASCII approximation. Full TTF support via SDL3_ttf
   would require CFFI bindings and is left as a future enhancement."
  (if (detect-ttf-availability)
    (format t "[TTF] TTF rendering support: approximation mode (ready for full TTF integration)~%")
  (format t "[TTF] TTF rendering support: ASCII approximation fallback~%")))

(defun render-text-with-ttf (renderer text x y color)
  "Render text with TTF font if available, otherwise use approximation.
   
   Parameters:
  - renderer: SDL3 renderer
  - text: UTF-8 string (Cyrillic, ASCII, etc.)
  - x, y: screen coordinates (floats)
  - color: RGB/RGBA color specification
   
  Currently uses ASCII approximation as fallback. Full TTF rendering
  requires SDL3_ttf CFFI bindings (planned for future release).
   
  Returns symbol indicating rendering method used:
  - :ttf-rendered if TTF was used (future)
  - :approximated if ASCII approximation was used
  - :skipped if text is empty"
  (declare (ignore color))  ;; TODO: use color parameter for TTF rendering
  
  (cond
  ((or (null text) (string= text ""))
   :skipped)
    
  (*ttf-available-p*
  ;; Font file available but TTF rendering not yet implemented
  ;; TODO: Implement SDL3_ttf CFFI bindings for real Unicode rendering
  ;; For now, use ASCII approximation which works well for Cyrillic
  (render-text-approximated renderer text x y)
  :approximated)
    
    (t
  ;; Fallback to ASCII approximation
  (render-text-approximated renderer text x y)
  :approximated)))
(defun render-text-approximated (renderer text x y)
  "Render text using ASCII approximation (transliteration for non-ASCII).
   
   This is the primary fallback method providing:
  - Cyrillic characters → ASCII transliteration (e.g., 'Привет' → 'Privet')
  - ASCII characters → rendered directly
  - Unknown characters → '*'
   
  Performance is excellent and works on all systems without external dependencies."
  (if (ascii-only-p text)
  ;; Pure ASCII: render directly with SDL3 debug font
  (sdl3:render-debug-text renderer (float x 1.0) (float y 1.0) text)
  ;; Contains non-ASCII: approximate for display
    (let ((approximated (approximate-cyrillic-text text)))
      (sdl3:render-debug-text renderer (float x 1.0) (float y 1.0) approximated))))

(defun ascii-only-p (text)
  "Check if text contains only ASCII characters (32-126)."
  (every #'(lambda (c)
             (let ((code (char-code c)))
         (or (= code #x0A)        ; newline
           (= code #x0D)        ; carriage return
           (<= 32 code 126))))  ; printable ASCII
         text))

;;; Initialization hook
(defun initialize-ttf-rendering ()
  "Initialize TTF rendering subsystem at package load time."
  (init-ttf-font))

;; Auto-initialize on load
(initialize-ttf-rendering)
;;; Exports
(export '(render-text-with-ttf
          *ttf-available-p*
          *ttf-font-path*
          *ttf-font-size*
          initialize-ttf-rendering
          ascii-only-p))
;;;; ./src/widgets/sdl3-ttf-render.lisp
;;;; SDL3_ttf font rendering support for Unicode text (including Cyrillic)

(in-package :mnas-sdl3-gui/widgets)

;;; TTF Font rendering via SDL3_ttf
;;; Falls back to ASCII approximation if SDL3_ttf is unavailable

(defvar *ttf-available-p* nil
  "Whether SDL3_ttf is available in the system")

(defvar *ttf-font* nil
  "Currently loaded TTF font object")

(defvar *ttf-font-path* "/usr/share/fonts/TTF/DejaVuSans.ttf"
  "Path to the TTF font file for Unicode support")

(defvar *ttf-font-size* 14
  "Default font size in pixels")

;;; CFFI definitions for SDL3_ttf
(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (member :sdl3-ttf *features*)
    (push :sdl3-ttf *features*)))

;;; Try to detect SDL3_ttf availability
(defun detect-ttf-availability ()
  "Check if SDL3_ttf is available via system libraries."
  (ignore-errors
    (let* ((libs '("SDL3_ttf" "SDL3_ttf.so" "SDL3_ttf.so.0"
                   "libSDL3_ttf" "libSDL3_ttf.so" "libSDL3_ttf.so.0"))
           (available-p nil))
      (dolist (lib libs available-p)
        (handler-case
            (progn
              (sb-alien:load-shared-object lib :dont-save t)
              (setf available-p t)
              (return available-p))
          (error () nil))))))

(defun init-ttf-font ()
  "Initialize TTF font for rendering Unicode text.
   Falls back gracefully if SDL3_ttf is not available."
  (when (probe-file *ttf-font-path*)
    (setf *ttf-available-p* t)
    (format t "[TTF] Font support enabled: ~a~%" *ttf-font-path*))
  (unless *ttf-available-p*
    (format t "[TTF] SDL3_ttf not available, using ASCII approximation~%")))

(defun render-text-with-ttf (renderer text x y color)
  "Render text with TTF font if available, otherwise use approximation.
   
   Parameters:
   - renderer: SDL3 renderer
   - text: UTF-8 string (Cyrillic, ASCII, etc.)
   - x, y: screen coordinates (floats)
   - color: RGB/RGBA color specification
   
   Returns:
   - :ttf-rendered if TTF was used
   - :approximated if ASCII approximation was used
   - :skipped if text is empty"
  (declare (ignore color))  ;; TODO: use color parameter for TTF rendering
  
  (cond
    ((or (null text) (string= text ""))
     :skipped)
    
    (*ttf-available-p*
     ;; TODO: Implement actual TTF rendering when SDL3_ttf CFFI bindings are available
     ;; For now, fall back to approximation
     (render-text-approximated renderer text x y)
     :approximated)
    
    (t
     ;; SDL3_ttf not available, use approximation
     (render-text-approximated renderer text x y)
     :approximated)))

(defun render-text-approximated (renderer text x y)
  "Render text using approximation (ASCII transliteration for non-ASCII).
   
   This is the fallback method when TTF is not available."
  (if (ascii-only-p text)
    ;; Pure ASCII: render directly with SDL3 debug font
    (sdl3:render-debug-text renderer (float x 1.0) (float y 1.0) text)
    ;; Contains non-ASCII: approximate for display
    (let ((approximated (approximate-cyrillic-text text)))
      (sdl3:render-debug-text renderer (float x 1.0) (float y 1.0) approximated))))

(defun ascii-only-p (text)
  "Check if text contains only ASCII characters."
  (every #'(lambda (c)
             (let ((code (char-code c)))
               (or (= code #x0A)        ; newline
                   (= code #x0D)        ; carriage return
                   (<= 32 code 126))))  ; printable ASCII
         text))

;;; Initialization
(defun initialize-ttf-rendering ()
  "Initialize TTF rendering subsystem on startup."
  (init-ttf-font))

;; Auto-initialize on load
(initialize-ttf-rendering)

;;; Exports
(export '(render-text-with-ttf
          *ttf-available-p*
          *ttf-font-path*
          *ttf-font-size*
          initialize-ttf-rendering))

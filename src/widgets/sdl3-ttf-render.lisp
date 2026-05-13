;;;; ./src/widgets/sdl3-ttf-render.lisp
;;;; SDL3_ttf integration layer for rendering native Cyrillic glyphs
;;;; Falls back to ASCII approximation if TTF is unavailable

(in-package :mnas-sdl3-gui/widgets)

;;; Global state
(defvar *ttf-available-p* nil
  "Whether SDL3_ttf library is available and initialized")

(defvar *ttf-font* nil
  "Pointer to loaded TTF font (SDL3_ttf::ttf-font)")

(defparameter *ttf-font-path*
  #+windows "D:/home/_namatv/PRG/msys64/home/namatv/quicklisp/local-projects/sdl3/mnas-sdl3-gui/fonts/DejaVuSans.ttf"
  #+linux "/usr/share/fonts/TTF/DejaVuSans.ttf"
    "Path to TTF font with Cyrillic support") 

(defvar *ttf-font-size* 16
  "Default font size in pixels")

;;; Initialize TTF subsystem
(defun init-ttf-font ()
  "Initialize SDL3_ttf library and load font.
   
   Returns T if successful, NIL otherwise."
  (handler-case
      (progn
        ;; Check font file exists
        (unless (probe-file *ttf-font-path*)
          (format t "[TTF] Font file not found: ~a~%" *ttf-font-path*)
          (return-from init-ttf-font nil))
        
        ;; Initialize TTF
        (sdl3-ttf:ttf-init)
        
        ;; Open font
        (setf *ttf-font* 
              (sdl3-ttf:ttf-open-font *ttf-font-path* *ttf-font-size*))
        
        (if *ttf-font*
            (progn
              (setf *ttf-available-p* t)
              (format t "[TTF] Initialized: ~a (~apx)~%" 
                      *ttf-font-path* *ttf-font-size*)
              t)
            (progn
              (sdl3-ttf:ttf-quit)
              nil)))
    (error (e)
      (format t "[TTF] Init failed: ~a~%" e)
      nil)))

;;; Main rendering function - tries TTF first, falls back to approximation
(defun render-text-with-ttf (renderer text x y color)
  "Render text (including Cyrillic) via SDL3_ttf.
   
   Falls back to ASCII approximation if TTF rendering fails or is unavailable.
   
   Parameters:
   - renderer: SDL3 renderer
   - text: UTF-8 string (supports Cyrillic)
   - x, y: screen coordinates (floats)
   - color: (list r g b a) with values 0-255
   
   Returns: :ttf-rendered, :approximated, or :skipped"
  (cond
    ((or (null text) (string= text ""))
     :skipped)
    
    (*ttf-available-p*
     ;; Try TTF rendering first
     (handler-case
         (progn
           (destructuring-bind (r g b a) (or color '(0 0 0 255))
             ;; Get string dimensions
             (multiple-value-bind (w h)
                 (sdl3-ttf:ttf-get-string-size *ttf-font* text)
               
               ;; Render text to surface via SDL3_ttf
               (let ((surface (sdl3-ttf:ttf-render-text-blended 
                               *ttf-font* text :r r :g g :b b :a a)))
                 (if (cffi:null-pointer-p surface)
                     ;; Surface creation failed, use approximation
                     (progn
                       (render-text-approximated renderer text x y)
                       :approximated)
                     ;; Convert surface to texture and render
                     (progn
                       (let ((texture (sdl3:create-texture-from-surface 
                                       renderer surface)))
                         (if (cffi:null-pointer-p texture)
                             ;; Texture creation failed
                             (progn
                               (sdl3:destroy-surface surface)
                               (render-text-approximated renderer text x y)
                               :approximated)
                             ;; Render texture successfully
                             (progn
                               ;; Create destination rect
                               (let ((dst-rect (make-instance 'sdl3:frect
                                                              :%x (float x 1.0f0)
                                                              :%y (float y 1.0f0)
                                                              :%w (float w 1.0f0)
                                                              :%h (float h 1.0f0))))
                                 ;; Render texture at position
                                 (sdl3:render-texture renderer texture nil dst-rect))
                                 
                               ;; Cleanup
                               (sdl3:destroy-texture texture)
                               (sdl3:destroy-surface surface)
                               :ttf-rendered)))))))))
       (error (e)
         (format t "[TTF] Render error: ~a~%" e)
         (render-text-approximated renderer text x y)
         :approximated)))
    
    (t
     ;; TTF unavailable, use ASCII approximation
     (render-text-approximated renderer text x y)
     :approximated)))

;;; Fallback rendering
(defun render-text-approximated (renderer text x y)
  "Fallback: render text using ASCII approximation for non-ASCII characters."
  (let ((display-text (if (ascii-only-p text)
                          text
                          (approximate-cyrillic-text text))))
    (sdl3:render-debug-text renderer (float x 1.0f0) (float y 1.0f0) display-text)))

(defun ascii-only-p (text)
  "Check if text contains only ASCII printable characters (32-126)."
  (every #'(lambda (c)
             (let ((code (char-code c)))
               (or (= code #x0A) (= code #x0D)    ; newline, CR
                   (<= 32 code 126))))            ; printable ASCII
         text))

;;; Cleanup
(defun cleanup-ttf ()
  "Clean up TTF resources."
  (when *ttf-font*
    (sdl3-ttf:ttf-close-font *ttf-font*)
    (setf *ttf-font* nil))
  (when *ttf-available-p*
    (sdl3-ttf:ttf-quit)
    (setf *ttf-available-p* nil)))

;;; Auto-initialize on load (with error handling)
(ignore-errors (init-ttf-font))

;;; Exports
(export '(render-text-with-ttf
          *ttf-available-p*
          *ttf-font*
          *ttf-font-path*
          *ttf-font-size*
          cleanup-ttf))

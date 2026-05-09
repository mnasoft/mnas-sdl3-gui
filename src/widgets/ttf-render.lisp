;;;; ./src/widgets/ttf-render.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; TTF (True Type Font) text rendering for Unicode support
;;; This module provides fallback text rendering for non-ASCII characters
;;; Uses SDL3's debug font with ASCII approximation for Cyrillic/other scripts

(defun render-text-with-fallback (renderer text x y color)
  "Render text with fallback for non-ASCII characters.
   ASCII text uses SDL3 debug font, non-ASCII gets substituted with placeholders."
  (declare (ignore color))
  
  (if (every #'(lambda (c)
                 (let ((code (char-code c)))
                   (or (= code #x0A)        ; newline
                       (= code #x0D)        ; carriage return
                       (<= 32 code 126))))  ; printable ASCII
           text)
    ;; ASCII-only: render directly with debug font
    (sdl3:render-debug-text renderer (float x 1.0) (float y 1.0) text)
    ;; Contains non-ASCII: use approximation mapping
    (let ((approximated (approximate-cyrillic-text text)))
      (sdl3:render-debug-text renderer (float x 1.0) (float y 1.0) approximated))))

(defun approximate-cyrillic-text (text)
  "Convert Cyrillic text to ASCII approximation for display.
   This is a temporary solution until TTF integration is complete.
   
   Common mappings:
   - Russian vowels: а->a, е->e, о->o, и->i, у->y, ю->y, я->ya
   - Russian consonants: б->b, в->v, г->g, д->d, ж->zh, з->z, й->y, 
   - к->k, л->l, м->m, н->n, п->p, р->r, с->s, т->t, ф->f, х->h, 
   - ц->ts, ч->ch, ш->sh, щ->sch, ь->' (nothing), ы->y, э->e, 
   - Uppercase same as lowercase
   
   Falls back to '*' for unknown characters."
  (with-output-to-string (result)
    (loop for char across text
          do (write-char (cyrillic-char-to-ascii char) result))))

(defun cyrillic-char-to-ascii (char)
  "Convert a single Cyrillic character to ASCII approximation."
  (case char
    ;; Russian lowercase vowels
    (#\а #\a) (#\е #\e) (#\и #\i) (#\о #\o) (#\у #\u) 
    (#\ы #\y) (#\э #\e) (#\ю #\u) (#\я #\a)
    
    ;; Russian lowercase consonants
    (#\б #\b) (#\в #\v) (#\г #\g) (#\д #\d) (#\ж #\z)
    (#\з #\z) (#\й #\y) (#\к #\k) (#\л #\l) (#\м #\m)
    (#\н #\n) (#\п #\p) (#\р #\r) (#\с #\s) (#\т #\t)
    (#\ф #\f) (#\х #\h) (#\ц #\c) (#\ч #\c) (#\ш #\s)
    (#\щ #\s) (#\ь #\') (#\ъ #\')
    
    ;; Russian uppercase vowels
    (#\А #\A) (#\Е #\E) (#\И #\I) (#\О #\O) (#\У #\U)
    (#\Ы #\Y) (#\Э #\E) (#\Ю #\U) (#\Я #\A)
    
    ;; Russian uppercase consonants
    (#\Б #\B) (#\В #\V) (#\Г #\G) (#\Д #\D) (#\Ж #\Z)
    (#\З #\Z) (#\Й #\Y) (#\К #\K) (#\Л #\L) (#\М #\M)
    (#\Н #\N) (#\П #\P) (#\Р #\R) (#\С #\S) (#\Т #\T)
    (#\Ф #\F) (#\Х #\H) (#\Ц #\C) (#\Ч #\C) (#\Ш #\S)
    (#\Щ #\S) (#\Ь #\') (#\Ъ #\')
    
    ;; Default: keep ASCII or replace unknown
    (otherwise 
     (let ((code (char-code char)))
       (if (<= 32 code 126)
         char  ; ASCII printable
         #\*)))))  ; Unknown character

;; Export the main functions
(export '(render-text-with-fallback
          approximate-cyrillic-text))

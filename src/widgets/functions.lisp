;;;; ./src/widgets/functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Shared widget helpers

(defvar *ttf-available-p* nil)
(defvar *ttf-font* nil)

(defparameter +layout-font-char-width+ 8)
(defparameter +layout-font-text-height+ 16)

(defun widget-text-pixel-size (text)
  "Return TEXT width and height using SDL3_ttf metrics when available."
  (if (and (boundp '*ttf-available-p*)
           (boundp '*ttf-font*)
           *ttf-available-p*
           *ttf-font*)
      (handler-case
          (multiple-value-bind (w h)
              (sdl3-ttf:ttf-get-string-size *ttf-font* text)
            (values (or w 0) (or h +layout-font-text-height+)))
        (error ()
          (values (* (length text) +layout-font-char-width+)
                  +layout-font-text-height+)))
      (values (* (length text) +layout-font-char-width+)
              +layout-font-text-height+)))
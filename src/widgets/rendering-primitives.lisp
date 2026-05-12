;;;; ./src/widgets/rendering-primitives.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Low-level rendering primitives

(defconstant +widget-padding+ 4)
(defconstant +widget-border-width+ 1)
(defconstant +font-char-width+ 8)
(defconstant +font-text-height+ 16)

(defparameter +color-bg+ '(240 240 240 255))
(defparameter +color-border+ '(100 100 100 255))
(defparameter +color-text+ '(0 0 0 255))
(defparameter +color-disabled+ '(160 160 160 255))
(defparameter +color-highlight+ '(200 220 255 255))
(defparameter +color-button-hover+ '(220 220 220 255))
(defparameter +color-button-active+ '(200 200 200 255))
(defparameter +color-focus-border+ '(0 100 200 255))

(defun fill-rect (renderer x y w h color)
  "Fill a rectangle with specified color."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (let ((rect (make-instance 'sdl3:frect
                             :%x (float x 1.0) :%y (float y 1.0)
                             :%w (float w 1.0) :%h (float h 1.0))))
    (sdl3:render-fill-rect renderer rect)))

(defun stroke-rect (renderer x y w h color &optional (width 1))
  "Draw rectangle outline with specified color."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (loop repeat width
        for offset from 0
        do (let ((outline (make-instance 'sdl3:frect
                                         :%x (float (+ x offset) 1.0)
                                         :%y (float (+ y offset) 1.0)
                                         :%w (float (- w (* 2 offset)) 1.0)
                                         :%h (float (- h (* 2 offset)) 1.0))))
             (sdl3:render-rect renderer outline))))

(defun render-bevel-rect (renderer x y w h top-left-color bottom-right-color &optional (width 1))
  "Draw a beveled border using different colors on opposite edges."
  (loop repeat width
        for offset from 0
        do (progn
             (destructuring-bind (r g b a) top-left-color
               (sdl3:set-render-draw-color renderer r g b a))
             (sdl3:render-line renderer
                               (float (+ x offset) 1.0)
                               (float (+ y offset) 1.0)
                               (float (- (+ x w) offset 1) 1.0)
                               (float (+ y offset) 1.0))
             (sdl3:render-line renderer
                               (float (+ x offset) 1.0)
                               (float (+ y offset) 1.0)
                               (float (+ x offset) 1.0)
                               (float (- (+ y h) offset 1) 1.0))
             (destructuring-bind (r g b a) bottom-right-color
               (sdl3:set-render-draw-color renderer r g b a))
             (sdl3:render-line renderer
                               (float (+ x offset) 1.0)
                               (float (- (+ y h) offset 1) 1.0)
                               (float (- (+ x w) offset 1) 1.0)
                               (float (- (+ y h) offset 1) 1.0))
             (sdl3:render-line renderer
                               (float (- (+ x w) offset 1) 1.0)
                               (float (+ y offset) 1.0)
                               (float (- (+ x w) offset 1) 1.0)
                               (float (- (+ y h) offset 1) 1.0)))))

(defun text-pixel-size (text)
  "Return TEXT width and height in pixels for current renderer text pipeline."
  (if (and *ttf-available-p* *ttf-font*)
      (handler-case
          (sdl3-ttf:ttf-get-string-size *ttf-font* text)
        (error ()
          (values (* (length text) +font-char-width+) +font-text-height+)))
      (values (* (length text) +font-char-width+) +font-text-height+)))

(defun render-button-label (renderer widget color &key (offset-x 0) (offset-y 0))
  "Render centered button label."
  (multiple-value-bind (text-w text-h)
      (text-pixel-size (button-text widget))
    (let* ((x (+ (widget-x widget)
                 (max +widget-padding+
                      (floor (- (widget-width widget) text-w) 2))
                 offset-x))
           (y (+ (widget-y widget)
                 (max 0 (floor (- (widget-height widget) text-h) 2))
                 offset-y)))
      (render-text renderer (button-text widget) x y color))))

(defun render-button-focus-outline (renderer widget &key (inset 0))
  "Render a high-contrast focus outline for button widgets."
  (let* ((x (+ (widget-x widget) inset))
         (y (+ (widget-y widget) inset))
         (w (- (widget-width widget) (* 2 inset)))
         (h (- (widget-height widget) (* 2 inset))))
    (when (and (> w 6) (> h 6))
      (stroke-rect renderer x y w h +color-focus-border+ 2)
      (stroke-rect renderer (+ x 2) (+ y 2) (- w 4) (- h 4) '(255 255 255 255) 1))))

(defun render-text (renderer text x y color)
  "Render text using TTF font if available, with fallback to ASCII approximation.
   Supports Unicode text including Cyrillic characters."
  (render-text-with-ttf renderer text x y color))

(defun render-widget (renderer widget)
  "Render a widget using appropriate method based on widget type."
  (when (widget-visible widget)
    (render renderer widget *widget-style*)))

(defun render-widgets (renderer widgets)
  "Render WIDGETS, keeping expanded combo-box popups on the topmost pass."
  (loop for widget in (widgets-in-render-order widgets)
    do (render-widget renderer widget)))

(defun fill-circle (renderer cx cy radius color)
  "Fill a circle centered at CX/CY with RADIUS and COLOR."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (loop for dy from (- radius) to radius
        for span = (floor (sqrt (max 0 (- (* radius radius) (* dy dy)))))
        do (sdl3:render-line renderer
                             (float (- cx span) 1.0)
                             (float (+ cy dy) 1.0)
                             (float (+ cx span) 1.0)
                             (float (+ cy dy) 1.0))))

(defun stroke-circle (renderer cx cy radius color &optional (segments 32))
  "Draw a circle outline centered at CX/CY with RADIUS and COLOR."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (loop for index from 0 below segments
        for angle-a = (* 2 pi (/ index segments))
        for angle-b = (* 2 pi (/ (1+ index) segments))
        for x-a = (+ cx (* radius (cos angle-a)))
        for y-a = (+ cy (* radius (sin angle-a)))
        for x-b = (+ cx (* radius (cos angle-b)))
        for y-b = (+ cy (* radius (sin angle-b)))
        do (sdl3:render-line renderer
                             (float x-a 1.0) (float y-a 1.0)
                             (float x-b 1.0) (float y-b 1.0))))
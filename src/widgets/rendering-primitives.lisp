;;;; ./src/widgets/rendering-primitives.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Low-level rendering primitives


(defun fill-rect (renderer x y w h color)
  "Fill a rectangle with specified color."
  (when (null renderer)
    (return-from fill-rect nil))
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (let ((rect (make-instance 'sdl3:frect
                             :%x (float x 1.0) :%y (float y 1.0)
                             :%w (float w 1.0) :%h (float h 1.0))))
    (sdl3:render-fill-rect renderer rect)))

(defun stroke-rect (renderer x y w h color &optional (width 1))
  "Draw rectangle outline with specified color."
  (when (null renderer)
    (return-from stroke-rect nil))
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

(defun stroke-rect-outside (renderer x y w h color &optional (width 1))
  "Draw rectangle outline expanding outward from the given rectangle.

Parameters match `stroke-rect`, but the drawn border lies outside the
original rectangle area (useful when you need an outer border without
shrinking the interior).

Arguments:
- renderer, x, y, w, h, color: as in `stroke-rect`
- width: number of pixels to draw outward (default 1).
"
  (when (null renderer)
    (return-from stroke-rect-outside nil))
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (loop repeat width
        for offset from 0
        do (let ((outline (make-instance 'sdl3:frect
                 :%x (float (- x 1 offset) 1.0)
                 :%y (float (- y 1 offset) 1.0)
                 :%w (float (+ w 1 (* 2 offset)) 1.0)
                 :%h (float (+ h 1 (* 2 offset)) 1.0))))
             (sdl3:render-rect renderer outline))))

(defun render-bevel-rect (renderer x y w h top-left-color bottom-right-color &optional (width 1))
  "Draw a beveled border using different colors on opposite edges."
  (when (null renderer)
    (return-from render-bevel-rect nil))
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
  "Render centered button <label>."
  (when (null renderer)
    (return-from render-button-label nil))
  (multiple-value-bind (text-w text-h)
      (text-pixel-size (<button>-text widget))
    (let* ((x (+ (<widget>-x widget)
                 (max +widget-padding+
                      (floor (- (<widget>-width widget) text-w) 2))
                 offset-x))
           (y (+ (<widget>-y widget)
                 (max 0 (floor (- (<widget>-height widget) text-h) 2))
                 offset-y)))
      (render-text renderer (<button>-text widget) x y color))))

(defun render-text (renderer text x y color)
  "Render text using TTF font if available, with fallback to ASCII approximation.
   Supports Unicode text including Cyrillic characters."
  (when (null renderer)
    nil)
  (render-text-with-ttf renderer text x y color))

;; NOTE: `render` is the preferred dispatching <entry>point.
;; Removed compatibility wrappers `render-widget`/`render-widgets` as a
;; deliberate breaking change; call sites should use `render` or
;; iterate over `(widgets-in-render-order ...)` and call `render`.

(defun fill-circle (renderer cx cy radius color)
  "Fill a circle centered at CX/CY with RADIUS and COLOR."
  (when (null renderer)
    (return-from fill-circle nil))
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (loop for dy from (- radius) to radius
        for span = (floor (sqrt (max 0 (- (* radius radius) (* dy dy)))))
        do (sdl3:render-line renderer
                             (float (- cx span) 1.0)
                             (float (+ cy dy) 1.0)
                             (float (+ cx span) 1.0)
                             (float (+ cy dy) 1.0))))

(defun fill-triangle (renderer cx cy radius color angle-center-point)
  "Fill a regular (equilateral) triangle inscribed in the circle centered at
CX,CY with given RADIUS. The triangle is oriented so that one vertex lies at
`angle-center-point` (radians measured from the positive X axis). COLOR is a
list (r g b a).

Fills the triangle using horizontal scanlines.
"
  (when (null renderer)
    (return-from fill-triangle nil))
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  ;; Compute three vertices of the regular triangle
  (let* ((angles (loop for i from 0 below 3 collect (+ angle-center-point (* i (/ (* 2 pi) 3)))))
         (pts (mapcar (lambda (ang)
                        (cons (+ cx (* radius (cos ang)))
                              (+ cy (* radius (sin ang)))))
                      angles))
         (xs (mapcar #'car pts))
         (ys (mapcar #'cdr pts))
         (y-min (floor (reduce #'min ys)))
         (y-max (ceiling (reduce #'max ys))))
    ;; For each scanline compute intersections with triangle edges
    (loop for y from y-min to y-max do
          (let ((intersections nil)
                (yf (float y 1.0)))
            (loop for i from 0 below 3 do
                  (let* ((x1 (nth i xs)) (y1 (nth i ys))
                         (j (mod (1+ i) 3))
                         (x2 (nth j xs)) (y2 (nth j ys)))
                    (when (not (= y1 y2))
                      ;; check if scanline intersects edge (y between y1 and y2)
                      (when (or (and (<= y1 y) (< y y2))
                                (and (<= y2 y) (< y y1))
                                (= y y1) (= y y2))
                           (let* ((alpha (/ (- y y1) (- y2 y1)))
                             (ix (+ x1 (* alpha (- x2 x1)))))
                          (push ix intersections))))))
            (when intersections
              (let* ((sorted (sort intersections #'<))
                     (x0 (car sorted))
                     (x1 (if (second sorted) (second sorted) x0)))
                (sdl3:render-line renderer
                                  (float x0 1.0) (float yf 1.0)
                                  (float x1 1.0) (float yf 1.0))))))))

(defun stroke-circle (renderer cx cy radius color &optional (segments 32))
  "Draw a circle outline centered at CX/CY with RADIUS and COLOR."
  (when (null renderer)
    (return-from stroke-circle nil))
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

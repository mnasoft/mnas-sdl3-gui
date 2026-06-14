;;;; ./src/widgets/methods/canvas-2d-methods.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Minimal scaffold for canvas-2d-widget behavior: scene assignment,
;; viewport transforms, pan/zoom helpers and a simple render pass.

(defmethod set-scene ((widget canvas-2d-widget) scene)
  "Assign SCENE model to canvas and request redraw."
  (setf (canvas-2d-widget-scene widget) scene)
  (request-redraw widget))

(defmethod request-redraw ((widget canvas-2d-widget))
  "Mark widget to be redrawn on next frame." 
  (setf (canvas-2d-widget-redraw-requested widget) t))

(defmethod world-to-screen ((widget canvas-2d-widget) x y &optional z)
  "Convert world coordinates to screen coordinates using viewport scale/offsets." 
  (let ((s (canvas-2d-widget-viewport-scale widget))
        (ox (canvas-2d-widget-viewport-offset-x widget))
        (oy (canvas-2d-widget-viewport-offset-y widget)))
    (values (+ ox (* x s)) (+ oy (* y s)) (and z (* s z)))))

(defmethod screen-to-world ((widget canvas-2d-widget) x y &optional z)
  "Inverse of `world-to-screen`." 
  (let ((s (canvas-2d-widget-viewport-scale widget))
        (ox (canvas-2d-widget-viewport-offset-x widget))
        (oy (canvas-2d-widget-viewport-offset-y widget)))
    (values (/ (- x ox) (max s 1e-9)) (/ (- y oy) (max s 1e-9)) (and z (/ z (max s 1e-9))))))

(defmethod handle-viewport-resize ((widget canvas-2d-widget) width height)
  "Handle viewport resize - update widget bounds and request redraw."
  (place-widget widget :x (<widget>-x widget) :y (<widget>-y widget) :width width :height height)
  (request-redraw widget))

(defun canvas-2d-pan-by (widget dx dy)
  "Pan canvas viewport by DX/DY (in screen pixels). Returns new offsets." 
  (when (canvas-2d-widget-pan-enabled widget)
    (incf (canvas-2d-widget-viewport-offset-x widget) dx)
    (incf (canvas-2d-widget-viewport-offset-y widget) dy)
    (request-redraw widget)
    (values (canvas-2d-widget-viewport-offset-x widget)
            (canvas-2d-widget-viewport-offset-y widget))))

(defun canvas-2d-zoom-by (widget factor &optional (center-x 0) (center-y 0))
  "Zoom canvas by FACTOR around optional CENTER (screen coords)." 
  (when (canvas-2d-widget-zoom-enabled widget)
    (let* ((old-scale (canvas-2d-widget-viewport-scale widget))
           (new-scale (* old-scale factor))
           (ox (canvas-2d-widget-viewport-offset-x widget))
           (oy (canvas-2d-widget-viewport-offset-y widget)))
      ;; adjust offsets so CENTER stays visually stable
      (setf (canvas-2d-widget-viewport-scale widget) new-scale)
      (setf (canvas-2d-widget-viewport-offset-x widget) (+ center-x (* (- ox center-x) (/ new-scale old-scale))))
      (setf (canvas-2d-widget-viewport-offset-y widget) (+ center-y (* (- oy center-y) (/ new-scale old-scale))))
      (request-redraw widget)
      (canvas-2d-widget-viewport-scale widget))))

(defmethod render (renderer (widget canvas-2d-widget) style)
  "Basic render pass for canvas: clear background and, if a scene is present,
perform a trivial placeholder draw. Real scene rendering should be implemented
by higher-level code that inspects `canvas-2d-widget-scene`."
  ;; clear canvas area
  (fill-rect renderer (<widget>-x widget) (<widget>-y widget)
             (<widget>-width widget) (<widget>-height widget) +color-bg+)
  ;; placeholder scene rendering: if scene is a simple list of items, draw them
  (let ((scene (canvas-2d-widget-scene widget)))
    (when (and scene (listp scene))
      (dolist (item scene)
        (when (and (consp item) (eq (car item) :circle))
          (let ((cx (nth 1 item))
                (cy (nth 2 item))
                (r  (nth 3 item))
                (color (nth 4 item)))
            (multiple-value-bind (sx sy) (world-to-screen widget cx cy)
              (fill-circle renderer sx sy r (or color '(64 128 200 255))))))))))

(defmethod widget-min-size ((widget canvas-2d-widget))
  "Minimal size hint for canvas widget - default to current size."
  (values (<widget>-width widget) (<widget>-height widget)))

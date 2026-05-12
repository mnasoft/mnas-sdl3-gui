;;;; ./src/widgets/mouse-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Mouse dispatch helpers

(defun dispatch-widget-mouse-down (widgets x y)
  "Dispatch mouse-down to WIDGETS and focus the widget that consumes it."
  (loop for widget in widgets
        when (handle-widget-mouse-down widget x y)
          do (set-widget-focus widgets widget)
             (return widget)
        finally (return nil)))

(defun dispatch-widget-mouse-up (widgets x y)
  "Dispatch mouse-up to WIDGETS and return the widget that consumes it."
  (loop for widget in widgets
        when (handle-widget-mouse-up widget x y)
          return widget
        finally (return nil)))

(defun dispatch-widget-mouse-motion (widgets x y)
  "Dispatch mouse-motion to each widget in WIDGETS."
  (loop for widget in widgets
        do (handle-widget-mouse-motion widget x y))
  nil)

(defun dispatch-widget-mouse-wheel (widgets x y dx dy)
  "Dispatch mouse-wheel input to widgets under X/Y and return the widget that consumes it."
  (loop for widget in widgets
        when (and (widget-visible widget)
                  (widget-enabled widget)
                  (contains-point-p widget x y)
                  (typep widget 'list-box)
                  (not (zerop dy))
                  (list-box-scroll-by widget (- dy)))
          return widget
        finally (return nil)))

(defun handle-widget-click (widget x y)
  "Compatibility helper: emulate click as mouse-down followed by mouse-up."
  (let ((down (handle-widget-mouse-down widget x y))
        (up (handle-widget-mouse-up widget x y)))
    (or down up)))

(defun handle-widget-mouse-motion (widget x y)
  "Handle mouse motion over a widget."
  (when (widget-visible widget)
    (cond
      ((typep widget 'list-box)
       (when (list-box-scrollbar-dragging-p widget)
         (list-box-set-scroll-offset-from-thumb-top
          widget
          (- y (list-box-scrollbar-drag-offset widget)))))
      (t
       (let ((inside (contains-point-p widget x y)))
         (when (typep widget 'button)
           (when (button-armed-p widget)
             (setf (button-pressed-p widget) inside))))))))
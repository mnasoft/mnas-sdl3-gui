;;;; ./src/widgets/methods/handle-widget-click.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Ensure only enabled/visible widgets receive click handling.
(defmethod handle-widget-click :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-click ((widget widget) x y)
  "Default compatibility helper: emulate click as mouse-down followed by mouse-up."
  (let ((down (handle-widget-mouse-down widget x y))
        (up (handle-widget-mouse-up widget x y)))
    (or down up)))

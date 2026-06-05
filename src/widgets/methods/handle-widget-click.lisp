;;;; ./src/widgets/methods/handle-widget-click.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Ensure only enabled/visible widgets receive click handling.
(defmethod handle-widget-click :around ((widget widget) x y)
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-widget-click ((widget widget) x y)
  "Default compatibility helper: emulate click as mouse-down followed by mouse-up."
  (let ((ev-down (sdl3:mouse-button-event :%x x :%y y :%down t))
        (ev-up (sdl3:mouse-button-event :%x x :%y y :%down nil)))
    (or (handle-mouse-button-event widget ev-down)
        (handle-mouse-button-event widget ev-up))))

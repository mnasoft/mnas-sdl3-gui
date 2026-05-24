;;;; ./src/widgets/mouse-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Mouse dispatch helpers

;; `dispatch-widget-mouse-down` removed: call `handle-widget-mouse-down` directly.

;; `dispatch-widget-mouse-up` removed: call `handle-widget-mouse-up` directly.

;; `dispatch-widget-mouse-motion` removed: call `handle-widget-mouse-motion` directly.

;; Converted from the old `dispatch-widget-mouse-wheel` free function to a
;; generic method. Use `handle-widget-mouse-wheel` to dispatch wheel events.
(defmethod handle-widget-mouse-wheel ((widgets cons) x y dx dy)
  "Handle mouse-wheel input for a list (CONS) of widgets. Returns the widget that consumes the event."
  (loop for widget in (widgets-in-hit-test-order widgets)
        when (and (visible-p widget)
                  (enabled-p widget)
                  (contains-point-p widget x y)
                  (not (zerop dy))
                  (handle-widget-mouse-wheel widget x y dx dy))
          return widget
        finally (return nil)))


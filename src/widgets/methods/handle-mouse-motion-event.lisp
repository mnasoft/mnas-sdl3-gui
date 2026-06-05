;;;; ./src/widgets/methods/handle-mouse-motion-event.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Event-level dispatch that converts an `sdl3:mouse-motion-event` into
;; calls to `handle-widget-mouse-motion` on per-widget level.

(defmethod handle-mouse-motion-event :around ((widget widget) (ev sdl3:mouse-motion-event))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-mouse-motion-event ((widgets cons) (ev sdl3:mouse-motion-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y))))
    (loop for widget in (widgets-in-hit-test-order widgets)
          when (and (visible-p widget)
                    (enabled-p widget)
                    (contains-point-p widget x y)
                    (handle-widget-mouse-motion widget x y))
            return widget
          finally (return nil))))

(defmethod handle-mouse-motion-event ((widget widget) (ev sdl3:mouse-motion-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y))))
    (handle-widget-mouse-motion widget x y)))

;;;; ./src/widgets/methods/handle-mouse-motion-event.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-mouse-motion-event :around ((widget widget) (ev sdl3:mouse-motion-event))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-mouse-motion-event ((widgets cons) (ev sdl3:mouse-motion-event))
  "Dispatch motion events to children in hit-test order; return the widget that consumed the event or NIL."
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y))))
    (loop for widget in (widgets-in-hit-test-order widgets)
          when (and (visible-p widget)
                    (enabled-p widget)
                    (contains-point-p widget x y)
                    (handle-mouse-motion-event widget ev))
            return widget
          finally (return nil))))

(defmethod handle-mouse-motion-event ((widget widget) (ev sdl3:mouse-motion-event))
  "Default per-widget motion handler: no-op. Specialized widgets implement their own behavior."
  (declare (ignore ev))
  nil)

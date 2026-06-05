;;;; ./src/widgets/methods/handle-mouse-wheel-event.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Event-level dispatch that converts an `sdl3:mouse-wheel-event` into
;; the per-widget `handle-widget-mouse-wheel` calls already present in
;; the codebase.

(defmethod handle-mouse-wheel-event :around ((widget widget) (ev sdl3:mouse-wheel-event))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-mouse-wheel-event ((widgets cons) (ev sdl3:mouse-wheel-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (dy (handler-case (slot-value ev 'sdl3:%yrel) (error ()
                                                          (handler-case (slot-value ev 'sdl3:%mouse-y) (error () 0))))))
    ;; Dispatch to widgets-in-hit-test-order and call the per-widget handler.
    (loop for widget in (widgets-in-hit-test-order widgets)
          when (and (visible-p widget)
                    (enabled-p widget)
                    (contains-point-p widget x y)
                    (not (zerop dy))
                    (handle-widget-mouse-wheel widget x y 0 dy))
            return widget
          finally (return nil))))

(defmethod handle-mouse-wheel-event ((widget widget) (ev sdl3:mouse-wheel-event))
  ;; Default per-widget adapter: call existing widget-level wheel handler
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (dy (handler-case (slot-value ev 'sdl3:%yrel) (error ()
                                                          (handler-case (slot-value ev 'sdl3:%mouse-y) (error () 0))))))
    (handle-widget-mouse-wheel widget x y 0 dy)))

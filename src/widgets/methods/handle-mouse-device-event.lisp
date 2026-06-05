;;;; ./src/widgets/methods/handle-mouse-device-event.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Mouse device events are typically global (device added/removed). Provide
;; a generic event-level dispatch that forwards the event to per-widget
;; `handle-widget-mouse-device` adapters when appropriate. Default
;; behaviour is no-op.

(defmethod handle-mouse-device-event :around ((widget widget) (ev sdl3:mouse-device-event))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-mouse-device-event ((widgets cons) (ev sdl3:mouse-device-event))
  ;; Default: iterate widgets and call per-widget adapter; most widgets will
  ;; ignore device events.
  (loop for widget in widgets
        when (handle-mouse-device-event widget ev)
          return widget
        finally (return nil)))

(defmethod handle-mouse-device-event ((widget widget) (ev sdl3:mouse-device-event))
  ;; Default no-op; per-widget specializations can respond to device events.
  (declare (ignore ev))
  nil)


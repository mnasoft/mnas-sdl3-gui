;;;; ./src/widgets/mouse-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Mouse dispatch helpers

;; `dispatch-widget-mouse-down` removed: call `handle-widget-mouse-down` directly.

;; `dispatch-widget-mouse-up` removed: call `handle-widget-mouse-up` directly.

;; `dispatch-widget-mouse-motion` removed: call `handle-widget-mouse-motion` directly.

;; Converted from the old `dispatch-widget-mouse-wheel` free function to a
;; generic method. Use `handle-widget-mouse-wheel` to dispatch wheel events.
;; `handle-widget-mouse-wheel` cons-method moved to
;; `src/widgets/methods/handle-widget-mouse-wheel.lisp`.
;; See that file for the implementation and per-widget specializations.

;; Generic dispatch for mouse-button events. Widgets packages can define
;; methods on `handle-mouse-button-event` specialized on widget tree types
;; or on the `sdl3:mouse-button-event` argument to customize behavior.
(defgeneric handle-mouse-button-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-button-event and dispatch to widget handlers."))

(defgeneric handle-mouse-wheel-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-wheel-event and dispatch to widget handlers."))

(defgeneric handle-mouse-motion-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-motion-event and dispatch to widget handlers."))

(defgeneric handle-mouse-device-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-device-event and dispatch to widget handlers.") )


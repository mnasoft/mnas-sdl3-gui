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


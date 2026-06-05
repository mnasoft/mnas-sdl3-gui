;;;; ./src/widgets/mouse-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

(defgeneric handle-mouse-button-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-button-event and dispatch to widget handlers."))

(defgeneric handle-mouse-wheel-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-wheel-event and dispatch to widget handlers."))

(defgeneric handle-mouse-motion-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-motion-event and dispatch to widget handlers."))

(defgeneric handle-mouse-device-event (widgets ev)
	(:documentation "Handle an sdl3:mouse-device-event and dispatch to widget handlers.") )


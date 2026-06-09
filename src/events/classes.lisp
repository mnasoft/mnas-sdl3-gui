;;;; ./src/events/classes.lisp

(in-package :mnas-sdl3-gui/events)
 
;; Event info class hierarchy: store last parsed event as an
;; instance of one of these classes. This keeps event data structured
;; and extensible.
(defclass event-info ()
  ((timestamp :initform nil :accessor info-timestamp :initarg :timestamp)))

(defclass mouse-motion-info (event-info)
  ((window-id
    :initform nil :accessor info-mm-window-id :initarg :window-id)
   (which
    :initform nil :accessor info-mm-which :initarg :which)
   (state
    :initform nil :accessor info-mm-state :initarg :state)
   (x
    :initform 0.0 :accessor info-mm-x :initarg :x)
   (y
    :initform 0.0 :accessor info-mm-y :initarg :y)
   (xrel
    :initform 0.0 :accessor info-mm-xrel :initarg :xrel)
   (yrel
    :initform 0.0 :accessor info-mm-yrel :initarg :yrel)))

(defclass mouse-button-info (event-info)
  ((window-id
    :initform nil :accessor info-mb-window-id :initarg :window-id)
   (which
    :initform nil :accessor info-mb-which :initarg :which)
   (button
    :initform nil :accessor info-mb-button :initarg :button)
   (down
    :initform nil :accessor info-mb-down :initarg :down)
   (clicks
    :initform nil :accessor info-mb-clicks :initarg :clicks)
   (x
    :initform 0.0 :accessor info-mb-x :initarg :x)
   (y
    :initform 0.0 :accessor info-mb-y :initarg :y)))

(defclass mouse-wheel-info (event-info)
  ((window-id
    :initform nil :accessor info-wl-window-id :initarg :window-id)
   (which
    :initform nil :accessor info-wl-which :initarg :which)
   (x
    :initform 0.0 :accessor info-wl-x :initarg :x)
   (y
    :initform 0.0 :accessor info-wl-y :initarg :y)
   (direction
    :initform nil :accessor info-wl-direction :initarg :direction)
   (mouse-x
    :initform 0.0 :accessor info-wl-mouse-x :initarg :mouse-x)
   (mouse-y
    :initform 0.0 :accessor info-wl-mouse-y :initarg :mouse-y)))

(defclass keyboard-info (event-info)
  ((window-id
    :initform nil :accessor info-kb-window-id :initarg :window-id)
   (which
    :initform nil :accessor info-kb-which :initarg :which)
   (scancode
    :initform nil :accessor info-kb-scancode :initarg :scancode)
   (key
    :initform nil :accessor info-kb-key :initarg :key)
   (mod
    :initform 0 :accessor info-kb-mod :initarg :mod)
   (raw
    :initform nil :accessor info-kb-raw :initarg :raw)
   (down
    :initform nil :accessor info-kb-down :initarg :down)
   (repeat
    :initform nil :accessor info-kb-repeat :initarg :repeat)))

;; tracker stores only structured references to event-info instances
;; instead of many scalar compatibility slots. This simplifies the
;; model and encourages consumers to inspect the `last-event` or the
;; typed `last-*-event` slots.
(defclass event-tracker ()
  ((last-type
    :initform nil :accessor last-event-type)
   (last-event
    :initform nil :accessor last-event)
   (last-motion
    :initform nil :accessor last-motion-event)   ; mouse-motion-info
   (last-button
    :initform nil :accessor last-button-event)   ; mouse-button-info
   (last-wheel
    :initform nil :accessor last-wheel-event)     ; mouse-wheel-info
   (last-keyboard
    :initform nil :accessor last-keyboard-event) ; keyboard-info
   (buttons-down
    :initform nil :accessor event-buttons-down) ; pressed mouse buttons
   (keys-down
    :initform nil :accessor event-keys-down)       ; pressed keyboard keys
   (timestamp
    :initform nil :accessor event-timestamp)))

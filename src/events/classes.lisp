;;;; ./src/events/classes.lisp

(in-package :mnas-sdl3-gui/events)
 
;; Event info class hierarchy: store last parsed event as an
;; instance of one of these classes. This keeps event data structured
;; and extensible.
(defclass <event-info> ()
  ((timestamp
    :initform nil
    :accessor <event-info>-timestamp
    :initarg :timestamp)))

(defclass <mouse-motion-info> (<event-info>)
  ((window-id
    :initform nil
    :accessor <mouse-motion-info>-window-id
    :initarg :window-id)
   (which
    :initform nil
    :accessor <mouse-motion-info>-which
    :initarg :which)
   (state
    :initform nil
    :accessor <mouse-motion-info>-state
    :initarg :state)
   (x
    :initform 0.0
    :accessor <mouse-motion-info>-x
    :initarg :x)
   (y
    :initform 0.0
    :accessor <mouse-motion-info>-y
    :initarg :y)
   (xrel
    :initform 0.0
    :accessor <mouse-motion-info>-xrel
    :initarg :xrel)
   (yrel
    :initform 0.0
    :accessor <mouse-motion-info>-yrel
    :initarg :yrel)))

(defclass <mouse-button-info> (<event-info>)
  ((window-id
    :initform nil
    :accessor <mouse-button-info>-window-id
    :initarg :window-id)
   (which
    :initform nil
    :accessor <mouse-button-info>-which
    :initarg :which)
   (button
    :initform nil
    :accessor <mouse-button-info>-button
    :initarg :button)
   (down
    :initform nil
    :accessor <mouse-button-info>-down
    :initarg :down)
   (clicks
    :initform nil
    :accessor <mouse-button-info>-clicks
    :initarg :clicks)
   (x
    :initform 0.0
    :accessor <mouse-button-info>-x
    :initarg :x)
   (y
    :initform 0.0
    :accessor <mouse-button-info>-y
    :initarg :y)))

(defclass <mouse-wheel-info> (<event-info>)
  ((window-id
    :initform nil
    :accessor <mouse-wheel-info>-window-id
    :initarg :window-id)
   (which
    :initform nil
    :accessor <mouse-wheel-info>-which
    :initarg :which)
   (x
    :initform 0.0
    :accessor <mouse-wheel-info>-x
    :initarg :x)
   (y
    :initform 0.0
    :accessor <mouse-wheel-info>-y
    :initarg :y)
   (direction
    :initform nil
    :accessor <mouse-wheel-info>-direction
    :initarg :direction)
   (mouse-x
    :initform 0.0
    :accessor <mouse-wheel-info>-mouse-x
    :initarg :mouse-x)
   (mouse-y
    :initform 0.0
    :accessor <mouse-wheel-info>-mouse-y
    :initarg :mouse-y)))

(defclass <keyboard-info> (<event-info>)
  ((window-id
    :initform nil
    :accessor <keyboard-info>-window-id
    :initarg :window-id)
   (which
    :initform nil
    :accessor <keyboard-info>-which
    :initarg :which)
   (scancode
    :initform nil
    :accessor <keyboard-info>-scancode
    :initarg :scancode)
   (key
    :initform nil
    :accessor <keyboard-info>-key
    :initarg :key)
   (mod
    :initform 0
    :accessor <keyboard-info>-mod
    :initarg :mod)
   (raw
    :initform nil
    :accessor <keyboard-info>-raw
    :initarg :raw)
   (down
    :initform nil
    :accessor <keyboard-info>-down
    :initarg :down)
   (repeat
    :initform nil
    :accessor <keyboard-info>-repeat
    :initarg :repeat)))

;; tracker stores only structured references to event-info instances
;; instead of many scalar compatibility slots. This simplifies the
;; model and encourages consumers to inspect the `last-event` or the
;; typed `last-*-event` slots.
(defclass <event-tracker> ()
  ((last-type
    :initform nil
    :accessor <event-tracker>-last-type)
   (last-event
    :initform nil
    :accessor <event-tracker>-last-event)
   (last-motion
    :initform nil
    :accessor <event-tracker>-last-motion)   ; mouse-motion-info
   (last-button
    :initform nil
    :accessor <event-tracker>-last-button)   ; mouse-button-info
   (last-wheel
    :initform nil
    :accessor <event-tracker>-last-wheel)     ; mouse-wheel-info
   (last-keyboard
    :initform nil
    :accessor <event-tracker>-last-keyboard) ; keyboard-info
   (buttons-down
    :initform nil
    :accessor <event-tracker>-buttons-down) ; pressed mouse buttons
   (keys-down
    :initform nil
    :accessor <event-tracker>-keys-down)       ; pressed keyboard keys
   (timestamp
    :initform nil
    :accessor <event-tracker>-timestamp)))

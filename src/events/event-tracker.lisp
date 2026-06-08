;;;; ./src/events/event-tracker.lisp

(in-package :mnas-sdl3-gui/events)
 
;; Event info class hierarchy: store last parsed event as an
;; instance of one of these classes. This keeps event data structured
;; and extensible.
(defclass event-info ()
  ((timestamp :initform nil :accessor info-timestamp :initarg :timestamp)))

(defclass mouse-motion-info (event-info)
  ((window-id :initform nil :accessor info-mm-window-id :initarg :window-id)
   (which :initform nil :accessor info-mm-which :initarg :which)
   (state :initform nil :accessor info-mm-state :initarg :state)
   (x :initform 0.0 :accessor info-mm-x :initarg :x)
   (y :initform 0.0 :accessor info-mm-y :initarg :y)
   (xrel :initform 0.0 :accessor info-mm-xrel :initarg :xrel)
   (yrel :initform 0.0 :accessor info-mm-yrel :initarg :yrel)))

(defclass mouse-button-info (event-info)
  ((window-id :initform nil :accessor info-mb-window-id :initarg :window-id)
   (which :initform nil :accessor info-mb-which :initarg :which)
   (button :initform nil :accessor info-mb-button :initarg :button)
   (down :initform nil :accessor info-mb-down :initarg :down)
   (clicks :initform nil :accessor info-mb-clicks :initarg :clicks)
   (x :initform 0.0 :accessor info-mb-x :initarg :x)
   (y :initform 0.0 :accessor info-mb-y :initarg :y)))

(defclass mouse-wheel-info (event-info)
  ((window-id :initform nil :accessor info-wl-window-id :initarg :window-id)
   (which :initform nil :accessor info-wl-which :initarg :which)
   (x :initform 0.0 :accessor info-wl-x :initarg :x)
   (y :initform 0.0 :accessor info-wl-y :initarg :y)
   (direction :initform nil :accessor info-wl-direction :initarg :direction)
   (mouse-x :initform 0.0 :accessor info-wl-mouse-x :initarg :mouse-x)
   (mouse-y :initform 0.0 :accessor info-wl-mouse-y :initarg :mouse-y)))

(defclass keyboard-info (event-info)
  ((window-id :initform nil :accessor info-kb-window-id :initarg :window-id)
   (which :initform nil :accessor info-kb-which :initarg :which)
   (scancode :initform nil :accessor info-kb-scancode :initarg :scancode)
   (key :initform nil :accessor info-kb-key :initarg :key)
   (mod :initform 0 :accessor info-kb-mod :initarg :mod)
   (raw :initform nil :accessor info-kb-raw :initarg :raw)
   (down :initform nil :accessor info-kb-down :initarg :down)
   (repeat :initform nil :accessor info-kb-repeat :initarg :repeat)))

;; tracker stores only structured references to event-info instances
;; instead of many scalar compatibility slots. This simplifies the
;; model and encourages consumers to inspect the `last-event` or the
;; typed `last-*-event` slots.
(defclass event-tracker ()
  ((last-type :initform nil :accessor last-event-type)
   (last-event :initform nil :accessor last-event)
   (last-motion :initform nil :accessor last-motion-event)   ; mouse-motion-info
   (last-button :initform nil :accessor last-button-event)   ; mouse-button-info
   (last-wheel :initform nil :accessor last-wheel-event)     ; mouse-wheel-info
   (last-keyboard :initform nil :accessor last-keyboard-event) ; keyboard-info
   (buttons-down :initform nil :accessor event-buttons-down) ; pressed mouse buttons
   (keys-down :initform nil :accessor event-keys-down)       ; pressed keyboard keys
   (timestamp :initform nil :accessor event-timestamp)))

(defparameter *event-tracker* (make-instance 'event-tracker))

(defun event-tracker-instance ()
  "Return the singleton event-tracker instance."
  *event-tracker*)

(defun make-event-tracker (&optional init)
  "Create and make the global event-tracker instance."
  (let ((et (or init (make-instance 'event-tracker))))
    (setf *event-tracker* et)
    et))

(defun clear-event-tracker ()
  (setf *event-tracker* (make-instance 'event-tracker)))

(defun modifiers->list (mod)
  "Convert SDL keymod value to a readable list of keywords.
Accepts either an integer bitfield or a list/sequence of keyword symbols
returned by some wrappers." 
  (cond
    ((null mod) '())
    ((integerp mod)
     (let ((res '()))
       (when (logbitp 0 mod) (push :lshift res))
       (when (logbitp 1 mod) (push :rshift res))
       (when (logbitp 6 mod) (push :lctrl res))
       (when (logbitp 7 mod) (push :rctrl res))
       (when (logbitp 8 mod) (push :lalt res))
       (when (logbitp 9 mod) (push :ralt res))
       (when (logbitp 10 mod) (push :lgui res))
       (when (logbitp 11 mod) (push :rgui res))
       (when (logbitp 12 mod) (push :num res))
       (when (logbitp 13 mod) (push :caps res))
       res))
    ((and (typep mod 'sequence) (not (stringp mod)))
     (mapcar (lambda (k)
               (if (keywordp k)
                   (intern (cl:string-downcase (symbol-name k)) :keyword)
                   k))
             mod))
    (t (list mod))))

;;; Process events via a generic function so handlers can be extended.
(defgeneric process-sdl-event (tracker ev)
  (:documentation "Update tracker (an event-tracker) from SDL event ev. Per-event-type processing for event tracking."))

(defmethod process-sdl-event ((tracker event-tracker) (ev sdl3:mouse-motion-event))
  (let* ((ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (state (slot-value ev 'sdl3:%state))
         (x (slot-value ev 'sdl3:%x))
         (y (slot-value ev 'sdl3:%y))
         (xrel (slot-value ev 'sdl3:%xrel))
         (yrel (slot-value ev 'sdl3:%yrel))
         (info (make-instance 'mouse-motion-info :timestamp ts :window-id wid
                              :which which :state state :x x :y y :xrel xrel :yrel yrel)))
    (setf (slot-value tracker 'last-type) 'mouse-motion
          (slot-value tracker 'last-motion) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker event-tracker) (ev sdl3:mouse-button-event))
  (let* ((button (slot-value ev 'sdl3:%button))
         (down (slot-value ev 'sdl3:%down))
         (ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (clicks (slot-value ev 'sdl3:%clicks))
         (x (slot-value ev 'sdl3:%x))
         (y (slot-value ev 'sdl3:%y))
         (info (make-instance 'mouse-button-info :timestamp ts :window-id wid
                              :which which :button button :down down :clicks clicks :x x :y y)))
    (when down
      (pushnew button (slot-value tracker 'buttons-down)))
    (unless down
      (setf (slot-value tracker 'buttons-down)
            (remove button (slot-value tracker 'buttons-down))))
    (setf (slot-value tracker 'last-type) 'mouse-button
          (slot-value tracker 'last-button) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker event-tracker) (ev sdl3:mouse-wheel-event))
  (let* ((ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (x (slot-value ev 'sdl3:%x))
         (y (slot-value ev 'sdl3:%y))
         (dir (slot-value ev 'sdl3:%direction))
         (mx (slot-value ev 'sdl3:%mouse-x))
         (my (slot-value ev 'sdl3:%mouse-y))
         (info (make-instance 'mouse-wheel-info :timestamp ts :window-id wid
                              :which which :x x :y y :direction dir :mouse-x mx :mouse-y my)))
    (setf (slot-value tracker 'last-type) 'mouse-wheel
          (slot-value tracker 'last-wheel) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker event-tracker) (ev sdl3:keyboard-event))
  (let* ((down (slot-value ev 'sdl3:%down))
         (ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (sc (slot-value ev 'sdl3:%scancode))
         (k (slot-value ev 'sdl3:%key))
         (modv (slot-value ev 'sdl3:%mod))
         (raw (slot-value ev 'sdl3:%raw))
         (repeat (slot-value ev 'sdl3:%repeat))
         (info (make-instance 'keyboard-info :timestamp ts :window-id wid :which which
                              :scancode sc :key k :mod modv :raw raw :down down :repeat repeat)))
    (when down
      (pushnew k (slot-value tracker 'keys-down)))
    (unless down
      (setf (slot-value tracker 'keys-down)
            (remove k (slot-value tracker 'keys-down))))
    (setf (slot-value tracker 'last-type) (if down 'key-down 'key-up)
          (slot-value tracker 'last-keyboard) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker event-tracker) (ev t))
  (setf (slot-value tracker 'last-type) 'other))

;; Convenience wrapper keeping the old single-argument API.
(defun update-from-sdl-event (ev)
  "Update the global tracker `*event-tracker*` from SDL event `ev`.
This is a thin wrapper around `process-sdl-event` methods." 
  (process-sdl-event *event-tracker* ev))

;; Dispatching log_event as a generic function provides cleaner
;; extension points for each event type.
(defgeneric log-event (ev)
  (:documentation "Log a single SDL event object ev in a human-readable form. Specialize on sdl3:* event classes."))

(defmethod log-event ((ev sdl3:mouse-motion-event))
  (format t "MOTION: ts=~a window=~a which=~a state=~a x=~,2f y=~,2f xrel=~,2f yrel=~,2f~%"
          (slot-value ev 'sdl3:%timestamp)
          (slot-value ev 'sdl3:%window-id)
          (slot-value ev 'sdl3:%which)
          (slot-value ev 'sdl3:%state)
          (slot-value ev 'sdl3:%x)
          (slot-value ev 'sdl3:%y)
          (slot-value ev 'sdl3:%xrel)
          (slot-value ev 'sdl3:%yrel)))

(defmethod log-event ((ev sdl3:mouse-button-event))
  (format t "MOUSE BUTTON: ts=~a window=~a which=~a button=~a down=~a clicks=~a x=~,2f y=~,2f buttons-down=~a~%"
          (slot-value ev 'sdl3:%timestamp)
          (slot-value ev 'sdl3:%window-id)
          (slot-value ev 'sdl3:%which)
          (slot-value ev 'sdl3:%button)
          (slot-value ev 'sdl3:%down)
          (slot-value ev 'sdl3:%clicks)
          (slot-value ev 'sdl3:%x)
          (slot-value ev 'sdl3:%y)
          (slot-value *event-tracker* 'buttons-down)))

(defmethod log-event ((ev sdl3:mouse-wheel-event))
  (format t "MOUSE WHEEL: ts=~a window=~a which=~a x=~,2f y=~,2f dir=~a mouse-x=~,2f mouse-y=~,2f~%"
          (slot-value ev 'sdl3:%timestamp)
          (slot-value ev 'sdl3:%window-id)
          (slot-value ev 'sdl3:%which)
          (slot-value ev 'sdl3:%x)
          (slot-value ev 'sdl3:%y)
          (slot-value ev 'sdl3:%direction)
          (slot-value ev 'sdl3:%mouse-x)
          (slot-value ev 'sdl3:%mouse-y)))

(defmethod log-event ((ev sdl3:keyboard-event))
  (let ((k (slot-value ev 'sdl3:%key))
        (sc (slot-value ev 'sdl3:%scancode))
        (mod (slot-value ev 'sdl3:%mod))
        (down (slot-value ev 'sdl3:%down))
        (raw (slot-value ev 'sdl3:%raw))
        (repeat (slot-value ev 'sdl3:%repeat)))
    (format t "KEY ~a: key=~a scancode=~a raw=~a down=~a repeat=~a mods=~a~%"
            (if down "DOWN" "UP") k sc raw down repeat (modifiers->list mod))))

(defmethod log-event ((ev t))
  (format t "EVENT: ~a~%" ev))


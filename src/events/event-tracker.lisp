;;;; ./src/events/event-tracker.lisp

(in-package :mnas-sdl3-gui/events)

(defclass event-tracker ()
  ((last-type :initform nil :accessor last-event-type)
   (mouse-x :initform 0.0 :accessor event-mouse-x)
   (mouse-y :initform 0.0 :accessor event-mouse-y)
   (mouse-buttons :initform nil :accessor event-mouse-buttons)
   (wheel-x :initform 0.0 :accessor event-wheel-x)
   (wheel-y :initform 0.0 :accessor event-wheel-y)
   (key :initform nil :accessor event-key)
   (scancode :initform nil :accessor event-scancode)
   (mod :initform 0 :accessor event-mod)
   (keys-down :initform nil :accessor event-keys-down)
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

(defun update-from-sdl-event (ev)
  "Update the global tracker from an sdl3:event-unmarshal result `ev`."
  (let ((tracker *event-tracker*))
    (typecase ev
      (sdl3:mouse-motion-event
       (setf (slot-value tracker 'last-type) 'mouse-motion
             (slot-value tracker 'mouse-x) (slot-value ev 'sdl3:%x)
             (slot-value tracker 'mouse-y) (slot-value ev 'sdl3:%y)))
      (sdl3:mouse-button-event
       (let ((button (slot-value ev 'sdl3:%button))
             (down (slot-value ev 'sdl3:%down)))
         (when down
           (pushnew button (slot-value tracker 'mouse-buttons)))
         (unless down
           (setf (slot-value tracker 'mouse-buttons)
                 (remove button (slot-value tracker 'mouse-buttons))))
         (setf (slot-value tracker 'last-type) 'mouse-button
               (slot-value tracker 'mouse-x) (slot-value ev 'sdl3:%x)
               (slot-value tracker 'mouse-y) (slot-value ev 'sdl3:%y))))
      (sdl3:mouse-wheel-event
       (setf (slot-value tracker 'last-type) 'mouse-wheel
             (slot-value tracker 'wheel-x) (slot-value ev 'sdl3:%x)
             (slot-value tracker 'wheel-y) (slot-value ev 'sdl3:%y)
             (slot-value tracker 'mouse-x) (slot-value ev 'sdl3:%mouse-x)
             (slot-value tracker 'mouse-y) (slot-value ev 'sdl3:%mouse-y)))
      (sdl3:keyboard-event
       (setf (slot-value tracker 'last-type) (if (slot-value ev 'sdl3:%down) 'key-down 'key-up)
             (slot-value tracker 'key) (slot-value ev 'sdl3:%key)
             (slot-value tracker 'scancode) (slot-value ev 'sdl3:%scancode)
             (slot-value tracker 'mod) (slot-value ev 'sdl3:%mod)
             (slot-value tracker 'timestamp) (slot-value ev 'sdl3:%timestamp)))
      (t
       (setf (slot-value tracker 'last-type) 'other)))))

(defun log-event (ev)
  "Print a human-readable log of the SDL event `ev` to stdout." 
  (let ((tracker *event-tracker*))
    (typecase ev
      (sdl3:mouse-motion-event
       (format t "MOTION: x=~,2f y=~,2f xrel=~,2f yrel=~,2f~%"
               (slot-value ev 'sdl3:%x)
               (slot-value ev 'sdl3:%y)
               (slot-value ev 'sdl3:%xrel)
               (slot-value ev 'sdl3:%yrel)))
      (sdl3:mouse-button-event
       (format t "MOUSE BUTTON: button=~a down=~a clicks=~a x=~,2f y=~,2f buttons-down=~a~%"
               (slot-value ev 'sdl3:%button)
               (slot-value ev 'sdl3:%down)
               (slot-value ev 'sdl3:%clicks)
               (slot-value ev 'sdl3:%x)
               (slot-value ev 'sdl3:%y)
               (slot-value tracker 'mouse-buttons)))
      (sdl3:mouse-wheel-event
       (format t "MOUSE WHEEL: x=~,2f y=~,2f mouse-x=~,2f mouse-y=~,2f dir=~a~%"
               (slot-value ev 'sdl3:%x)
               (slot-value ev 'sdl3:%y)
               (slot-value ev 'sdl3:%mouse-x)
               (slot-value ev 'sdl3:%mouse-y)
               (slot-value ev 'sdl3:%direction)))
      (sdl3:keyboard-event
       (let ((k (slot-value ev 'sdl3:%key))
             (sc (slot-value ev 'sdl3:%scancode))
             (mod (slot-value ev 'sdl3:%mod))
             (down (slot-value ev 'sdl3:%down)))
        (format t "KEY ~a: key=~a scancode=~a down=~a mods=~a~%"
          (if down "DOWN" "UP") k sc down (modifiers->list mod))))
      (t
       (format t "EVENT: ~a~%" ev)))))

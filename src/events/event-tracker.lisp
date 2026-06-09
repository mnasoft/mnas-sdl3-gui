;;;; ./src/events/event-tracker.lisp

(in-package :mnas-sdl3-gui/events)
 
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

;; Convenience wrapper keeping the old single-argument API.
(defun update-from-sdl-event (ev)
  "Update the global tracker `*event-tracker*` from SDL event `ev`.
This is a thin wrapper around `process-sdl-event` methods." 
  (process-sdl-event *event-tracker* ev))

;;;; ./src/events/generics.lisp

(in-package :mnas-sdl3-gui/events)

(defgeneric process-sdl-event (tracker ev)
  (:documentation
   "Update tracker (an event-tracker) from SDL event ev. Per-event-type
processing for event tracking."))

(defgeneric log-event (ev)
  (:documentation
   "Log a single SDL event object ev in a human-readable form. Specialize
on sdl3:* event classes."))

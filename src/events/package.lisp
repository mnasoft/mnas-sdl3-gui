;;;; ./src/events/package.lisp

(defpackage :mnas-sdl3-gui/events
  (:use #:cl)
  (:export #:event-tracker-instance
           #:make-event-tracker
           #:clear-event-tracker
           #:update-from-sdl-event
           #:log-event))

(in-package :mnas-sdl3-gui/events)

;;; Utilities and the event tracker implementation live in
;;; ./src/events/event-tracker.lisp

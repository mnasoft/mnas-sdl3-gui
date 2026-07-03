;;;; ./src/app/methods/handle-application-event.lisp

(in-package :mnas-sdl3-gui/app)

(defmethod handle-application-event ((application <app>) type event)
  (declare (ignore application type event))
  :continue)

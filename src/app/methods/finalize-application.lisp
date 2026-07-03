;;;; ./src/app/methods/finalize-application.lisp

(in-package :mnas-sdl3-gui/app)

(defmethod finalize-application ((application <app>) &optional result)
  (declare (ignore result))
  application)

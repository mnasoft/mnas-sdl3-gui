;;;; ./src/app/generics.lisp

(in-package :mnas-sdl3-gui/app)

(defgeneric initialize-application (application)
  (:documentation "Initialize runtime resources for APPLICATION."))

(defgeneric render-application (application)
  (:documentation "Render APPLICATION."))

(defgeneric handle-application-event (application type event)
  (:documentation "Handle EVENT for APPLICATION."))

(defgeneric finalize-application (application &optional result)
  (:documentation "Release resources and finalize APPLICATION."))

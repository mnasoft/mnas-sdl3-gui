;;;; ./src/app/classes.lisp

(in-package :mnas-sdl3-gui/app)

(defclass <application> ()
  ((title
    :initarg :title
    :initform "Application"
    :accessor app-title)
   (width
    :initarg :width
    :initform 640
    :accessor app-width)
   (height
    :initarg :height
    :initform 480
    :accessor app-height)
   (style
    :initarg :style
    :initform :windows
    :accessor app-style)
   (window
    :initarg :window
    :initform nil
    :accessor app-window)
   (window-id
    :initarg :window-id
    :initform 0
    :accessor app-window-id)
   (renderer
    :initarg :renderer
    :initform nil
    :accessor app-renderer)
   (layer-manager
    :initarg :layer-manager
    :initform nil
    :accessor app-layer-manager)
   (toolbar
    :initarg :toolbar
    :initform nil
    :accessor app-toolbar)
   (open-p
    :initarg :open-p
    :initform t
    :accessor app-open-p)
   (status
    :initarg :status
    :initform ""
    :accessor app-status)
   (widgets
    :initarg :widgets
    :initform nil
    :accessor app-widgets)
   (result
    :initarg :result
    :initform nil
    :accessor app-result)))

(defgeneric initialize-application (application)
  (:documentation "Initialize runtime resources for APPLICATION."))

(defgeneric render-application (application)
  (:documentation "Render APPLICATION."))

(defgeneric handle-application-event (application type event)
  (:documentation "Handle EVENT for APPLICATION."))

(defgeneric finalize-application (application &optional result)
  (:documentation "Release resources and finalize APPLICATION."))

(defmethod initialize-application ((application <application>))
  application)

(defmethod render-application ((application <application>))
  :continue)

(defmethod handle-application-event ((application <application>) type event)
  (declare (ignore application type event))
  :continue)

(defmethod finalize-application ((application <application>) &optional result)
  (declare (ignore result))
  application)

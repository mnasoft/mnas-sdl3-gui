;;;; ./src/app/classes.lisp

(in-package :mnas-sdl3-gui/app)

(defclass <app> ()
  ((title
    :initarg :title
    :initform "Application"
    :accessor <app>-title
    :documentation "Window title shown by the application.")
   (width
    :initarg :width
    :initform 640
    :accessor <app>-width
    :documentation "Initial window width in pixels.")
   (height
    :initarg :height
    :initform 480
    :accessor <app>-height
    :documentation "Initial window height in pixels.")
   (style
    :initarg :style
    :initform :windows
    :accessor <app>-style
    :documentation "Visual style used by widgets and controls.")
   (window
    :initarg :window
    :initform nil
    :accessor <app>-window
    :documentation "SDL window instance associated with the application.")
   (window-id
    :initarg :window-id
    :initform 0
    :accessor <app>-window-id
    :documentation "Identifier of the application window.")
   (renderer
    :initarg :renderer
    :initform nil
    :accessor <app>-renderer
    :documentation "SDL renderer used to draw the application.")
   (layer-manager
    :initarg :layer-manager
    :initform nil
    :accessor <app>-layer-manager
    :documentation "Window layer manager used for stacking and focus handling.")
   (toolbar
    :initarg :toolbar
    :initform nil
    :accessor <app>-toolbar
    :documentation "Toolbar attached to the application window.")
   (open-p
    :initarg :open-p
    :initform t
    :accessor <app>-open-p
    :documentation "Whether the application is currently open and active.")
   (status
    :initarg :status
    :initform ""
    :accessor <app>-status
    :documentation "Current status message displayed by the application.")
   (widgets
    :initarg :widgets
    :initform nil
    :accessor <app>-widgets
    :documentation "List of widgets owned by the application.")
   (result
    :initarg :result
    :initform nil
    :accessor <app>-result
    :documentation "Final result value returned when the application terminates."))
  (:documentation "Base application object for SDL3 GUI applications."))

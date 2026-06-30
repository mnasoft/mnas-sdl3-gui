;;;; ./demos/dialog/window/window-01/parameters.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

(defparameter *window* nil)
(defparameter *renderer* nil)
(defparameter *window-id* 0)
(defparameter *layer-manager* nil)
(defparameter *toolbar* nil)
(defparameter *open* t)
(defparameter +default-width+ 640)
(defparameter +default-height+ 360)
(defparameter *width* +default-width+)
(defparameter *height* +default-height+)
(defparameter *demo-title* "Resizable Window Demo")
(defparameter *demo-flags* :resizable)

(defparameter +modal-1-id+ 10001)
(defparameter +modal-2-id+ 10002)
(defparameter *modal-1-open* nil)
(defparameter *modal-2-open* nil)
(defparameter *show-grid* nil)

(defparameter +toolbar-x+ 24.0)
(defparameter +toolbar-y+ 208.0)
(defparameter +toolbar-width+ 592.0)
(defparameter +toolbar-height+ 40.0)
(defparameter +mouse-left+ 1)

(defparameter *all-flags*
  '(:fullscreen
    :opengl
    :occluded
    :hidden
    :borderless
    :resizable
    :minimized
    :maximized
    :mouse-grabbed
    :input-focus
    :mouse-focus
    :external
    :modal
    :high-pixel-density
    :mouse-capture
    :mouse-relative-mode
    :always-on-top
    :utility
    :tooltip
    :popup-menu
    :keyboard-grabbed
    :vulkan
    :metal
    :transparent
    :not-focusable))

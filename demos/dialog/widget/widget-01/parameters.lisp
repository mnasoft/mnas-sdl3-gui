;;;; ./demos/dialog/widget/widget-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/widget-01)

(defparameter *window* nil)
(defparameter *render* nil)
(defparameter *layer-manager* nil)
(defparameter *widgets* nil)
(defparameter *widget-root* nil)
(defparameter *toolbar* nil)
(defparameter *open* t)
(defparameter *status-message* "Widget demo. Click, type, and interact with controls.")
(defparameter *style* :flat)

(defparameter +toolbar-x+ 20.0)
(defparameter +toolbar-y+ 400.0)
(defparameter +toolbar-width+ 300.0)
(defparameter +toolbar-height+ 34.0)

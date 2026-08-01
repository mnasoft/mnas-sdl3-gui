

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

(defparameter *window* nil)
(defparameter *window-id* 0)
(defparameter *renderer* nil)
(defparameter *toolbar* nil)
(defparameter *simple-01-layer-manager* nil)
(defparameter *dialog-root* nil)
(defparameter *dialog-result* nil)
(defparameter *dialog-open* t)
(defparameter *dialog-style* :windows)

;; Dialog state
(defparameter *ok-button* nil)
(defparameter *cancel-button* nil)
(defparameter *extra-button* nil)
(defparameter *message* "Are you sure you want to continue?")
(defparameter +simple-dialog-window-height+ 532)
(defparameter +simple-dialog-toolbar-height+ 32)

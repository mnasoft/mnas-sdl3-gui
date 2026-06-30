;;;; ./demos/dialog/window/window-02/parameters.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(defparameter *main-window* nil)
(defparameter *main-renderer* nil)
(defparameter *main-id* 0)

(defparameter *layer-manager* nil)
(defparameter *toolbar* nil)

(defparameter *popup-window* nil)
(defparameter *popup-renderer* nil)
(defparameter *popup-id* 0)
(defparameter *popup-visible* nil)
(defparameter *pin-popup* nil)

(defparameter *open* t)
(defparameter *hover-index* nil)
(defparameter *selected-item* "No item selected")
(defparameter *popup-items*
  '("Open"
    "Save"
    "Save As..."
    "Close"))

(defparameter +main-width+ 760)
(defparameter +main-height+ 460)
(defparameter +popup-width+ 230)
(defparameter +popup-item-height+ 36)
(defparameter +popup-padding+ 6)
(defparameter +mouse-left+ 1)
(defparameter +mouse-right+ 3)
(defparameter +toolbar-x+ 28.0)
(defparameter +toolbar-y+ 208.0)
(defparameter +toolbar-width+ 420.0)
(defparameter +toolbar-height+ 40.0)

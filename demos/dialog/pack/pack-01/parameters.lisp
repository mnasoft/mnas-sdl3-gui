;;;; ./demos/dialog/pack/pack-01/parameters.lisp

(in-package :mnas-sdl3-gui/demos/dialog/pack-01)

(defparameter *window* nil)
(defparameter *renderer* nil)
(defparameter *window-id* 0)
(defparameter *layer-manager* nil)
(defparameter *open* t)
(defparameter *style* :windows)
#+nil (defparameter *widgets* nil)
(defparameter *status*
  "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")
(defparameter *status-y* 590.0)

(defparameter +margin+ 16)
(defparameter +section-gap+ 6)
(defparameter +status-band+ 26)
(defparameter +toolbar-height+ 36)
(defparameter +toolbar-x+ 16.0)
(defparameter +toolbar-y+ 16.0)

(defparameter *toggle-light* nil)
(defparameter *toggle-dark* nil)
(defparameter *check-logs* nil)
(defparameter *check-backup* nil)
(defparameter *edit-user* nil)
(defparameter *edit-path* nil)

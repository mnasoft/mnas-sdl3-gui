;;;; ./demos/dialog/entry/entry-01/entry-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)

(defparameter *window* nil)
(defparameter *renderer* nil)
(defparameter *window-id* 0)
(defparameter *layer-manager* nil)
(defparameter *toolbar* nil)
(defparameter *open* t)
(defparameter *result* nil)
(defparameter *input* nil)
(defparameter *ok-button* nil)
(defparameter *style* :flat)
(defparameter *active-modifiers* nil)

(defparameter *title* "Введите текст и нажмите ОК")
(defparameter *hint* "Проверьте кириллицу: Съешь ещё этих мягких булок")


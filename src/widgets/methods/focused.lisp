;;;; ./src/widgets/methods/focused.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod focused ((widget <widget>))
  (<widget>-focused widget))

(defmethod focused ((widgets cons))
  (find-if #'focused widgets))

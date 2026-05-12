;;;; ./src/widgets/methods/edit-box-scroll-to-start.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-scroll-to-start ((widget edit-box))
  (setf (edit-box-scroll-offset widget) 0))
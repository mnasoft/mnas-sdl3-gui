;;;; ./src/widgets/methods/contains-point-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod contains-point-p ((widget widget) x y)
  (and (<= (widget-x widget) x (+ (widget-x widget) (widget-width widget)))
       (<= (widget-y widget) y (+ (widget-y widget) (widget-height widget)))))
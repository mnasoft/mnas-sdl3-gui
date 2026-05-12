;;;; ./src/widgets/methods/edit-box-visible-text-width.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-visible-text-width ((widget edit-box))
  (max 1 (- (widget-width widget) (* 2 +widget-padding+))))
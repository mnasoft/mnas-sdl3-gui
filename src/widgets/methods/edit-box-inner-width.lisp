;;;; ./src/widgets/methods/edit-box-inner-width.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-inner-width ((widget edit-box))
  (max 1 (- (widget-width widget) 8)))

(defmethod edit-box-inner-width ((widget editable-combo-box))
  (let ((arrow-width 24))
    (max 1 (- (widget-width widget) (+ 8 arrow-width)))))
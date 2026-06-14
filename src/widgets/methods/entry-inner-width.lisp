;;;; ./src/widgets/methods/entry-inner-width.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-inner-width ((widget entry))
  (max 1 (- (<widget>-width widget) 8)))

(defmethod entry-inner-width ((widget editable-combo-box))
  (let ((arrow-width 24))
    (max 1 (- (<widget>-width widget) (+ 8 arrow-width)))))
;;;; ./src/widgets/methods/clear-edit-box-selection.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod clear-edit-box-selection ((widget edit-box))
  (setf (edit-box-selection-start widget) nil
        (edit-box-selection-end widget) nil))
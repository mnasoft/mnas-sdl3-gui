;;;; ./src/widgets/methods/edit-box-select-to-end.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-to-end ((widget edit-box))
  (let ((anchor (edit-box-selection-anchor widget)))
    (setf (edit-box-cursor widget) (length (edit-box-text widget)))
    (edit-box-scroll-to-end widget)
    (edit-box-select-from-anchor widget anchor))
  t)
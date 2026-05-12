;;;; ./src/widgets/methods/edit-box-select-to-start.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-to-start ((widget edit-box))
  (let ((anchor (edit-box-selection-anchor widget)))
    (setf (edit-box-cursor widget) 0)
    (edit-box-scroll-to-start widget)
    (edit-box-select-from-anchor widget anchor))
  t)
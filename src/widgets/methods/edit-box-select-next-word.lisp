;;;; ./src/widgets/methods/edit-box-select-next-word.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-next-word ((widget edit-box))
  (let ((anchor (edit-box-selection-anchor widget)))
    (edit-box-move-to-next-word widget)
    (edit-box-select-from-anchor widget anchor))
  t)
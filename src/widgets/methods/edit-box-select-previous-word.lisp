;;;; ./src/widgets/methods/edit-box-select-previous-word.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-previous-word ((widget edit-box))
  (let ((anchor (edit-box-selection-anchor widget)))
    (edit-box-move-to-previous-word widget)
    (edit-box-select-from-anchor widget anchor))
  t)
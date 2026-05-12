;;;; ./src/widgets/methods/edit-box-select-previous-char.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-previous-char ((widget edit-box))
  (let ((anchor (edit-box-selection-anchor widget)))
    (when (> (edit-box-cursor widget) 0)
      (decf (edit-box-cursor widget))
      (edit-box-ensure-cursor-visible widget)
      (edit-box-select-from-anchor widget anchor)))
  t)
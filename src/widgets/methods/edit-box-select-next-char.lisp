;;;; ./src/widgets/methods/edit-box-select-next-char.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-next-char ((widget edit-box))
  (let ((anchor (edit-box-selection-anchor widget))
        (text-len (length (edit-box-text widget))))
    (when (< (edit-box-cursor widget) text-len)
      (incf (edit-box-cursor widget))
      (edit-box-ensure-cursor-visible widget)
      (edit-box-select-from-anchor widget anchor)))
  t)
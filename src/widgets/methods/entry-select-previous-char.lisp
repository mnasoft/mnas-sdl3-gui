;;;; ./src/widgets/methods/entry-select-previous-char.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-select-previous-char ((widget entry))
  (let ((anchor (entry-selection-anchor widget)))
    (when (> (entry-cursor widget) 0)
      (decf (entry-cursor widget))
      (entry-ensure-cursor-visible widget)
      (entry-select-from-anchor widget anchor)))
  t)
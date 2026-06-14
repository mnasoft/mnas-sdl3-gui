;;;; ./src/widgets/methods/entry-select-previous-char.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-select-previous-char ((obj entry))
  (let ((anchor (entry-selection-anchor obj)))
    (when (> (entry-cursor obj) 0)
      (decf (entry-cursor obj))
      (entry-ensure-cursor-visible obj)
      (entry-select-from-anchor obj anchor)))
  t)

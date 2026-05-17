;;;; ./src/widgets/methods/entry-select-previous-word.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-select-previous-word ((widget entry))
  (let ((anchor (entry-selection-anchor widget)))
    (entry-move-to-previous-word widget)
    (entry-select-from-anchor widget anchor))
  t)
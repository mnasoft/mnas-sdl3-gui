;;;; ./src/widgets/methods/<entry>-select-next-word.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-select-next-word ((widget <entry>))
  (let ((anchor (<entry>-selection-anchor widget)))
    (<entry>-move-to-next-word widget)
    (<entry>-select-from-anchor widget anchor))
  t)
;;;; ./src/widgets/methods/<entry>-select-to-end.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-select-to-end ((widget <entry>))
  (let ((anchor (<entry>-selection-anchor widget)))
    (setf (<entry>-cursor widget) (length (<entry>-text widget)))
    (<entry>-scroll-to-end widget)
    (<entry>-select-from-anchor widget anchor))
  t)
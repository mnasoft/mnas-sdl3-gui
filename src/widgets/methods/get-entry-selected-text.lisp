;;;; ./src/widgets/methods/get-<entry>-selected-text.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod get-<entry>-selected-text ((widget <entry>))
  (let ((start (<entry>-selection-start widget))
        (end (<entry>-selection-end widget)))
    (if (and start end (< start end))
        (subseq (<entry>-text widget) start end)
        "")))

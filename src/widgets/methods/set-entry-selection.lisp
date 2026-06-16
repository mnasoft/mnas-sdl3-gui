;;;; ./src/widgets/methods/set-<entry>-selection.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod set-<entry>-selection ((widget <entry>) start end)
  (let ((text-len (length (<entry>-text widget))))
    (setf (<entry>-selection-start widget) (max 0 (min start text-len))
          (<entry>-selection-end widget) (max 0 (min end text-len)))))

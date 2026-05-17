;;;; ./src/widgets/methods/entry-selection-anchor.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-selection-anchor ((widget entry))
  (let ((start (entry-selection-start widget))
        (end (entry-selection-end widget))
        (cursor (entry-cursor widget)))
    (cond
      ((and start end (< start end))
       (if (= cursor start) end start))
      (t cursor))))
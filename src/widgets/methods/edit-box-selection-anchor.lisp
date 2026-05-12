;;;; ./src/widgets/methods/edit-box-selection-anchor.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-selection-anchor ((widget edit-box))
  (let ((start (edit-box-selection-start widget))
        (end (edit-box-selection-end widget))
        (cursor (edit-box-cursor widget)))
    (cond
      ((and start end (< start end))
       (if (= cursor start) end start))
      (t cursor))))
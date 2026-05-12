;;;; ./src/widgets/methods/get-edit-box-selected-text.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod get-edit-box-selected-text ((widget edit-box))
  (let ((start (edit-box-selection-start widget))
        (end (edit-box-selection-end widget)))
    (if (and start end (< start end))
        (subseq (edit-box-text widget) start end)
        "")))
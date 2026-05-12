;;;; ./src/widgets/methods/set-edit-box-selection.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod set-edit-box-selection ((widget edit-box) start end)
  (let ((text-len (length (edit-box-text widget))))
    (setf (edit-box-selection-start widget) (max 0 (min start text-len))
          (edit-box-selection-end widget) (max 0 (min end text-len)))))
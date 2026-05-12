;;;; ./src/widgets/methods/edit-box-scroll-to-end.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-scroll-to-end ((widget edit-box))
  (let* ((text-len (length (edit-box-text widget)))
         (visible-width (edit-box-inner-width widget))
         (start text-len))
    (loop while (> start 0)
          for candidate = (1- start)
          while (<= (edit-box-text-width-between widget candidate text-len) visible-width)
          do (decf start))
    (setf (edit-box-scroll-offset widget) start)))
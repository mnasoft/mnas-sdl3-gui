;;;; ./src/widgets/methods/normalize-edit-box-scroll-offset.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod normalize-edit-box-scroll-offset ((widget edit-box))
  (let* ((text (edit-box-text widget))
         (text-len (length text))
         (visible-width (edit-box-inner-width widget))
         (start (max 0 (min (edit-box-scroll-offset widget) text-len))))
    (loop while (> start 0)
          for candidate = (1- start)
          while (<= (edit-box-text-width-between widget candidate text-len) visible-width)
          do (decf start))
    (setf (edit-box-scroll-offset widget) start)))
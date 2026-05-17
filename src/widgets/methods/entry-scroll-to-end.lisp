;;;; ./src/widgets/methods/entry-scroll-to-end.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-scroll-to-end ((widget entry))
  (let* ((text-len (length (entry-text widget)))
         (visible-width (entry-inner-width widget))
         (start text-len))
    (loop while (> start 0)
          for candidate = (1- start)
          while (<= (entry-text-width-between widget candidate text-len) visible-width)
          do (decf start))
    (setf (entry-scroll-offset widget) start)))
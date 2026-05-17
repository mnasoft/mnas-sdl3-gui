;;;; ./src/widgets/methods/normalize-entry-scroll-offset.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod normalize-entry-scroll-offset ((widget entry))
  (let* ((text (entry-text widget))
         (text-len (length text))
         (visible-width (entry-inner-width widget))
         (start (max 0 (min (entry-scroll-offset widget) text-len))))
    (loop while (> start 0)
          for candidate = (1- start)
          while (<= (entry-text-width-between widget candidate text-len) visible-width)
          do (decf start))
    (setf (entry-scroll-offset widget) start)))
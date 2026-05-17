;;;; ./src/widgets/methods/entry-ensure-cursor-visible.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-ensure-cursor-visible ((widget entry))
  (let* ((cursor (max 0 (min (entry-cursor widget) (length (entry-text widget)))))
         (visible-width (entry-inner-width widget))
         (start (max 0 (min (entry-scroll-offset widget) cursor))))
    (when (< cursor start)
      (setf start cursor))
    (loop while (> (entry-text-width-between widget start cursor) visible-width)
          do (incf start))
    (setf (entry-scroll-offset widget) start)
    (normalize-entry-scroll-offset widget)))
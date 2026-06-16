;;;; ./src/widgets/methods/<entry>-position-from-pixel.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-position-from-pixel ((widget <entry>) x)
  (let* ((text-len (length (<entry>-text widget)))
         (visible-start (max 0 (min (<entry>-scroll-offset widget) text-len)))
         (visible-width (<entry>-inner-width widget))
         (relative-x (max 0 (min (- x (<widget>-x widget) 4) visible-width)))
         (previous-width 0))
    (loop for position from visible-start below text-len
          for next-width = (<entry>-text-width-between widget visible-start (1+ position))
          for midpoint = (+ previous-width (/ (- next-width previous-width) 2))
          do (when (<= relative-x midpoint)
               (return position))
             (setf previous-width next-width)
          finally (return text-len))))

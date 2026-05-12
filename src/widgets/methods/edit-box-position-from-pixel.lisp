;;;; ./src/widgets/methods/edit-box-position-from-pixel.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-position-from-pixel ((widget edit-box) x)
  (let* ((text-len (length (edit-box-text widget)))
         (visible-start (max 0 (min (edit-box-scroll-offset widget) text-len)))
         (visible-width (edit-box-inner-width widget))
         (relative-x (max 0 (min (- x (widget-x widget) 4) visible-width)))
         (previous-width 0))
    (loop for position from visible-start below text-len
          for next-width = (edit-box-text-width-between widget visible-start (1+ position))
          for midpoint = (+ previous-width (/ (- next-width previous-width) 2))
          do (when (<= relative-x midpoint)
               (return position))
             (setf previous-width next-width)
          finally (return text-len))))
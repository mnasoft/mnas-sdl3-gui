;;;; ./src/widgets/methods/edit-box-visible-range.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-visible-range ((widget edit-box))
  (let* ((text-len (length (edit-box-text widget)))
         (start (max 0 (min (edit-box-scroll-offset widget) text-len)))
         (visible-width (edit-box-visible-text-width widget))
         (end start))
    (loop while (< end text-len)
          for candidate = (1+ end)
          while (<= (compute-text-segment-pixel-width widget start candidate)
                    visible-width)
          do (incf end))
    (values start end)))
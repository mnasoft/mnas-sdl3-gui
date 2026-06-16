;;;; ./src/widgets/methods/<entry>-visible-range.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-visible-range ((widget <entry>))
  (let* ((text-len (length (<entry>-text widget)))
         (start (max 0 (min (<entry>-scroll-offset widget) text-len)))
         (visible-width (<entry>-visible-text-width widget))
         (end start))
    (loop while (< end text-len)
          for candidate = (1+ end)
          while (<= (compute-text-segment-pixel-width widget start candidate)
                    visible-width)
          do (incf end))
    (values start end)))

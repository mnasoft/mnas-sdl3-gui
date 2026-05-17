;;;; ./src/widgets/methods/compute-text-offset-to-position.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod compute-text-offset-to-position ((widget entry) text-pos)
  (let* ((text (entry-text widget))
         (pos (max 0 (min text-pos (length text))))
         (prefix (subseq text 0 pos))
         (display-prefix (or (entry-show-text widget) prefix)))
    (if (and *ttf-available-p* *ttf-font*)
        (handler-case
            (multiple-value-bind (w h)
                (sdl3-ttf:ttf-get-string-size *ttf-font* display-prefix)
              (declare (ignore h))
              (or w 0))
          (error ()
            (* pos +font-char-width+)))
        (* pos +font-char-width+))))
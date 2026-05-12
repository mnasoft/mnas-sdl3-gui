;;;; ./src/widgets/methods/compute-text-offset-to-position.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod compute-text-offset-to-position ((widget edit-box) text-pos)
  (let* ((text (edit-box-text widget))
         (pos (max 0 (min text-pos (length text))))
         (prefix (subseq text 0 pos)))
    (if (and *ttf-available-p* *ttf-font*)
        (handler-case
            (multiple-value-bind (w h)
                (sdl3-ttf:ttf-get-string-size *ttf-font* prefix)
              (declare (ignore h))
              (or w 0))
          (error ()
            (* pos +font-char-width+)))
        (* pos +font-char-width+))))
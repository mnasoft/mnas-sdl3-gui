;;;; ./src/widgets/methods/compute-text-segment-pixel-width.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod compute-text-segment-pixel-width ((widget entry) text-start text-end)
  (let ((text (or (entry-show-text widget)
                  (entry-text widget))))
    (if (>= text-start text-end)
        0
        (let ((segment (subseq text text-start text-end)))
          (if (and *ttf-available-p* *ttf-font*)
              (handler-case
                  (multiple-value-bind (w h)
                      (sdl3-ttf:ttf-get-string-size *ttf-font* segment)
                    (declare (ignore h))
                    (or w 0))
                (error ()
                  (* (length segment) +font-char-width+)))
              (* (length segment) +font-char-width+))))))
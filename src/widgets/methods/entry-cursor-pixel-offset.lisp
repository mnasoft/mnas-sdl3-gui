;;;; ./src/widgets/methods/entry-cursor-pixel-offset.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-cursor-pixel-offset ((obj entry))
  (let* ((text (entry-text obj))
         (cursor (max 0 (min (entry-cursor obj) (length text))))
         (prefix (subseq text 0 cursor)))
    (if (and *ttf-available-p* *ttf-font*)
        (handler-case
            (multiple-value-bind (w h)
                (sdl3-ttf:ttf-get-string-size *ttf-font* prefix)
              (declare (ignore h))
              (or w 0))
          (error ()
            (* cursor +font-char-width+)))
        (* cursor +font-char-width+))))

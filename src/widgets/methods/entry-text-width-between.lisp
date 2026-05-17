;;;; ./src/widgets/methods/entry-text-width-between.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-text-width-between ((widget entry) start end)
  (if (>= start end)
      0
      (let ((text (or (entry-show-text widget)
                      (entry-text widget))))
        (multiple-value-bind (width height)
            (widget-text-pixel-size (subseq text start end))
          (declare (ignore height))
          width))))
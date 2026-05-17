;;;; ./src/widgets/methods/entry-text-width-between.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-text-width-between ((widget entry) start end)
  (if (>= start end)
      0
      (multiple-value-bind (width height)
          (widget-text-pixel-size (subseq (entry-text widget) start end))
        (declare (ignore height))
        width)))
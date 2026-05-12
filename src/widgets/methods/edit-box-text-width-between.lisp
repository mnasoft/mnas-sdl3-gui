;;;; ./src/widgets/methods/edit-box-text-width-between.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-text-width-between ((widget edit-box) start end)
  (if (>= start end)
      0
      (multiple-value-bind (width height)
          (widget-text-pixel-size (subseq (edit-box-text widget) start end))
        (declare (ignore height))
        width)))
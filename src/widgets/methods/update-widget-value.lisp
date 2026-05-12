;;;; ./src/widgets/methods/update-widget-value.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod update-widget-value ((widget widget) new-value)
  (unless (eql (widget-value widget) new-value)
    (setf (widget-value widget) new-value)
    (when (widget-on-change widget)
      (funcall (widget-on-change widget) widget new-value))))
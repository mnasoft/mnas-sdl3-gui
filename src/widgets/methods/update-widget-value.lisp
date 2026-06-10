;;;; ./src/widgets/methods/update-widget-value.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod update-widget-value ((widget widget) new-value)
  (unless (eql (widget-value widget) new-value)
    (setf (widget-value widget) new-value)
    (when (widget-on-change widget)
      (funcall (widget-on-change widget) widget new-value))))

(defmethod update-widget-value ((widget combo-box) new-value)
  "When a combo-box value changes, update header display text as well."  
  (call-next-method)
  (let ((hdr (combo-box-header-widget widget)))
    (when hdr
      (setf (combo-box-header-display-text hdr) (format nil "~a" new-value)))))
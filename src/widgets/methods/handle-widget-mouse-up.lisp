;;;; ./src/widgets/methods/handle-widget-mouse-up.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-widget-mouse-up :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-mouse-up ((widget widget) x y)
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-up ((widget button) x y)
  (let* ((inside (contains-point-p widget x y))
         (armed (button-armed-p widget))
         (activate (and armed inside)))
    (setf (button-pressed-p widget) nil
          (button-armed-p widget) nil)
    (when activate
      (when (button-on-click widget)
        (funcall (button-on-click widget) widget)))
    (or armed inside)))
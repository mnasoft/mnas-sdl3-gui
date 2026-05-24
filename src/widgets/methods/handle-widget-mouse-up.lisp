;;;; ./src/widgets/methods/handle-widget-mouse-up.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-widget-mouse-up :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-mouse-up ((widget widget) x y)
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-up ((widget widget-container) x y)
  (when (contains-point-p widget x y)
    (dolist (child (widgets-in-hit-test-order (children widget)))
      (when (handle-widget-mouse-up child x y)
        (return t)))
    nil))

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

(defmethod handle-widget-mouse-up ((widget list-box) x y)
  (declare (ignore x y))
  (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
    (setf (list-box-scrollbar-dragging-p widget) nil
          (list-box-scrollbar-drag-offset widget) 0)
    dragging-p))

(defmethod handle-widget-mouse-up ((widget combo-box) x y)
  (declare (ignore x y))
  (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
    (setf (list-box-scrollbar-dragging-p widget) nil
          (list-box-scrollbar-drag-offset widget) 0)
    dragging-p))
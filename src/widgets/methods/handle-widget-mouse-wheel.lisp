;;;; ./src/widgets/methods/handle-widget-mouse-wheel.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-widget-mouse-wheel :around ((widget widget) x y dx dy)
  (when (and (visible-p widget) (enabled-p widget))
    (call-next-method)))

(defmethod handle-widget-mouse-wheel ((widget widget) x y dx dy)
  (declare (ignore x y dx dy))
  nil)

(defmethod handle-widget-mouse-wheel ((widget widget-container) x y dx dy)
  (when (contains-point-p widget x y)
    (handle-widget-mouse-wheel (children widget) x y dx dy)))

(defmethod handle-widget-mouse-wheel ((widget scroll-container) x y dx dy)
  (when (contains-point-p widget x y)
    (or (handle-widget-mouse-wheel (children widget) x y dx dy)
        (scroll-by widget (- dy)))))

(defmethod handle-widget-mouse-wheel ((widget combo-box) x y dx dy)
  (when (and (contains-point-p widget x y)
             (combo-box-expanded-p widget))
    (scroll-by widget (- dy))))

(defmethod handle-widget-mouse-wheel ((widget tree-view) x y dx dy)
  (when (contains-point-p widget x y)
    (scroll-by widget (- dy))))

(defmethod handle-widget-mouse-wheel ((widget list-box) x y dx dy)
  (when (contains-point-p widget x y)
    (scroll-by widget (- dy))))

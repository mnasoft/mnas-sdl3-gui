;;;; ./src/widgets/methods/handle-widget-mouse-down.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-widget-mouse-down :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-mouse-down ((widget widget) x y)
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-down ((widget button) x y)
  (let ((inside (contains-point-p widget x y)))
    (setf (button-armed-p widget) inside
          (button-pressed-p widget) inside
          (widget-focused widget) inside)
    inside))

(defmethod handle-widget-mouse-down ((widget toggle) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      (select-toggle-in-group widget)
      t)))

(defmethod handle-widget-mouse-down ((widget check-box) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      (setf (check-box-checked widget) (not (check-box-checked widget)))
      (update-widget-value widget (check-box-checked widget))
      t)))

(defmethod handle-widget-mouse-down ((widget edit-box) x y)
  (let ((inside (contains-point-p widget x y)))
    (setf (widget-focused widget) inside)
    (when inside
      (setf (edit-box-cursor widget) (edit-box-position-from-pixel widget x))
      (clear-edit-box-selection widget)
      (edit-box-ensure-cursor-visible widget))
    inside))

(defmethod handle-widget-mouse-down ((widget list-box) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (let ((rel-y (- y (widget-y widget)))
            (item-height (list-box-item-height widget)))
        (when (plusp rel-y)
          (let ((new-index (floor rel-y item-height)))
            (when (< new-index (length (list-box-items widget)))
              (setf (list-box-selected-index widget) new-index)
              (update-widget-value widget
                                   (nth new-index (list-box-items widget)))))))
      t)))
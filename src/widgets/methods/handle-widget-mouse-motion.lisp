;;;; ./src/widgets/methods/handle-widget-mouse-motion.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Ensure only enabled/visible widgets handle motion.
(defmethod handle-widget-mouse-motion :around ((widget widget) x y)
  (when (and (widget-enabled widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-widget-mouse-motion ((widget widget) x y)
  "Default no-op for generic widgets."
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-motion ((widget widget-container) x y)
  "Propagate mouse-motion to children in hit-test order."
  (dolist (child (widgets-in-hit-test-order (children widget)))
    (handle-widget-mouse-motion child x y))
  nil)

(defmethod handle-widget-mouse-motion ((widget combo-box) x y)
  "Handle scrollbar thumb dragging when combo-box popup is expanded."
  (when (and (combo-box-expanded-p widget)
             (list-box-scrollbar-dragging-p widget))
    (combo-box-set-scroll-offset-from-thumb-top
     widget
     (- y (list-box-scrollbar-drag-offset widget))))
  nil)

(defmethod handle-widget-mouse-motion ((widget list-box) x y)
  "Handle scrollbar thumb dragging for list-box."
  (when (list-box-scrollbar-dragging-p widget)
    (list-box-set-scroll-offset-from-thumb-top
     widget
     (- y (list-box-scrollbar-drag-offset widget))))
  nil)

(defmethod handle-widget-mouse-motion ((widget button) x y)
  "Update pressed state for armed buttons while moving the mouse."
  (let ((inside (contains-point-p widget x y)))
    (when (button-armed-p widget)
      (setf (button-pressed-p widget) inside)))
  nil)

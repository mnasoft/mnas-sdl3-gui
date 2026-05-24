;;;; ./src/widgets/methods/scroll-by.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Guard that only enabled and visible widgets handle scroll requests.
(defmethod scroll-by :around ((widget widget) delta)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod scroll-by ((widget widget) delta)
  "Default no-op for widgets that do not implement scrolling."
  (declare (ignore delta))
  nil)

(defmethod scroll-by ((widget list-box) delta)
  "Scroll LIST-BOX by DELTA rows. Returns T when offset changed."
  (let ((old-offset (list-box-scroll-offset widget)))
    (setf (list-box-scroll-offset widget)
          (+ old-offset delta))
    (normalize-list-box-scroll-offset widget)
    (/= old-offset (list-box-scroll-offset widget))))

(defmethod scroll-by ((widget scroll-container) delta)
  "Scroll SCROLL-CONTAINER by DELTA pixels. Returns T when offset changed."
  (let ((old-offset (scroll-container-scroll-offset widget)))
    (setf (scroll-container-scroll-offset widget)
          (+ old-offset delta))
    (normalize-scroll-container-scroll-offset widget)
    (/= old-offset (scroll-container-scroll-offset widget))))

(defmethod scroll-by ((widget tree-view) delta)
  "Scroll TREE-VIEW by DELTA rows. Returns T when offset changed."
  (let ((old-offset (tree-view-scroll-offset widget)))
    (setf (tree-view-scroll-offset widget)
          (+ old-offset delta))
    (normalize-tree-view-scroll-offset widget)
    (/= old-offset (tree-view-scroll-offset widget))))

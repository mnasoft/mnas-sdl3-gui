;;;; ./src/widgets/methods/handle-widget-mouse-down.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-widget-mouse-down :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-mouse-down ((widget widget) x y)
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-down ((widget widget-container) x y)
  (when (contains-point-p widget x y)
    (loop for child in (widgets-in-hit-test-order (children widget))
          when (handle-widget-mouse-down child x y)
            do (setf (widget-focused widget) t)
               (return t)
          finally (return nil))))

(defmethod handle-widget-mouse-down ((widget canvas-2d-widget) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      t)))

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

(defmethod handle-widget-mouse-down ((widget entry) x y)
  (let ((inside (contains-point-p widget x y)))
    (setf (widget-focused widget) inside)
    (when inside
      (setf (entry-cursor widget) (entry-position-from-pixel widget x))
      (clear-entry-selection widget)
      (entry-ensure-cursor-visible widget))
    inside))

(defmethod handle-widget-mouse-down ((widget tree-view) x y)
  (let ((inside (contains-point-p widget x y)))
    (setf (widget-focused widget) inside)
    (when inside
      (let* ((rows (tree-view-visible-rows widget))
             (row-height (max 16 (tree-view-row-height widget)))
             (row-index (+ (tree-view-scroll-offset widget)
                           (floor (- y (widget-y widget)) row-height))))
        (when (and (>= row-index 0) (< row-index (length rows)))
          (destructuring-bind (node depth) (nth row-index rows)
            (let* ((toggle-x (+ (widget-x widget)
                                +widget-padding+
                                (* depth (max 8 (tree-view-indent-width widget)))))
                   (toggle-hit (and (tree-node-has-children-p node)
                                    (<= toggle-x x (+ toggle-x 10)))))
              (when toggle-hit
                (tree-view-toggle-node-expanded widget node))
              (tree-view-select-node widget node)))))
      t)))

(defmethod handle-widget-mouse-down ((widget list-box) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      (normalize-list-box-scroll-offset widget)
      (let* ((scrollbar-width +list-box-scrollbar-width+)
             (visible-count (list-box-visible-item-count widget))
             (scrollbar-needed-p (list-box-scrollbar-needed-p widget))
             (content-width (list-box-content-width widget))
             (item-height (list-box-item-height widget))
             (rel-x (- x (widget-x widget)))
             (rel-y (- y (widget-y widget))))
        (cond
          ((and scrollbar-needed-p (>= rel-x content-width))
           (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
               (list-box-scrollbar-geometry widget)
             (declare (ignore needed-p track-x track-height max-offset))
             (let ((thumb-hit-p (<= thumb-y y (+ thumb-y thumb-height))))
               (setf (list-box-scrollbar-dragging-p widget) t
                     (list-box-scrollbar-drag-offset widget)
                     (if thumb-hit-p
                         (- y thumb-y)
                         (floor thumb-height 2)))
               (list-box-set-scroll-offset-from-thumb-top
                widget
                (- y (list-box-scrollbar-drag-offset widget))))))
          ((and (>= rel-y 0) (< rel-x content-width))
           (setf (list-box-scrollbar-dragging-p widget) nil)
           (let* ((row (floor rel-y item-height))
                  (new-index (+ (list-box-scroll-offset widget) row)))
             (when (and (< row visible-count)
                        (< new-index (length (list-box-items widget))))
               (setf (list-box-selected-index widget) new-index)
               (update-widget-value widget
                                    (nth new-index (list-box-items widget))))))
          (t
           (setf (list-box-scrollbar-dragging-p widget) nil))))
      t)))

(defmethod handle-widget-mouse-down ((widget editable-combo-box) x y)
  (let* ((inside (contains-point-p widget x y))
         (main-height (combo-box-main-height widget))
         (main-x (widget-x widget))
         (main-y (widget-y widget))
         (main-width (widget-width widget))
         (arrow-width 24)
         (popup-y (+ main-y main-height)))
    (when inside
            (format t "[combo-box] mouse-down x=~D y=~D arrow-hit=~A expanded=~A mode=~A enabled=~A host=~S popup-id=~S~%"
              x y
              (>= x (- (+ main-x main-width) arrow-width))
              (combo-box-expanded-p widget)
              (combo-box-popup-mode widget)
              (combo-box-popup-window-enabled-p widget)
              (combo-box-popup-host-window widget)
              (combo-box-popup-window-id widget))
      (setf (widget-focused widget) t)
      (cond
        ((and (<= main-y y (+ main-y main-height))
              (>= x main-x)
              (< x (+ main-x main-width)))
         (if (>= x (- (+ main-x main-width) arrow-width))
             (progn
               (sync-combo-box-expanded-state widget (not (combo-box-expanded-p widget)))
               (when (combo-box-expanded-p widget)
                 (ensure-combo-box-selection-visible widget)))
             (progn
               (setf (entry-cursor widget) (entry-position-from-pixel widget x)
                     (entry-selection-start widget) nil
                     (entry-selection-end widget) nil)
               (entry-ensure-cursor-visible widget)
               (when (combo-box-expanded-p widget)
                 (sync-combo-box-expanded-state widget nil)))))
          ((and (combo-box-expanded-p widget)
            (not (combo-box-popup-window-enabled-p widget))
            (>= y popup-y)
            (< y (+ popup-y (combo-box-popup-height widget))))
         (normalize-combo-box-scroll-offset widget)
         (let* ((scrollbar-width +list-box-scrollbar-width+)
                (visible-count (combo-box-visible-item-count widget))
                (scrollbar-needed-p (combo-box-scrollbar-needed-p widget))
                (content-width (combo-box-content-width widget))
                (item-height (list-box-item-height widget))
                (rel-x (- x (widget-x widget)))
                (rel-y (- y popup-y)))
           (cond
             ((and scrollbar-needed-p (>= rel-x content-width))
              (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
                  (combo-box-scrollbar-geometry widget)
                (declare (ignore needed-p track-x track-height max-offset))
                (let ((thumb-hit-p (<= thumb-y y (+ thumb-y thumb-height))))
                  (setf (list-box-scrollbar-dragging-p widget) t
                        (list-box-scrollbar-drag-offset widget)
                        (if thumb-hit-p
                            (- y thumb-y)
                            (floor thumb-height 2)))
                  (combo-box-set-scroll-offset-from-thumb-top
                   widget
                   (- y (list-box-scrollbar-drag-offset widget))))))
             ((>= rel-y 0)
              (setf (list-box-scrollbar-dragging-p widget) nil)
              (let* ((row (floor rel-y item-height))
                     (new-index (+ (list-box-scroll-offset widget) row)))
                (when (and (< row visible-count)
                           (< new-index (length (list-box-items widget))))
                  (setf (list-box-selected-index widget) new-index
                        (entry-text widget) (format nil "~a" (nth new-index (list-box-items widget)))
                        (entry-cursor widget) (length (entry-text widget)))
                  (sync-combo-box-expanded-state widget nil)
                  (update-widget-value widget
                                       (nth new-index (list-box-items widget))))))
             (t
              (setf (list-box-scrollbar-dragging-p widget) nil)
              (sync-combo-box-expanded-state widget nil))))))
      t)))

(defmethod handle-widget-mouse-down ((widget combo-box) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      (cond
        ((<= (widget-y widget) y (+ (widget-y widget) (combo-box-main-height widget)))
         (sync-combo-box-expanded-state widget (not (combo-box-expanded-p widget)))
         (when (combo-box-expanded-p widget)
           (ensure-combo-box-selection-visible widget)))
          ((and (combo-box-expanded-p widget)
            (not (combo-box-popup-window-enabled-p widget)))
         (normalize-combo-box-scroll-offset widget)
         (let* ((scrollbar-width +list-box-scrollbar-width+)
                (visible-count (combo-box-visible-item-count widget))
                (scrollbar-needed-p (combo-box-scrollbar-needed-p widget))
                (content-width (combo-box-content-width widget))
                (item-height (list-box-item-height widget))
                (rel-x (- x (widget-x widget)))
                (rel-y (- y (combo-box-popup-y widget))))
           (cond
             ((and scrollbar-needed-p (>= rel-x content-width))
              (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
                  (combo-box-scrollbar-geometry widget)
                (declare (ignore needed-p track-x track-height max-offset))
                (let ((thumb-hit-p (<= thumb-y y (+ thumb-y thumb-height))))
                  (setf (list-box-scrollbar-dragging-p widget) t
                        (list-box-scrollbar-drag-offset widget)
                        (if thumb-hit-p
                            (- y thumb-y)
                            (floor thumb-height 2)))
                  (combo-box-set-scroll-offset-from-thumb-top
                   widget
                   (- y (list-box-scrollbar-drag-offset widget))))))
             ((>= rel-y 0)
              (setf (list-box-scrollbar-dragging-p widget) nil)
              (let* ((row (floor rel-y item-height))
                     (new-index (+ (list-box-scroll-offset widget) row)))
                (when (and (< row visible-count)
                           (< new-index (length (list-box-items widget))))
                  (setf (list-box-selected-index widget) new-index
                    )
                  (sync-combo-box-expanded-state widget nil)
                  (update-widget-value widget
                                       (nth new-index (list-box-items widget))))))
             (t
              (setf (list-box-scrollbar-dragging-p widget) nil
                    )
                  (sync-combo-box-expanded-state widget nil))))))
      t)))

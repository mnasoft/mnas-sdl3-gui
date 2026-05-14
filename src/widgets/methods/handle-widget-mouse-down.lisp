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
               (setf (edit-box-cursor widget) (edit-box-position-from-pixel widget x)
                     (edit-box-selection-start widget) nil
                     (edit-box-selection-end widget) nil)
               (edit-box-ensure-cursor-visible widget)
               (when (combo-box-expanded-p widget)
                 (sync-combo-box-expanded-state widget nil)))))
        ((and (combo-box-expanded-p widget)
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
                        (edit-box-text widget) (format nil "~a" (nth new-index (list-box-items widget)))
                        (edit-box-cursor widget) (length (edit-box-text widget)))
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
        ((combo-box-expanded-p widget)
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

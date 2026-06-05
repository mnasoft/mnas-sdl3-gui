;;;; ./src/widgets/methods/handle-mouse-button-event.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-mouse-button-event :around ((widget widget) (ev sdl3:mouse-button-event))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

 ;; Root list handler: perform hit-test order dispatch and delegate to
 ;; per-widget `handle-mouse-button-event` methods.
(defmethod handle-mouse-button-event ((widgets cons) (ev sdl3:mouse-button-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (down (slot-value ev 'sdl3:%down)))
    ;; Close expanded combo-box popups that are not under the pointer (mouse-down behaviour).
    (when down
      (loop for widget in widgets
            when (and (typep widget 'combo-box)
                      (combo-box-expanded-p widget)
                      (not (contains-point-p widget x y)))
              do (progn
                   (sync-combo-box-expanded-state widget nil)
                   (setf (list-box-scrollbar-dragging-p widget) nil
                         (list-box-scrollbar-drag-offset widget) 0))))
    ;; Dispatch to children in hit-test order. For mouse-down return the widget
    ;; that consumed the event (and set focus). For mouse-up return the widget
    ;; that consumed the up event or NIL.
    (if down
        (loop for widget in (widgets-in-hit-test-order widgets)
              when (handle-mouse-button-event widget ev)
                do (set-widget-focus widgets widget)
                   (return widget)
              finally (return nil))
        (loop for widget in (widgets-in-hit-test-order widgets)
              when (handle-mouse-button-event widget ev)
                return widget
              finally (return nil)))))


(defmethod handle-mouse-button-event ((widget widget) (ev sdl3:mouse-button-event))
  "Default no-op for generic widgets unless specialized." 
  (declare (ignore ev))
  nil)


(defmethod handle-mouse-button-event ((widget widget-container) (ev sdl3:mouse-button-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y))))
    (when (contains-point-p widget x y)
      (loop for child in (widgets-in-hit-test-order (children widget))
            when (handle-mouse-button-event child ev)
              do (setf (widget-focused widget) t)
                 (return t)
            finally (return nil)))))


(defmethod handle-mouse-button-event ((widget canvas-2d-widget) (ev sdl3:mouse-button-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y))))
    (when (contains-point-p widget x y)
      (setf (widget-focused widget) t)
      t)))


(defmethod handle-mouse-button-event ((widget button) (ev sdl3:mouse-button-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (inside (contains-point-p widget x y))
         (down (slot-value ev 'sdl3:%down)))
    (when down
      (setf (button-armed-p widget) inside
            (button-pressed-p widget) inside
            (widget-focused widget) inside)
      inside)
    (unless down
      (let ((armed (button-armed-p widget))
            (activate nil))
        (setf (button-pressed-p widget) nil
              (button-armed-p widget) nil)
        (setf activate (and armed inside))
        (when activate
          (when (button-on-click widget)
            (funcall (button-on-click widget) widget)))
        (or armed inside)))))


(defmethod handle-mouse-button-event ((widget toolbar-button) (ev sdl3:mouse-button-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (down (slot-value ev 'sdl3:%down))
         (inside (contains-point-p widget x y)))
    (when down
      (setf (widget-focused widget) inside)
      inside)
    (unless down
      (when inside
        (let ((cmd-id (button-command-id widget)))
          (when cmd-id
            (handler-case
                (mnas-sdl3-gui/commands:execute-command cmd-id :context widget)
              (error (e)
                (format *error-output* "Error executing toolbar command ~S: ~S~%" cmd-id e)))))
        t))))


(defmethod handle-mouse-button-event ((widget toggle) (ev sdl3:mouse-button-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y)))
        (down (slot-value ev 'sdl3:%down)))
    (when (and down (contains-point-p widget x y))
      (setf (widget-focused widget) t)
      (select-toggle-in-group widget)
      t)))


(defmethod handle-mouse-button-event ((widget check-box) (ev sdl3:mouse-button-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y)))
        (down (slot-value ev 'sdl3:%down)))
    (when (and down (contains-point-p widget x y))
      (setf (widget-focused widget) t)
      (setf (check-box-checked widget) (not (check-box-checked widget)))
      (update-widget-value widget (check-box-checked widget))
      t)))


 (defmethod handle-mouse-button-event ((widget entry) (ev sdl3:mouse-button-event))
   (let ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (down (slot-value ev 'sdl3:%down)))
     (setf (widget-focused widget) (contains-point-p widget x y))
     (when (and down (contains-point-p widget x y))
       (setf (entry-cursor widget) (entry-position-from-pixel widget x))
       (clear-entry-selection widget)
       (entry-ensure-cursor-visible widget))
     (contains-point-p widget x y)))


(defmethod handle-mouse-button-event ((widget tree-view) (ev sdl3:mouse-button-event))
  (let ((x (round (slot-value ev 'sdl3:%x)))
        (y (round (slot-value ev 'sdl3:%y)))
        (down (slot-value ev 'sdl3:%down)))
    (setf (widget-focused widget) (contains-point-p widget x y))
    (when (and down (contains-point-p widget x y))
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
      (contains-point-p widget x y))))


(defmethod handle-mouse-button-event ((widget list-box) (ev sdl3:mouse-button-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (down (slot-value ev 'sdl3:%down))
         (inside (contains-point-p widget x y)))
    (when (and down inside)
      (setf (widget-focused widget) t)
      (normalize-list-box-scroll-offset widget))
    (when down
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
           (setf (list-box-scrollbar-dragging-p widget) nil)))))
    (when (not down)
      (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
        (setf (list-box-scrollbar-dragging-p widget) nil
              (list-box-scrollbar-drag-offset widget) 0)
        dragging-p))))


(defmethod handle-mouse-button-event ((widget editable-combo-box) (ev sdl3:mouse-button-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (down (slot-value ev 'sdl3:%down))
         (main-height (combo-box-main-height widget))
         (main-x (widget-x widget))
         (main-y (widget-y widget))
         (main-width (widget-width widget))
         (arrow-width 24)
         (popup-y (+ main-y main-height)))
    (when down
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
              (sync-combo-box-expanded-state widget nil)))))))
    ;; mouse-up: clear dragging state
    (unless down
      (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
        (setf (list-box-scrollbar-dragging-p widget) nil
              (list-box-scrollbar-drag-offset widget) 0)
        dragging-p))))


(defmethod handle-mouse-button-event ((widget combo-box) (ev sdl3:mouse-button-event))
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (down (slot-value ev 'sdl3:%down)))
    (when down
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
                  (setf (list-box-selected-index widget) new-index)
                  (sync-combo-box-expanded-state widget nil)
                  (update-widget-value widget
                                       (nth new-index (list-box-items widget))))))
             (t
              (setf (list-box-scrollbar-dragging-p widget) nil)
              (sync-combo-box-expanded-state widget nil)))))))
    (unless down
      (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
        (setf (list-box-scrollbar-dragging-p widget) nil
              (list-box-scrollbar-drag-offset widget) 0)
        dragging-p))))


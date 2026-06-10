;;;; ./src/widgets/combo-box-functions.lisp

(defun combo-box-selected-item (widget)
  "Return currently selected item of combo-box WIDGET, or NIL when unavailable."
  (let ((items (list-box-items widget))
        (index (list-box-selected-index widget)))
    (when (and items (<= 0 index) (< index (length items)))
      (nth index items))))

(defun combo-box-find-item-index (widget item)
  "Return index of ITEM in combo-box WIDGET items, or NIL if missing."
  (position item (list-box-items widget) :test #'equal))

(defun combo-box-add-item (widget item &key (select t))
  "Add ITEM to combo-box WIDGET items, optionally selecting it.
If ITEM already exists, it becomes selected instead of duplicated." 
  (let ((items (list-box-items widget))
        (index (combo-box-find-item-index widget item)))
    (if index
        (when select
          (setf (list-box-selected-index widget) index))
        (progn
          (setf (list-box-items widget) (append items (list item))
                (list-box-selected-index widget) (1- (length (list-box-items widget))))))
    (when select
      (update-widget-value widget item)))
  widget)

(defun combo-box-total-height (widget)
  "Return total reserved height of combo-box WIDGET including popup when expanded."
  (+ (combo-box-main-height widget)
     (if (and (combo-box-expanded-p widget)
              (not (combo-box-popup-window-enabled-p widget)))
         (combo-box-popup-height widget)
         0)))

(defun combo-box-popup-window-enabled-p (widget)
  "Return true when WIDGET uses a separate popup window for the drop-down."
  (let ((host (combo-box-popup-host-window widget)))
    (and (typep widget 'combo-box)
         (eq (combo-box-popup-mode widget) :window)
         host
         (not (cffi:null-pointer-p host)))))

(defun sync-combo-box-expanded-state (widget expanded-p)
  "Synchronize combo-box expansion state and reserved widget height."
  (let ((main-height (if (combo-box-expanded-p widget)
                         (combo-box-main-height widget)
                         (widget-height widget))))
    (setf (combo-box-main-height widget) (max 1 main-height)
          (combo-box-expanded-p widget) expanded-p
          (widget-height widget)
          (if (and expanded-p
                   (not (combo-box-popup-window-enabled-p widget)))
              (+ (combo-box-main-height widget)
                 (combo-box-popup-height widget))
              (combo-box-main-height widget))))
  (format t "[combo-box] sync expanded=~A enabled=~A host=~S~%"
          expanded-p
          (combo-box-popup-window-enabled-p widget)
          (combo-box-popup-host-window widget))
  (when (combo-box-popup-window-enabled-p widget)
    (if expanded-p
        (progn
          (format t "[combo-box] calling show-popup~%")
          (finish-output)
          (combo-box-show-popup-window widget))
        (progn
          (format t "[combo-box] calling hide-popup~%")
          (finish-output)
          (combo-box-hide-popup-window widget))))
  ;; Call optional demo hook to allow creating transient popup surfaces/windows.
  (when *combo-box-expanded-callback*
    (handler-case
        (funcall *combo-box-expanded-callback* widget expanded-p)
      (error (e)
        (format t "Error in *combo-box-expanded-callback*: ~A~%" e))))
  widget)

(defun combo-box-visible-item-count (widget)
  "Return visible row count for combo-box popup of WIDGET."
  (max 1
       (min (combo-box-max-visible-items widget)
            (max 1 (length (list-box-items widget))))))

(defun combo-box-max-scroll-offset (widget)
  "Return maximum valid popup scroll offset for combo-box WIDGET."
  (max 0
       (- (length (list-box-items widget))
          (combo-box-visible-item-count widget))))

(defun combo-box-scrollbar-needed-p (widget)
  "Return true when combo-box popup requires a scrollbar." 
  (> (length (list-box-items widget))
     (combo-box-visible-item-count widget)))

(defun normalize-combo-box-scroll-offset (widget)
  "Clamp combo-box popup scroll offset for WIDGET." 
  (setf (list-box-scroll-offset widget)
        (max 0
             (min (list-box-scroll-offset widget)
                  (combo-box-max-scroll-offset widget)))))

(defun ensure-combo-box-selection-visible (widget)
  "Adjust popup scroll of WIDGET so selected row stays visible." 
  (let* ((item-count (length (list-box-items widget)))
         (visible-count (combo-box-visible-item-count widget))
         (max-offset (combo-box-max-scroll-offset widget))
         (selected-index (if (plusp item-count)
                             (max 0 (min (list-box-selected-index widget) (1- item-count)))
                             0))
         (scroll-offset (max 0 (min (list-box-scroll-offset widget) max-offset))))
    (cond
      ((< selected-index scroll-offset)
       (setf scroll-offset selected-index))
      ((>= selected-index (+ scroll-offset visible-count))
       (setf scroll-offset (1+ (- selected-index visible-count)))))
    (setf (list-box-selected-index widget) selected-index
          (list-box-scroll-offset widget) (max 0 (min scroll-offset max-offset)))))

(defun combo-box-popup-y (widget)
  "Return popup top Y coordinate for combo-box WIDGET." 
  (+ (widget-y widget) (combo-box-main-height widget)))

(defun combo-box-popup-height (widget)
  "Return popup height for combo-box WIDGET." 
  (+ 2 (* (combo-box-visible-item-count widget)
          (list-box-item-height widget))))

(defun combo-box-content-width (widget)
  "Return popup content width excluding scrollbar when present." 
  (- (widget-width widget)
     (if (combo-box-scrollbar-needed-p widget)
         +list-box-scrollbar-width+
         0)))

(defun combo-box-scrollbar-geometry (widget)
  "Return popup scrollbar geometry for WIDGET.
Values are: needed-p, track-x, track-y, track-height, thumb-y, thumb-height, max-offset." 
  (let ((needed-p (combo-box-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (combo-box-visible-item-count widget))
               (item-count (length (list-box-items widget)))
               (track-x (+ (widget-x widget) (combo-box-content-width widget)))
               (track-y (1+ (combo-box-popup-y widget)))
               (track-height (max 1 (- (combo-box-popup-height widget) 2)))
               (max-offset (combo-box-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count item-count)))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (list-box-scroll-offset widget) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun combo-box-popup-scrollbar-geometry (widget popup-x popup-y)
  "Return popup scrollbar geometry for WIDGET with popup at POPUP-X/POPUP-Y."
  (let ((needed-p (combo-box-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (combo-box-visible-item-count widget))
               (item-count (length (list-box-items widget)))
               (track-x (+ popup-x (combo-box-content-width widget)))
               (track-y (1+ popup-y))
               (track-height (max 1 (- (combo-box-popup-height widget) 2)))
               (max-offset (combo-box-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count item-count)))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (list-box-scroll-offset widget) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun combo-box-set-scroll-offset-from-thumb-top (widget thumb-top)
  "Update popup scroll offset of combo-box WIDGET from scrollbar thumb top." 
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (combo-box-scrollbar-geometry widget)
    (declare (ignore track-x thumb-y))
    (when needed-p
      (let* ((thumb-travel (max 1 (- track-height thumb-height)))
             (clamped-thumb-top (max track-y
                                     (min thumb-top
                                          (+ track-y thumb-travel))))
             (relative-top (- clamped-thumb-top track-y)))
        (setf (list-box-scroll-offset widget)
              (if (zerop max-offset)
                  0
                  (round (* max-offset (/ relative-top thumb-travel))))))
      (normalize-combo-box-scroll-offset widget))))

(defun combo-box-popup-set-scroll-offset-from-thumb-top (widget popup-x popup-y thumb-top)
  "Update popup scroll offset using POPUP-X/POPUP-Y geometry and THUMB-TOP."
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (combo-box-popup-scrollbar-geometry widget popup-x popup-y)
    (declare (ignore track-x thumb-y))
    (when needed-p
      (let* ((thumb-travel (max 1 (- track-height thumb-height)))
             (clamped-thumb-top (max track-y
                                     (min thumb-top
                                          (+ track-y thumb-travel))))
             (relative-top (- clamped-thumb-top track-y)))
        (setf (list-box-scroll-offset widget)
              (if (zerop max-offset)
                  0
                  (round (* max-offset (/ relative-top thumb-travel))))))
      (normalize-combo-box-scroll-offset widget))))

(defun combo-box-ensure-popup-window (widget)
  "Ensure popup window/renderer exist for WIDGET. Returns popup window or NIL."
  (cond
    ((combo-box-popup-window widget)
     (combo-box-popup-window widget))
    ((and (combo-box-popup-window-enabled-p widget)
          (combo-box-popup-host-window widget))
     (format t "[combo-box] ensure-popup host=~S size=~Dx~D~%"
             (combo-box-popup-host-window widget)
             (widget-width widget)
             (combo-box-popup-height widget))
     (finish-output)
     (let* ((popup-window (sdl3:create-popup-window
                           (combo-box-popup-host-window widget)
                           0
                           0
                           (widget-width widget)
                           (combo-box-popup-height widget)
                           :popup-menu)))
       (when (or (null popup-window) (cffi:null-pointer-p popup-window))
         (format t "Failed to create combo-box popup window: ~A~%" (sdl3:get-error))
         (return-from combo-box-ensure-popup-window nil))
       (let ((popup-renderer (sdl3:create-renderer popup-window "")))
         (when (or (null popup-renderer) (cffi:null-pointer-p popup-renderer))
           (format t "Failed to create combo-box popup renderer: ~A~%" (sdl3:get-error))
           (return-from combo-box-ensure-popup-window nil))
         (setf (combo-box-popup-window widget) popup-window
               (combo-box-popup-renderer widget) popup-renderer
               (combo-box-popup-window-id widget) (sdl3:get-window-id popup-window))
           ;; Register mapping from the SDL popup window id to this widget so
           ;; event dispatchers can quickly find the widgets associated with
           ;; transient popup windows.
           (when (and (combo-box-popup-window-id widget)
              (numberp (combo-box-popup-window-id widget))
              (> (combo-box-popup-window-id widget) 0))
             (register-widget-for-window-id (combo-box-popup-window-id widget) widget))
         (format t "[combo-box] popup created id=~S renderer=~S~%"
                 (combo-box-popup-window-id widget)
                 popup-renderer)
         (finish-output)
         (when (combo-box-popup-layer-manager widget)
           (mnas-sdl3-gui/window-manager:register-window
            (combo-box-popup-layer-manager widget)
            (combo-box-popup-window-id widget)
            :dropdown-host
            :parent-id (sdl3:get-window-id (combo-box-popup-host-window widget))
            :open-p nil))
         popup-window)))
    (t nil)))

(defun combo-box-show-popup-window (widget)
  "Show popup window for WIDGET if popup mode is enabled."
  (format t "[combo-box] show-popup enter host=~S popup=~S~%"
    (combo-box-popup-host-window widget)
    (combo-box-popup-window widget))
  (finish-output)
  (when (combo-box-ensure-popup-window widget)
    (multiple-value-bind (ok wx wy)
        (sdl3:get-window-position (combo-box-popup-host-window widget))
      (let ((global-x (if ok (+ wx (widget-x widget)) (widget-x widget)))
            (global-y (if ok (+ wy (widget-y widget) (combo-box-main-height widget))
                          (+ (widget-y widget) (combo-box-main-height widget)))))
        (format t "[combo-box] show-popup ok=~A host=~S popup-id=~S pos=(~D,~D) expanded=~A~%"
                ok
                (combo-box-popup-host-window widget)
                (combo-box-popup-window-id widget)
                global-x global-y
                (combo-box-expanded-p widget))
  (finish-output)
        (sdl3:set-window-position (combo-box-popup-window widget) global-x global-y)
        (sdl3:show-window (combo-box-popup-window widget))
        (sdl3:raise-window (combo-box-popup-window widget))
        (when (combo-box-popup-layer-manager widget)
          (mnas-sdl3-gui/window-manager:open-dropdown-host
           (combo-box-popup-layer-manager widget)
           (combo-box-popup-window-id widget)
           (sdl3:get-window-id (combo-box-popup-host-window widget))))
        (setf (combo-box-popup-visible-p widget) t))))
  (combo-box-popup-visible-p widget))

(defun combo-box-hide-popup-window (widget)
  "Hide popup window for WIDGET if present."
  (setf (combo-box-popup-visible-p widget) nil)
  (when (combo-box-popup-window widget)
    (ignore-errors (sdl3:hide-window (combo-box-popup-window widget))))
  (when (combo-box-popup-layer-manager widget)
    (mnas-sdl3-gui/window-manager:close-window
     (combo-box-popup-layer-manager widget)
     (combo-box-popup-window-id widget)
     :close-children t))
  nil)

(defun combo-box-enable-popup-window (widget host-window &key layer-manager)
  "Enable popup window mode for WIDGET using HOST-WINDOW." 
  (setf (combo-box-popup-mode widget) :window
        (combo-box-popup-host-window widget) host-window
        (combo-box-popup-layer-manager widget) layer-manager)
  (combo-box-ensure-popup-window widget)
  widget)

(defun combo-box-disable-popup-window (widget)
  "Disable popup window mode and destroy popup resources for WIDGET." 
  (combo-box-hide-popup-window widget)
  ;; Capture popup window id before destroying resources so we can remove
  ;; the mapping from window id -> widget.
  (let ((old-id (combo-box-popup-window-id widget)))
    (when (combo-box-popup-renderer widget)
      (sdl3:destroy-renderer (combo-box-popup-renderer widget)))
    (when (combo-box-popup-window widget)
      (destroy-window-and-unregister (combo-box-popup-window widget)
                                     :layer-manager (combo-box-popup-layer-manager widget)))
    )
  (setf (combo-box-popup-window widget) nil
        (combo-box-popup-renderer widget) nil
        (combo-box-popup-window-id widget) 0
        (combo-box-popup-host-window widget) nil
        (combo-box-popup-layer-manager widget) nil
        (combo-box-popup-visible-p widget) nil
        (combo-box-popup-mode widget) :inline)
  widget)

(defun combo-box-handle-popup-mouse-down (widget x y)
  "Handle mouse-down inside popup window for WIDGET with local X/Y coords." 
  (normalize-combo-box-scroll-offset widget)
  (let* ((item-height (list-box-item-height widget))
         (visible-count (combo-box-visible-item-count widget))
         (scrollbar-needed-p (combo-box-scrollbar-needed-p widget))
         (content-width (combo-box-content-width widget))
         (rel-x x)
         (rel-y y))
    (cond
      ((and scrollbar-needed-p (>= rel-x content-width))
       (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
           (combo-box-popup-scrollbar-geometry widget 0 0)
         (declare (ignore needed-p track-x track-height max-offset))
         (let ((thumb-hit-p (<= thumb-y y (+ thumb-y thumb-height))))
           (setf (list-box-scrollbar-dragging-p widget) t
                 (list-box-scrollbar-drag-offset widget)
                 (if thumb-hit-p
                     (- y thumb-y)
                     (floor thumb-height 2)))
           (combo-box-popup-set-scroll-offset-from-thumb-top widget 0 0
                                                             (- y (list-box-scrollbar-drag-offset widget))))))
      ((>= rel-y 0)
       (setf (list-box-scrollbar-dragging-p widget) nil)
       (let* ((row (floor rel-y item-height))
              (new-index (+ (list-box-scroll-offset widget) row)))
         (when (and (< row visible-count)
                    (< new-index (length (list-box-items widget))))
           (setf (list-box-selected-index widget) new-index)
           (when (typep widget 'editable-combo-box)
             (setf (entry-text widget) (format nil "~a" (nth new-index (list-box-items widget)))
                   (entry-cursor widget) (length (entry-text widget)))
             (entry-scroll-to-start widget))
           (sync-combo-box-expanded-state widget nil)
           (update-widget-value widget
                                (nth new-index (list-box-items widget))))))
      (t
       (setf (list-box-scrollbar-dragging-p widget) nil)
       (sync-combo-box-expanded-state widget nil)))
    t))

(defun combo-box-handle-popup-mouse-up (widget x y)
  "Handle mouse-up inside popup window for WIDGET." 
  (declare (ignore x y))
  (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
    (setf (list-box-scrollbar-dragging-p widget) nil
          (list-box-scrollbar-drag-offset widget) 0)
    dragging-p))

(defun combo-box-handle-popup-mouse-motion (widget x y)
  "Handle mouse-motion inside popup window for WIDGET." 
  (when (list-box-scrollbar-dragging-p widget)
    (combo-box-popup-set-scroll-offset-from-thumb-top widget 0 0
                                                      (- y (list-box-scrollbar-drag-offset widget)))
    t))

(defun combo-box-handle-popup-mouse-wheel (widget dy)
  "Handle mouse-wheel inside popup window for WIDGET." 
  (when (not (zerop dy))
    (let ((ev (sdl3:mouse-wheel-event :%yrel dy :%mouse-y dy :%x 0 :%y 0)))
      (handle-mouse-wheel-event widget ev))))

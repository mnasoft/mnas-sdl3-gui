;;;; ./src/widgets/methods/initialize-instance.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod register-toggle-group-member ((widget <toggle>))
  (let ((group (<toggle>-group widget)))
    (when group
      (pushnew widget (gethash group *toggle-groups*) :test #'eq))))

(defmethod initialize-instance :after ((widget <toggle>) &key &allow-other-keys)
  (register-toggle-group-member widget))

(defmethod initialize-instance :after ((widget <widget>) &key &allow-other-keys)
  "Auto-register WIDGET in global window->widgets registry when :window slot is provided."
  (let ((win (<widget>-window widget)))
    (when win
      (let ((wid (window-id-from win)))
        (when (and wid (numberp wid) (> wid 0))
          (ignore-errors (register-widget-for-window-id wid widget)))))))

(defun sync-combo-box-geometry-with-owner (widget)
  "Copy the owner combo-box geometry onto its header and popup widgets."
  (let ((header (header-widget widget))
        (popup (popup-widget widget)))
    (when header
      (setf (<widget>-x header) (<widget>-x widget)
            (<widget>-y header) (<widget>-y widget)
            (<widget>-width header) (<widget>-width widget)
            (<widget>-height header) (<widget>-height widget)))
    (when popup
      (setf (<widget>-x popup) (<widget>-x widget)
            (<widget>-y popup) (<widget>-y widget)
            (<widget>-width popup) (<widget>-width widget)
            (<widget>-height popup) (<widget>-height widget)))
    widget))

(defmethod initialize-instance :after ((widget <combo-box-popup>)
                                       &key (visible nil visible-supplied)
                                       &allow-other-keys)
  (setf (<widget>-visible widget) (if visible-supplied visible nil)))

(defmethod initialize-instance :after ((widget <combo-box>)
                                       &key
                                         popup-host-window
                                         popup-layer-manager
                                         selected-index
                                         items
                                         padding
                                       &allow-other-keys)
  ;; Ensure header and popup instances exist and are linked.
  (when (and (null padding)
             (zerop (or (<widget>-padding widget) 0)))
    (setf (<widget>-padding widget)
          (max 1 (floor +font-text-height+ 8))))
  (unless (header-widget widget)
    (let* ((hdr (make-instance '<combo-box-header> :owner widget))
           (pop (make-instance '<combo-box-popup> :owner widget)))
      (setf (header-widget widget) hdr
            (popup-widget widget) pop
            (<widget>-owner pop) widget
            (<widget>-owner hdr) widget
            )))
  ;; Forward the initial items passed via :items initarg to the popup.
  ;; The popup keeps its own children as the single source of truth.
  (let ((popup (popup-widget widget)))
    (when (and popup items)
      (setf (children popup) items
            (selected-index popup) (or selected-index 0))))
  (sync-combo-box-geometry-with-owner widget)
  (setf (main-height widget) (<widget>-height widget))
  (ensure-combo-box-selection-visible widget)
  (sync-combo-box-expanded-state widget (expanded-p widget))
  (setf (<widget>-value widget) (selected-item widget))
  (when popup-host-window
    (enable-popup-window widget popup-host-window :layer-manager popup-layer-manager)))

(defmethod initialize-instance :after ((widget <check-box>) &rest initargs)
  (let ((width-supplied (member :width initargs))
        (height-supplied (member :height initargs))
        (padding-supplied (member :padding initargs)))
    (when (and (not padding-supplied)
               (zerop (or (<widget>-padding widget) 0)))
      (setf (<widget>-padding widget)
            (max 1 (floor +font-text-height+ 8))))
    (multiple-value-bind (min-width min-height)
        (widget-min-size widget)
      (unless width-supplied
        (setf (<widget>-width widget) min-width))
      (unless height-supplied
        (setf (<widget>-height widget) min-height)))))

(defmethod initialize-instance :after ((widget <integer-entry>) &key &allow-other-keys)
  (unless (<entry>-validate widget)
    (setf (<entry>-validate widget) #'<integer-entry>-text-p)))

(defmethod initialize-instance :after ((widget <real-entry>) &key &allow-other-keys)
  (unless (<entry>-validate widget)
    (setf (<entry>-validate widget) #'<real-entry>-text-p)))

;; When widget's `:window` slot is changed after creation we should update the
;; global registry accordingly. Provide a setf method for `<widget>-window`
;; that unregisters from the old window id and registers for the new one.
(defmethod (setf <widget>-window) (new-win (widget <widget>))
  (let ((old (<widget>-window widget)))
    ;; Unregister from old window id if present
    (when old
      (let ((old-id (window-id-from old)))
        (when (and old-id (numberp old-id) (> old-id 0))
          (ignore-errors (unregister-widget-for-window-id old-id widget))))))
  ;; Actually set the slot without invoking this setf method recursively
  (setf (slot-value widget 'window) new-win)
  ;; Register for new window id if provided
  (when new-win
    (let ((new-id (window-id-from new-win)))
      (when (and new-id (numberp new-id) (> new-id 0))
        (ignore-errors (register-widget-for-window-id new-id widget)))))
  new-win)

;; Finalize-instance hooks to cleanup registry and widget-specific resources
;; when instances are finalized (MOP finalization). Keep calls robust with
;; ignore-errors to avoid throwing during GC/finalization.
(defmethod finalize-instance :before ((widget <combo-box>))
  (let ((popup (popup-widget widget)))
    (when (or (and popup (popup-visible-p popup))
              (and popup (<widget>-window popup)))
      (ignore-errors (disable-popup-window widget)))))

(defmethod finalize-instance :after ((widget <widget>))
  (let ((win (<widget>-window widget)))
    (when win
      (let ((wid (window-id-from win)))
        (when (and wid (numberp wid) (> wid 0))
          (ignore-errors (unregister-widget-for-window-id wid widget)))))))

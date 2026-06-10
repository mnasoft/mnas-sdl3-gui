;;;; ./src/widgets/methods/initialize-instance.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod initialize-instance :after ((widget toggle) &key &allow-other-keys)
  (register-toggle-group-member widget))

(defmethod initialize-instance :after ((widget widget) &key &allow-other-keys)
  "Auto-register WIDGET in global window->widgets registry when :window slot is provided."
  (let ((win (widget-window widget)))
    (when win
      (let ((wid (window-id-from win)))
        (when (and wid (numberp wid) (> wid 0))
          (ignore-errors (register-widget-for-window-id wid widget)))))))

(defmethod initialize-instance :after ((widget combo-box) &key popup-host-window popup-layer-manager &allow-other-keys)
  ;; Ensure header and popup instances exist and are linked.
  (unless (combo-box-header-widget widget)
    (let* ((hdr (make-instance 'combo-box-header :owner widget))
           (pop (make-instance 'combo-box-popup :owner widget)))
      (setf (combo-box-header-widget widget) hdr
            (combo-box-popup-widget widget) pop
            (combo-box-popup-owner pop) widget
            (combo-box-header-owner hdr) widget
            )))
  ;; Forward any initial items passed via :items initarg to popup
  (let ((init-items (combo-box-initial-items widget)))
    (when init-items
      (setf (list-box-items (combo-box-popup-widget widget)) init-items)
      (setf (list-box-selected-index (combo-box-popup-widget widget))
            (combo-box-initial-selected-index widget))))
  (setf (combo-box-main-height widget) (widget-height widget))
  (ensure-combo-box-selection-visible widget)
  (sync-combo-box-expanded-state widget (combo-box-expanded-p widget))
  (setf (widget-value widget) (combo-box-selected-item widget))
  (when popup-host-window
    (combo-box-enable-popup-window widget popup-host-window :layer-manager popup-layer-manager)))

(defmethod initialize-instance :after ((widget integer-entry) &key &allow-other-keys)
  (unless (entry-validate widget)
    (setf (entry-validate widget) #'integer-entry-text-p)))

(defmethod initialize-instance :after ((widget real-entry) &key &allow-other-keys)
  (unless (entry-validate widget)
    (setf (entry-validate widget) #'real-entry-text-p)))

;; When widget's `:window` slot is changed after creation we should update the
;; global registry accordingly. Provide a setf method for `widget-window`
;; that unregisters from the old window id and registers for the new one.
(defmethod (setf widget-window) (new-win (widget widget))
  (let ((old (widget-window widget)))
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
(defmethod finalize-instance :before ((widget combo-box))
  (let ((popup (combo-box-popup-widget widget)))
    (when (or (and popup (combo-box-popup-visible-p popup))
              (and popup (combo-box-popup-window popup)))
      (ignore-errors (combo-box-disable-popup-window widget)))))

(defmethod finalize-instance :after ((widget widget))
  (let ((win (widget-window widget)))
    (when win
      (let ((wid (window-id-from win)))
        (when (and wid (numberp wid) (> wid 0))
          (ignore-errors (unregister-widget-for-window-id wid widget)))))))

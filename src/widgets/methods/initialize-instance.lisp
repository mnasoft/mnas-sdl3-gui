;;;; ./src/widgets/methods/initialize-instance.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod initialize-instance :after ((widget toggle) &key &allow-other-keys)
  (register-toggle-group-member widget))

(defmethod initialize-instance :after ((widget combo-box) &key &allow-other-keys)
  (setf (combo-box-main-height widget) (widget-height widget))
  (ensure-combo-box-selection-visible widget)
  (sync-combo-box-expanded-state widget (combo-box-expanded-p widget))
  (setf (widget-value widget) (combo-box-selected-item widget)))

(defmethod initialize-instance :after ((widget integer-entry) &key &allow-other-keys)
  (unless (entry-validate widget)
    (setf (entry-validate widget) #'integer-entry-text-p)))

(defmethod initialize-instance :after ((widget real-entry) &key &allow-other-keys)
  (unless (entry-validate widget)
    (setf (entry-validate widget) #'real-entry-text-p)))
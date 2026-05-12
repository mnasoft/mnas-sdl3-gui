;;;; ./src/widgets/methods/activate-widget.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod activate-widget :around ((widget widget))
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod activate-widget ((widget widget))
  nil)

(defmethod activate-widget ((widget button))
  (setf (button-armed-p widget) t
        (button-pressed-p widget) t)
  (unwind-protect
       (progn
         (when (button-on-click widget)
           (funcall (button-on-click widget) widget))
         t)
    (setf (button-armed-p widget) nil
          (button-pressed-p widget) nil)))

(defmethod activate-widget ((widget toggle))
  (select-toggle-in-group widget)
  t)

(defmethod activate-widget ((widget check-box))
  (setf (check-box-checked widget) (not (check-box-checked widget)))
  (update-widget-value widget (check-box-checked widget))
  t)

(defmethod activate-widget ((widget combo-box))
  (sync-combo-box-expanded-state widget (not (combo-box-expanded-p widget)))
  (when (combo-box-expanded-p widget)
    (ensure-combo-box-selection-visible widget))
  t)
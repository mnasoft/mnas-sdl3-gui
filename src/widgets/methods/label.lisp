;;;; ./src/widgets/methods/label.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod label ((widget <widget>))
  (cond
    ((slot-exists-p widget 'label)
     (slot-value widget 'label))
    ((slot-exists-p widget 'text)
     (slot-value widget 'text))
    (t nil)))

(defmethod (setf label) (new-value (widget <widget>))
  (cond
    ((slot-exists-p widget 'label)
     (setf (slot-value widget 'label) new-value))
    ((slot-exists-p widget 'text)
     (setf (slot-value widget 'text) new-value))
    (t (error "No label/text slot available for ~S" (class-name (class-of widget))))))

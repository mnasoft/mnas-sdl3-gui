;;;; ./src/widgets/methods/item-height.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod item-height ((w <list-box>))
  (slot-value w 'item-height))

(defmethod (setf item-height) (new-value (w <list-box>))
  (setf (slot-value w 'item-height) new-value)
  new-value)

(defmethod item-height ((w <combo-box>))
  (let ((p (popup-widget w)))
    (if p (item-height p) 24)))

(defmethod (setf item-height) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (item-height p) new-value)))
  new-value)

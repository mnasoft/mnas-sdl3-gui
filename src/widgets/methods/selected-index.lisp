;;;; ./src/widgets/methods/selected-index.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod selected-index ((w <list-box>))
  (slot-value w 'selected-index))

(defmethod (setf selected-index) (new-value (w <list-box>))
  (setf (slot-value w 'selected-index) new-value)
  new-value)

#+nil
(defmethod selected-index ((w <combo-box>))
  (let ((p (popup-widget w)))
    (if p (selected-index p) 0)))

(defmethod selected-index ((w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (selected-index p))))

(defmethod (setf selected-index) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (selected-index p) new-value))
    new-value))

;;;; ./src/widgets/methods/scrollbar-dragging-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod scrollbar-dragging-p ((w <list-box>))
  (slot-value w 'scrollbar-dragging-p))

(defmethod (setf scrollbar-dragging-p) (new-value (w <list-box>))
  (setf (slot-value w 'scrollbar-dragging-p) new-value)
  new-value)

(defmethod scrollbar-dragging-p ((w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (scrollbar-dragging-p p))))

(defmethod (setf scrollbar-dragging-p) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (scrollbar-dragging-p p) new-value))
    new-value))

;;;; ./src/widgets/methods/scrollbar-drag-offset.lisp

(in-package :mnas-sdl3-gui/widgets)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; <list-box>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmethod scrollbar-drag-offset ((w <list-box>))
  (slot-value w 'scrollbar-drag-offset))

(defmethod (setf scrollbar-drag-offset) (new-value (w <list-box>))
  (setf (slot-value w 'scrollbar-drag-offset) new-value)
  new-value)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; <combo-box>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmethod scrollbar-drag-offset ((w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (scrollbar-drag-offset p))))

#+nil
(defmethod (setf scrollbar-drag-offset) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (scrollbar-drag-offset p) new-value)))
  new-value)

#+nil
(defmethod (setf scrollbar-drag-offset) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (scrollbar-drag-offset p) new-value)))
  new-value)

(defmethod (setf scrollbar-drag-offset) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (scrollbar-drag-offset p) new-value))
    new-value))

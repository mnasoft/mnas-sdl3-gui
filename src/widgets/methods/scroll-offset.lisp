;;;; ./src/widgets/methods/scroll-offset.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod scroll-offset ((w <combo-box>))
  (let ((p (popup-widget w)))
    (if p (scroll-offset p) 0)))

(defmethod (setf scroll-offset) (new-value (w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (setf (scroll-offset p) new-value)))
  new-value)

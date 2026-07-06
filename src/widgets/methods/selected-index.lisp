;;;; ./src/widgets/methods/selected-index.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod selected-index ((w <list-box>))
  (slot-value w 'selected-index))

(defmethod selected-index ((w <combo-box>))
  (let ((p (popup-widget w)))
    (when p (selected-index p))))

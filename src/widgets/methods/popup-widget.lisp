;;;; ./src/widgets/methods/popup-widget.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod popup-widget ((obj <combo-box>))
  (<combo-box>-popup-widget obj))

(defmethod (setf popup-widget) (value (obj <combo-box>))
  (setf (<combo-box>-popup-widget obj) value))

(defmethod popup-widget ((obj <combo-box-popup>))
  obj)

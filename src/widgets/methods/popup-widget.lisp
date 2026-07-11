;;;; ./src/widgets/methods/popup-widget.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod popup-widget ((obj <combo-box>))
  (<combo-box>-popup-widget obj))

(defmethod (setf popup-widget) (value (obj <combo-box>))
  (setf (<combo-box>-popup-widget obj) value))

(defmethod popup-widget ((obj <combo-box-header>))
  (let ((owner (<widget>-owner obj)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'popup))
        (popup-widget owner)
        nil)))

(defmethod (setf popup-widget) (value (obj <combo-box-header>))
  (let ((owner (<widget>-owner obj)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'popup))
        (setf (popup-widget owner) value)
        (setf (slot-value obj 'popup) value)))
  value)

(defmethod popup-widget ((obj <combo-box-popup>))
  obj)

;;;; ./src/widgets/methods/ignore-next-popup-mouse-down-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod ignore-next-popup-mouse-down-p ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (ignore-next-popup-mouse-down-p owner)
        nil)))

(defmethod (setf ignore-next-popup-mouse-down-p) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (setf (ignore-next-popup-mouse-down-p owner) new-value)
        (setf (slot-value widget 'ignore-next-popup-mouse-down-p) new-value)))
  new-value)

(defmethod ignore-next-popup-mouse-down-p ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (ignore-next-popup-mouse-down-p owner)
        nil)))

(defmethod (setf ignore-next-popup-mouse-down-p) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (setf (ignore-next-popup-mouse-down-p owner) new-value)
        (setf (slot-value widget 'ignore-next-popup-mouse-down-p) new-value)))
  new-value)

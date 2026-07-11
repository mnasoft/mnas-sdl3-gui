;;;; ./src/widgets/methods/main-height.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod main-height ((widget <combo-box-header>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'main-height))
        (main-height owner)
        30)))

(defmethod (setf main-height) (new-value (widget <combo-box-header>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'main-height))
        (setf (main-height owner) new-value)
        (setf (slot-value widget 'main-height) new-value)))
  new-value)

(defmethod main-height ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'main-height))
        (main-height owner)
        30)))

(defmethod (setf main-height) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'main-height))
        (setf (main-height owner) new-value)
        (setf (slot-value widget 'main-height) new-value)))
  new-value)

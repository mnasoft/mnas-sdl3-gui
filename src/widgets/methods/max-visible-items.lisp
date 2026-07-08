;;;; ./src/widgets/methods/max-visible-items.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod max-visible-items ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'max-visible-items))
        (max-visible-items owner)
        6)))

(defmethod (setf max-visible-items) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'max-visible-items))
        (setf (max-visible-items owner) new-value)
        (setf (slot-value widget 'max-visible-items) new-value)))
  new-value)

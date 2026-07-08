;;;; ./src/widgets/methods/expanded-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod expanded-p ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'expanded-p))
        (expanded-p owner)
        nil)))

(defmethod (setf expanded-p) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'expanded-p))
        (setf (expanded-p owner) new-value)
        (setf (slot-value widget 'expanded-p) new-value)))
  new-value)

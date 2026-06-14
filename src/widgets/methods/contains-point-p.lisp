;;;; ./src/widgets/methods/contains-point-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod contains-point-p ((widget <widget>) x y)
  (and (<= (<widget>-x widget) x (+ (<widget>-x widget) (<widget>-width widget)))
       (<= (<widget>-y widget) y (+ (<widget>-y widget) (<widget>-height widget)))))

(defmethod contains-point-p ((widget combo-box) x y)
  (or (and (<= (<widget>-x widget) x (+ (<widget>-x widget) (<widget>-width widget)))
           (<= (<widget>-y widget) y (+ (<widget>-y widget) (<combo-box>-main-height widget))))
      (and (<combo-box>-expanded-p widget)
           (not (combo-box-popup-window-enabled-p widget))
           (<= (<widget>-x widget) x (+ (<widget>-x widget) (<widget>-width widget)))
           (<= (combo-box-popup-y widget) y
               (+ (combo-box-popup-y widget) (combo-box-popup-height widget))))))

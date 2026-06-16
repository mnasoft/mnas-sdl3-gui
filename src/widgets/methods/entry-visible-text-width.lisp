;;;; ./src/widgets/methods/<entry>-visible-text-width.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-visible-text-width ((widget <entry>))
  (max 1 (- (<widget>-width widget) (* 2 +widget-padding+))))

(defmethod <entry>-visible-text-width ((widget editable-combo-box))
  (let ((arrow-width 24))
    (max 1 (- (<widget>-width widget) (* 2 +widget-padding+) arrow-width))))
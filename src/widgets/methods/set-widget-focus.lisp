;;;; ./src/widgets/methods/set-widget-focus.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod set-widget-focus ((widgets cons) (target <widget>))
  "Assign keyboard focus to TARGET and clear it from the other WIDGETS."
  (loop for widget in widgets
        do (setf (<widget>-focused widget) (eq widget target)))
  target)

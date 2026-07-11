;;;; ./src/widgets/methods/set-widget-focus.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod set-widget-focus ((widgets cons) (target <widget>))
  "Assign keyboard focus to TARGET and clear it from the other WIDGETS."
  (loop for widget in widgets
        do (setf (<widget>-focused widget) (eq widget target)))
  (loop for widget in widgets
        when (and (not (null widget))
                  (find-class 'mnas-sdl3-gui/widgets:<combo-box> nil)
                  (typep widget 'mnas-sdl3-gui/widgets:<combo-box>))
          do (let ((header (header-widget widget)))
               (when header
                 (setf (<widget>-focused header) (eq widget target)))))
  target)

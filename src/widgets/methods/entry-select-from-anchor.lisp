;;;; ./src/widgets/methods/<entry>-select-from-anchor.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-select-from-anchor ((widget <entry>) anchor)
  (let ((cursor (<entry>-cursor widget)))
    (if (= anchor cursor)
        (clear-<entry>-selection widget)
        (set-<entry>-selection widget (min anchor cursor) (max anchor cursor)))))
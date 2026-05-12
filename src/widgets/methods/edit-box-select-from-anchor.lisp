;;;; ./src/widgets/methods/edit-box-select-from-anchor.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-select-from-anchor ((widget edit-box) anchor)
  (let ((cursor (edit-box-cursor widget)))
    (if (= anchor cursor)
        (clear-edit-box-selection widget)
        (set-edit-box-selection widget (min anchor cursor) (max anchor cursor)))))
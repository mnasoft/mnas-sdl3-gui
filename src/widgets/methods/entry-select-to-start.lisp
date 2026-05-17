;;;; ./src/widgets/methods/entry-select-to-start.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-select-to-start ((widget entry))
  (let ((anchor (entry-selection-anchor widget)))
    (setf (entry-cursor widget) 0)
    (entry-scroll-to-start widget)
    (entry-select-from-anchor widget anchor))
  t)
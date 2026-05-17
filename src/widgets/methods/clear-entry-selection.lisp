;;;; ./src/widgets/methods/clear-entry-selection.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod clear-entry-selection ((widget entry))
  (setf (entry-selection-start widget) nil
        (entry-selection-end widget) nil))
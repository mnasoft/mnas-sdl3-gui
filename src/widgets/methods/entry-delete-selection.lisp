;;;; ./src/widgets/methods/entry-delete-selection.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-delete-selection ((widget entry))
  (let ((start (entry-selection-start widget))
        (end (entry-selection-end widget)))
    (when (and start end (< start end))
      (let ((text (entry-text widget)))
        (setf (entry-text widget)
              (concatenate 'string
                           (subseq text 0 start)
                           (subseq text end)))
        (setf (entry-cursor widget) start)
        (clear-entry-selection widget)
        (entry-ensure-cursor-visible widget)
        (update-widget-value widget (entry-text widget))
        t))))
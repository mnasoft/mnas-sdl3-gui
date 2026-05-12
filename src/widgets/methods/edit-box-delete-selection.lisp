;;;; ./src/widgets/methods/edit-box-delete-selection.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-delete-selection ((widget edit-box))
  (let ((start (edit-box-selection-start widget))
        (end (edit-box-selection-end widget)))
    (when (and start end (< start end))
      (let ((text (edit-box-text widget)))
        (setf (edit-box-text widget)
              (concatenate 'string
                           (subseq text 0 start)
                           (subseq text end)))
        (setf (edit-box-cursor widget) start)
        (clear-edit-box-selection widget)
        (edit-box-ensure-cursor-visible widget)
        (update-widget-value widget (edit-box-text widget))
        t))))
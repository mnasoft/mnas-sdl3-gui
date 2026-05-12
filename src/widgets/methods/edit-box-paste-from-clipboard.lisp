;;;; ./src/widgets/methods/edit-box-paste-from-clipboard.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-paste-from-clipboard ((widget edit-box))
  (when (sdl3:has-clipboard-text)
    (handler-case
        (let* ((clipboard-text (sdl3:get-clipboard-text))
               (current-text (edit-box-text widget))
               (cursor (edit-box-cursor widget))
               (max-len (edit-box-max-length widget))
               (combined (concatenate 'string
                                      (subseq current-text 0 cursor)
                                      clipboard-text
                                      (subseq current-text cursor)))
               (truncated (if (> (length combined) max-len)
                              (subseq combined 0 max-len)
                              combined)))
          (setf (edit-box-text widget) truncated)
          (incf (edit-box-cursor widget) (length clipboard-text))
          (clear-edit-box-selection widget)
          (edit-box-ensure-cursor-visible widget)
          (update-widget-value widget truncated))
      (error (e)
        (format *error-output* "Clipboard error: ~a~%" e)))))
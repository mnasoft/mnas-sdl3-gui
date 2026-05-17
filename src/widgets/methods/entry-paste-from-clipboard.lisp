;;;; ./src/widgets/methods/entry-paste-from-clipboard.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-paste-from-clipboard ((widget entry))
  (when (sdl3:has-clipboard-text)
    (handler-case
        (let* ((clipboard-text (sdl3:get-clipboard-text))
               (current-text (entry-text widget))
               (cursor (entry-cursor widget))
               (max-len (entry-max-length widget))
               (combined (concatenate 'string
                                      (subseq current-text 0 cursor)
                                      clipboard-text
                                      (subseq current-text cursor)))
               (truncated (if (> (length combined) max-len)
                              (subseq combined 0 max-len)
                              combined)))
          (when (entry-valid-text-p widget truncated)
            (setf (entry-text widget) truncated)
            (setf (entry-cursor widget)
                  (min (length truncated)
                       (+ cursor (length clipboard-text))))
            (clear-entry-selection widget)
            (entry-ensure-cursor-visible widget)
            (update-widget-value widget truncated)))
      (error (e)
        (format *error-output* "Clipboard error: ~a~%" e)))))
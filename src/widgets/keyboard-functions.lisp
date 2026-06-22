;;;; ./src/widgets/keyboard-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Keyboard dispatch helpers

(defun dispatch-focused-widget-key-event (widgets key char &key ctrl shift alt)
  "Send KEY/CHAR event to the currently focused widget from WIDGETS."
  (let ((widget (focused-widget widgets)))
    (when widget
      (handle-keyboard-event widget
                             (make-widget-keyboard-input key char
                                                         :ctrl ctrl
                                                         :shift shift
                                                         :alt alt)))))

(defun dispatch-focused-text-input (widgets text)
  "Insert TEXT into the currently focused <entry> from WIDGETS."
  (let ((widget (focused-<entry> widgets)))
    (when widget
      (loop for char across text
            do (handle-keyboard-event widget
                                      (make-widget-keyboard-input nil char))))))

;; `dispatch-widget-keyboard-event` removed: use `handle-keyboard-event` directly.
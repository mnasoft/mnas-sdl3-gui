;;;; ./demos/dialog/combo-box/combo-box-04.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-04)

;;; Minimal non-editable combo-box popup demo

(defun create-combo-box-04-widgets (&optional window)
  (let ((combo
          (make-instance
           'mnas-sdl3-gui/widgets:combo-box
           :x 20 :y 20 :width 320 :height 34
           :items (loop for i from 1 to 20 collect (format nil "Item ~2,'0D" i))
           :selected-index 0
           :max-visible-items 5
           :placeholder "Choose..."
           :popup-host-window window
           :window window))
        (combo-1
          (make-instance
           'mnas-sdl3-gui/widgets:combo-box
           :x 20 :y 60 :width 320 :height 34
           :items (loop for i from 1 to 20 collect (format nil "Atem ~2,'0D" i))
           :selected-index 0
           :max-visible-items 5
           :placeholder "Choose..."
           :popup-host-window window
           :window window)))
        (let ((widgets (list combo combo-1)))
          (when window
            (mnas-sdl3-gui/widgets:register-widgets-for-window window widgets))
          widgets)))




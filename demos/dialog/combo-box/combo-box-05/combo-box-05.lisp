;;;; ./demos/dialog/combo-box/combo-box-05/combo-box-05.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-05)

(defun create-combo-box-05-widgets (&optional window)
  (let ((combo
         (make-instance
          'mnas-sdl3-gui/widgets:combo-box
          :x 20 :y 40 :width 320 :height 34
          :main-height 34
          :items (loop for i from 1 to 50 collect (format nil "Item ~2,'0D" i))
          :selected-index 0
          :max-visible-items 6
          :window window)))
    (setf *widget* combo
          *widgets* (list combo))
    (when window
      (mnas-sdl3-gui/widgets:register-widgets-for-window window *widgets*))
    *widgets*))



(defun combo-box-05 ()
  "Run minimal combo-box demo with a single combo-box."
  (sdl3:enter-app-main-callbacks
   'combo-box-05-demo-init
   'combo-box-05-demo-iterate
   'combo-box-05-demo-event
   'combo-box-05-demo-quit))

;;; Usage:
;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-05)

;;;; (mnas-sdl3-gui/demos/dialog/combo-box-05:combo-box-05)
;;;; (combo-box-05)

;;;;(setf (mnas-sdl3-gui/widgets:<combo-box>-expanded-p (first *widgets*)) t)

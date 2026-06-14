;;;; ./demos/dialog/combo-box/combo-box-05/combo-box-05.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-05)

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

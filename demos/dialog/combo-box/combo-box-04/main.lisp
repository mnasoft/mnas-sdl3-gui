;;;; ./demos/dialog/combo-box/combo-box-04/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-04)

(defun combo-box-04 ()
  "Run minimal combo-box demo."
  (sdl3:enter-app-main-callbacks
   'combo-box-04-demo-init
   'combo-box-04-demo-iterate
   'combo-box-04-demo-event
   'combo-box-04-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-04)

;;;; (combo-box-04)

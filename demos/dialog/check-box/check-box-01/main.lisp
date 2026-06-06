;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)


(defun check-box-01 (&optional (style :windows))
  "Run check-box demo with keyboard focus support."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'check-box-demo-init
   'check-box-demo-iterate
   'check-box-demo-event
   'check-box-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/app)
;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/check-box-01)
;;;; (mnas-sdl3-gui/demos/dialog/check-box-01:check-box-01)
;;;; (check-box-01)

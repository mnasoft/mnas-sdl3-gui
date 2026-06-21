;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)


(defun main (&optional (style :windows))
  "Run check-box demo with keyboard focus support."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/app)
;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/check-box-01)

;;;; (mnas-sdl3-gui/demos/dialog/check-box-01:main)
;;;; (main)
;;;; (mnas-debug:enable)
;;;; (mnas-debug:disable)

;;;; ./demos/dialog/toggle/toggle-01/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(defun main (&optional (style :windows))
  "Run a grouped toggle demo."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/toggle)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/toggle-01)

;;;; (mnas-sdl3-gui/demos/dialog/toggle-01:main)
;;;; (main)

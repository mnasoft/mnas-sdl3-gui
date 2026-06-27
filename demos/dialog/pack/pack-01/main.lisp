(in-package :mnas-sdl3-gui/demos/dialog/pack-01)

(defun main (&optional (style :windows))
  "Run pack layout demo with multiple widgets of each type."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/pack)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/pack-01)

;;;; (mnas-sdl3-gui/demos/dialog/pack-01:main)
;;;; (main)

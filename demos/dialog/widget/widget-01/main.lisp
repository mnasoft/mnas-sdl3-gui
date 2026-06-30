 ;;;; ./demos/dialog/widget/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/widget-01)

(defun main (&optional (style :flat))
  "Run the widget dialog demo with STYLE (:flat, :windows, :motif)."
  (setf *style* style
        *open* t)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callbacks-iterate
   'callback-event
   'callback-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/widget)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/widget-01)

;;;; (mnas-sdl3-gui/demos/dialog/widget-01:main)
;;;; (main)

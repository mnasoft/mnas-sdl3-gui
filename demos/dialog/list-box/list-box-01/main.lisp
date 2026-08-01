;;;; ./demos/dialog/list-box/list-box-01/list-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(defun list-box-01 (&optional (style :windows))
  "Run demo with two list-box widgets and OK/Cancel buttons."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  *result*)

(defun main (&optional (style :windows))
  "Compatibility wrapper for the older demo entrypoint."
  (list-box-01 style))

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/list-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/list-box-01)

;;;; (mnas-sdl3-gui/demos/dialog/list-box-01:list-box-01)
;;;; (list-box-01)

;;;; (setf mnas-sdl3-gui/widgets::*debug-mouse-wheel-events* t)
;;;; (mnas-debug:enable)
;;;; (mnas-debug:disable)

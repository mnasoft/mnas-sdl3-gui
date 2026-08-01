;;;; ./demos/dialog/simple/simple-01/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

;;; Public demo function

(defun simple-01 (&optional (style :windows))
  "Run the simple dialog demo.
   Returns :ok or :cancel depending on which button was clicked."
  (setf *dialog-style* style)
  (sdl3:enter-app-main-callbacks
   'simple-dialog-init
   'simple-dialog-iterate
   'simple-dialog-event
   'simple-dialog-quit)
  *dialog-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/simple)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/simple-01)

;;;; (simple-01)

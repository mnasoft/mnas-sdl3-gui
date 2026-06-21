;;;; ./demos/dialog/entry/entry-01/entry-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)

(defun main (&optional (style :flat))
  "Run entry dialog and return entered text when OK is pressed.
Returns NIL when dialog is cancelled/closed."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  *result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry-01)

;;;; (main)
;;;; (mnas-sdl3-gui/demos/dialog/entry-01:main)

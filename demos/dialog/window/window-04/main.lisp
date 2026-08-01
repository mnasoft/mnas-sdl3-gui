;;;; ./demos/dialog/window/window-04/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-04)

(defun window-04 (&optional (style :windows))
  "Run dedicated demo for :transparent window flag."
  (mnas-sdl3-gui/widgets:set-widget-style style)
  (setf *window* nil
        *renderer* nil
        *window-id* 0
        *layer-manager* nil
        *toolbar* nil
        *open* t
        *opacity* +default-opacity+
        *frost* t)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  :done)

(defun main (&optional (style :windows))
  "Compatibility wrapper for the older demo entrypoint."
  (window-04 style))

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-04)
;;;; (mnas-sdl3-gui/demos/dialog/window-04:window-04)

;;;; ./demos/dialog/window/window-04/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-04)

(defun main ()
  "Run dedicated demo for :transparent window flag."
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

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-04)
;;;; (mnas-sdl3-gui/demos/dialog/window-04:main)

;;;; ./demos/dialog/window/window-03/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-03)

(defun window-03 ()
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

(defun main ()
  "Compatibility wrapper for old demo entrypoints."
  (window-03))


;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-03)

;;;; (mnas-sdl3-gui/demos/dialog/window-03:main)

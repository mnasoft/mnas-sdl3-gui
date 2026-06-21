;;;; ./demos/dialog/entry/entry-02/entry-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-02)

(defun main (&optional (style :flat))
  "Run the entry demo and return selected values when done."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  *result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry-02)

;;;; (main)
;;;; (mnas-sdl3-gui/demos/dialog/entry-02:main)

;;;;(setf (mnas-sdl3-gui/widgets:<entry>-text *name*) "name")

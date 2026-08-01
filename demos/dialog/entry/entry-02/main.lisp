;;;; ./demos/dialog/entry/entry-02/entry-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-02)

(defun entry-02 (&optional (style :flat))
  "Run the entry demo and return selected values when done."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  *result*)

(defun main (&optional (style :flat))
  "Compatibility wrapper for the older demo entrypoint."
  (entry-02 style))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry-02)

;;;; (entry-02)
;;;; (mnas-sdl3-gui/demos/dialog/entry-02:entry-02)

;;;;(setf (mnas-sdl3-gui/widgets:<entry>-text *name*) "name")

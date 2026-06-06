;;;; ./demos/dialog/toolbar/toolbar-demo/toolbar-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toolbar-demo)

(defun register-toolbar-demo-commands ()
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :toolbar/demo-new
    "New"
    :execute (lambda (ctx)
               (declare (ignore ctx))
               (format t "[toolbar-demo] New~%")
               (setf (mnas-sdl3-gui/widgets:widget-visible *toolbar*) nil)
               ))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :toolbar/demo-open
    "Open"
    :execute (lambda (ctx)
               (declare (ignore ctx))
               (format t "[toolbar-demo] Open~%")))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :toolbar/demo-quit
    "Quit"
    :execute (lambda (ctx)
               (declare (ignore ctx))
               (setf *open* nil)))
   :replace t))

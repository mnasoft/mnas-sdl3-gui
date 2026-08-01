;;;; ./demos/dialog/simple/simple-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

(defun simple-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun simple-01-register-commands ()
  "Register commands for simple-01 demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :simple-01/quit
    "Quit simple dialog"
    :group :simple-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *dialog-result* :cancel
                     *dialog-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :simple-01/ok
    "Confirm simple dialog"
    :group :simple-01
    :shortcut :return
    :execute (lambda (context)
               (declare (ignore context))
               (setf *dialog-result* :ok
                     *dialog-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :simple-01/cancel
    "Cancel simple dialog"
    :group :simple-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *dialog-result* :cancel
                     *dialog-open* nil)
               t))
   :replace t))

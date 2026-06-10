;;;; ./demos/dialog/combo-box/combo-box-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defun combo-box-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun combo-box-01-register-commands ()
  "Register commands for the combo-box-01 demo."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :combo-box-01/quit
    "Quit combo-box demo"
    :group :combo-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :combo-box-01/report
    "Report combo-box values"
    :group :combo-box-01
    :shortcut :enter
    :execute (lambda (context)
               (declare (ignore context))
               (combo-box-01-report-value)
               t))
   :replace t))


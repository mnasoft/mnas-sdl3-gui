;;;; ./demos/dialog/font/font-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/font-01)

(defun font-01-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun font-01-register-commands ()
  "Register font-01 demo commands in shared command registry."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :font-01/quit
    "Quit font demo"
    :group :font-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *cyrillic-font-open* nil)
               t))
   :replace t)
  t)

(defun font-01-register-shortcuts ()
  "Register keyboard shortcut routes for font-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut :font-01/quit :escape :replace t)
  t)

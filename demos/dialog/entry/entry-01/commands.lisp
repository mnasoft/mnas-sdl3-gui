;;;; ./demos/dialog/entry/entry-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)

(defun command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun register-commands ()
  "Register entry-01 demo commands in shared command registry."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-01/ok
    "Confirm entry dialog"
    :group :entry-01
    :shortcut :return
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result*
                     (mnas-sdl3-gui/widgets:<entry>-text *input*)
                     *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-01/cancel
    "Cancel entry dialog"
    :group :entry-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result* nil
                     *open* nil)
               t))
   :replace t)
  t)

(defun register-shortcuts ()
  "Register keyboard shortcut routes for entry-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut :entry-01/ok :return :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :entry-01/cancel :escape :replace t)
  t)

;;;; ./demos/dialog/entry/entry-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)

(defun entry-01-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun entry-01-register-commands ()
  "Register entry-01 demo commands in shared command registry."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-01/ok
    "Confirm entry dialog"
    :group :entry-01
    :shortcut :return
    :execute (lambda (context)
               (declare (ignore context))
               (setf *entry-01-result*
                     (mnas-sdl3-gui/widgets:entry-text *entry-01-input*)
                     *entry-01-open* nil)
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
               (setf *entry-01-result* nil
                     *entry-01-open* nil)
               t))
   :replace t)
  t)

(defun entry-01-register-shortcuts ()
  "Register keyboard shortcut routes for entry-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut :entry-01/ok :return :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :entry-01/cancel :escape :replace t)
  t)

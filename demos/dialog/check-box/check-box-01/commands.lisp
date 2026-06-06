;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)

(defun check-box-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun check-box-register-commands ()
  "Register commands for the check-box demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :check-box-01/quit
    "Quit check-box demo"
    :group :check-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t))

(defun check-box-register-shortcuts ()
  "Register keyboard shortcuts for the check-box demo." 
  (mnas-sdl3-gui/commands:register-shortcut :check-box-01/quit :escape :replace t)
  t)

(defun check-box-01-sync-command-state ()
  "Sync command state for check-box demo toolbar." 
  (let ((quit-cmd (mnas-sdl3-gui/commands:find-command :check-box-01/quit)))
    (when quit-cmd
      (mnas-sdl3-gui/commands:set-command-enabled quit-cmd t))))

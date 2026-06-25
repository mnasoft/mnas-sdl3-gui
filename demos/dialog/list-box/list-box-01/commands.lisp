;;;; ./demos/dialog/list-box/list-box-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(defun list-box-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun list-box-01-register-commands ()
  "Register commands for list-box-01 demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/quit
    "Quit list-box demo"
    :group :list-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result* nil
                     *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/ok
    "Confirm list selection"
    :group :list-box-01
    :shortcut :enter
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result*
                     (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *left*)
                                      (mnas-sdl3-gui/widgets:list-box-items *left*))
                           :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *right*)
                                       (mnas-sdl3-gui/widgets:list-box-items *right*)))
                     *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/cancel
    "Cancel list selection"
    :group :list-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result* nil
                     *open* nil)
               t))
   :replace t))

(defun list-box-01-register-shortcuts ()
  "Register keyboard shortcuts for list-box-01 demo." 
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/ok :enter :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/cancel :escape :replace t)
  t)

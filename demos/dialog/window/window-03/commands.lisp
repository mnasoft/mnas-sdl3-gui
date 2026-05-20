;;;; ./demos/dialog/window/window-03/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-03)

(defun window-03-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun window-03-register-commands ()
  "Register window-03 demo commands in shared command registry." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-03/quit
    "Quit transparent demo"
    :group :window-03
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *window-03-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-03/increase-opacity
    "Increase window opacity"
    :group :window-03
    :shortcut :up
    :execute (lambda (context)
               (declare (ignore context))
               (incf *window-03-opacity* +window-03-opacity-step+)
               (window-03-apply-opacity)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-03/decrease-opacity
    "Decrease window opacity"
    :group :window-03
    :shortcut :down
    :execute (lambda (context)
               (declare (ignore context))
               (decf *window-03-opacity* +window-03-opacity-step+)
               (window-03-apply-opacity)
               t))
   :replace t))

(defun window-03-register-shortcuts ()
  "Register keyboard shortcut routes for window-03 demo." 
  (mnas-sdl3-gui/commands:register-shortcut
   :window-03/quit
   :escape
   :scope :window-03
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-03/increase-opacity
   :up
   :scope :window-03
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-03/decrease-opacity
   :down
   :scope :window-03
   :replace t))

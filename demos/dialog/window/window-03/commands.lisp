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
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (< *window-03-opacity* 0.999))
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
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (> *window-03-opacity* 0.151))
    :execute (lambda (context)
               (declare (ignore context))
               (decf *window-03-opacity* +window-03-opacity-step+)
               (window-03-apply-opacity)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-03/reset-opacity
    "Reset window opacity"
    :group :window-03
    :shortcut :r
    :visible nil
    :execute (lambda (context)
               (declare (ignore context))
               (setf *window-03-opacity* +window-03-default-opacity+)
               (window-03-apply-opacity)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-03/toggle-frost
    "Toggle frosted panel style"
    :group :window-03
    :shortcut :f
    :checked t
    :execute (lambda (context)
               (declare (ignore context))
               (setf *window-03-frost* (not *window-03-frost*))
               (let ((cmd (mnas-sdl3-gui/commands:find-command :window-03/toggle-frost)))
                 (when cmd
                   (setf (mnas-sdl3-gui/commands:command-checked cmd)
                         *window-03-frost*)))
               t))
   :replace t))

(defun window-03-register-shortcuts ()
  "Register keyboard shortcut routes for window-03 demo." 
  (mnas-sdl3-gui/commands:register-shortcut
   :window-03/quit
   :escape
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-03/increase-opacity
   :up
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-03/decrease-opacity
   :down
    :replace t)
    (mnas-sdl3-gui/commands:register-shortcut
    :window-03/reset-opacity
    :r
    :replace t)
    (mnas-sdl3-gui/commands:register-shortcut
    :window-03/toggle-frost
    :f
   :replace t))

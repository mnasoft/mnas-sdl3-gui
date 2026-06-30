;;;; ./demos/dialog/window/window-04/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-04)

(defun window-04-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun register-commands ()
  "Register window-04 demo commands in shared command registry."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-04/quit "Quit transparent demo"
    :group :window-04
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-04/increase-opacity "Increase window opacity"
    :group :window-04
    :shortcut :up
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (< *opacity* 0.999))
    :execute (lambda (context)
               (declare (ignore context))
               (incf *opacity* +opacity-step+)
               (window-04-apply-opacity)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-04/decrease-opacity "Decrease window opacity"
    :group :window-04
    :shortcut :down
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (> *opacity* 0.151))
    :execute (lambda (context)
               (declare (ignore context))
               (decf *opacity* +opacity-step+)
               (window-04-apply-opacity)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-04/reset-opacity "Reset window opacity"
    :group :window-04
    :shortcut :r
    :visible nil
    :execute (lambda (context)
               (declare (ignore context))
               (setf *opacity* +default-opacity+)
               (window-04-apply-opacity)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-04/toggle-frost "Toggle frosted panel style"
    :group :window-04
    :shortcut :f
    :checked t
    :execute (lambda (context)
               (declare (ignore context))
               (setf *frost* (not *frost*))
               (let ((cmd (mnas-sdl3-gui/commands:find-command :window-04/toggle-frost)))
                 (when cmd
                   (mnas-sdl3-gui/commands:set-command-checked cmd *frost*))))
    :can-execute t)
   :replace t))

(defun register-shortcuts ()
  "Register keyboard shortcut routes for window-04 demo."
  (mnas-sdl3-gui/commands:register-shortcut
   :window-04/quit
   :escape
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-04/increase-opacity
   :up
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-04/decrease-opacity
   :down
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-04/reset-opacity
   :r
   :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :window-04/toggle-frost
   :f
   :replace t))

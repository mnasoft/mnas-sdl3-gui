;;;; ./demos/dialog/window/window-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

(defun command (id &rest context-plist)
  "Execute window-01 command ID with plist CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun register-commands ()
  "Register window-01 runtime commands in shared command registry."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-01/quit "Quit window-01 demo"
    :group :window-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-01/open-modal-1 "Open modal level 1"
    :group :window-01
    :shortcut :m
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (not *modal-1-open*))
    :execute (lambda (context)
               (declare (ignore context))
               (open-modal-1)))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-01/open-modal-2 "Open nested modal level 2"
    :group :window-01
    :shortcut :n
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (and *modal-1-open*
                        (not *modal-2-open*)))
    :execute (lambda (context)
               (declare (ignore context))
               (open-modal-2)))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-01/close-top-modal "Close top modal"
    :group :window-01
    :shortcut :backspace
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (or *modal-1-open* *modal-2-open*))
    :execute (lambda (context)
               (declare (ignore context))
               (close-top-modal)))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-01/reset-size "Reset to default window size"
    :group :window-01
    :shortcut :r
    :visible nil
    :execute (lambda (context)
               (declare (ignore context))
               (setf *width* +default-width+
                     *height* +default-height+)
               (when *window*
                 (sdl3:set-window-size *window*
                                       +default-width+
                                       +default-height+))
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command :window-01/toggle-grid "Toggle grid overlay"
    :group :window-01
    :shortcut :g
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (setf *show-grid* (not *show-grid*))
               (let ((cmd (mnas-sdl3-gui/commands:find-command :window-01/toggle-grid)))
                 (when cmd
                   (mnas-sdl3-gui/commands:set-command-checked cmd *show-grid*)))
               t))
   :replace t))

(defun register-shortcuts ()
  "Register keyboard shortcut routes for window-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut :window-01/open-modal-1 :m :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :window-01/open-modal-2 :n :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :window-01/close-top-modal :backspace :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :window-01/toggle-grid :g :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :window-01/reset-size :r :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :window-01/quit :escape :replace t))

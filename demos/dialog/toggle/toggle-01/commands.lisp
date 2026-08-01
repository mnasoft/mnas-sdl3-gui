;;;; ./demos/dialog/toggle/toggle-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(defun toggle-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun toggle-01-register-commands ()
  "Register grouped toggle commands for the demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :toggle-01/quit
    "Quit toggle demo"
    :group :toggle-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t)
  (dolist (spec +command-map+)
    (destructuring-bind (id group label shortcut) spec
      (mnas-sdl3-gui/commands:register-command
       (mnas-sdl3-gui/commands:make-command
        id
        (format nil "Select ~A" label)
        :group group
        :shortcut shortcut
        :checked nil
        :execute (lambda (context)
                   (declare (ignore context))
                   (toggle-01-select group label)
                   t))
       :replace t))))

(defun toggle-01-register-shortcuts ()
  "Register keyboard shortcuts for toggle commands." 
  (mnas-sdl3-gui/commands:register-shortcut :toggle-01/quit :escape :replace t)
  (dolist (spec +command-map+)
    (destructuring-bind (id group label shortcut) spec
      (declare (ignore group label))
      (mnas-sdl3-gui/commands:register-shortcut id shortcut :replace t)))
  t)

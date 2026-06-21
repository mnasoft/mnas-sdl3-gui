;;;; ./demos/dialog/toggle/toggle-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(defparameter +command-map+
  '((:toggle-01/group-1-option-1 :group-1 "Вариант 1" :one)
    (:toggle-01/group-1-option-2 :group-1 "Вариант 2" :two)
    (:toggle-01/group-1-option-3 :group-1 "Вариант 3" :three)
    (:toggle-01/group-1-option-4 :group-1 "Вариант 4" :four)
    (:toggle-01/group-2-option-1 :group-2 "Опция 1" :q)
    (:toggle-01/group-2-option-2 :group-2 "Опция 2" :w)
    (:toggle-01/group-2-option-3 :group-2 "Опция 3" :e)
    (:toggle-01/group-2-option-4 :group-2 "Опция 4" :r)))

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

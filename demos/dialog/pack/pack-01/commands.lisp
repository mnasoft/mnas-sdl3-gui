;;;; ./demos/dialog/pack/pack-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/pack-01)

(defun pack-01-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun pack-01-register-commands ()
  "Register pack-01 demo commands in shared command registry." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/quit
    "Quit pack layout demo"
    :group :pack-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *pack-demo-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/apply
    "Apply current settings"
    :group :pack-01
    :shortcut :p
    :execute (lambda (context)
               (declare (ignore context))
               (setf *pack-demo-status* "Нажата кнопка: Применить")
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/reset
    "Reset demo settings"
    :group :pack-01
    :shortcut :r
    :execute (lambda (context)
               (declare (ignore context))
               (pack-01-reset-settings)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/theme-flat
    "Use flat widget style"
    :group :pack-01/theme
    :shortcut :f
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (pack-01-apply-style :flat)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/theme-windows
    "Use windows widget style"
    :group :pack-01/theme
    :shortcut :w
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (pack-01-apply-style :windows)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/toggle-logs
    "Toggle logs option"
    :group :pack-01
    :shortcut :l
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (pack-01-toggle-logs)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :pack-01/toggle-backup
    "Toggle backup option"
    :group :pack-01
    :shortcut :b
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (pack-01-toggle-backup)
               t))
   :replace t))

(defun pack-01-register-shortcuts ()
  "Register keyboard shortcut routes for pack-01 demo." 
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/apply :p :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/reset :r :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/theme-flat :f :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/theme-windows :w :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/toggle-logs :l :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :pack-01/toggle-backup :b :replace t)
  t)

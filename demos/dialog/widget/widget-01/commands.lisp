;;;; ./demos/dialog/widget/widget-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/widget-01)

(defun widget-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun widget-01-register-commands ()
  "Register command set for widget-01 demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :widget-01/quit
    "Quit widget demo"
    :group :widget-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *widget-01-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :widget-01/style-flat
    "Switch widget style to flat"
    :group :widget-01/style
    :shortcut :f
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (widget-01-apply-style :flat)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :widget-01/style-windows
    "Switch widget style to windows"
    :group :widget-01/style
    :shortcut :w
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (widget-01-apply-style :windows)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :widget-01/style-motif
    "Switch widget style to motif"
    :group :widget-01/style
    :shortcut :m
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (widget-01-apply-style :motif)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :widget-01/clear-entry
    "Clear entry field text"
    :group :widget-01
    :shortcut :c
    :visible nil
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (let ((entry (widget-01-entry-widget)))
                     (and entry (> (length (mnas-sdl3-gui/widgets:entry-text entry)) 0))))
    :execute (lambda (context)
               (declare (ignore context))
               (let ((entry (widget-01-entry-widget)))
                 (when entry
                   (setf (mnas-sdl3-gui/widgets:entry-text entry) ""
                         (mnas-sdl3-gui/widgets:entry-cursor entry) 0)
                   (setf *status-message* "Entry text cleared from command toolbar.")
                   t))))
   :replace t))

(defun widget-01-register-shortcuts ()
  "Register keyboard shortcuts for widget-01 commands." 
  (mnas-sdl3-gui/commands:register-shortcut :widget-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :widget-01/style-flat :f :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :widget-01/style-windows :w :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :widget-01/style-motif :m :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :widget-01/clear-entry :c :replace t)
  t)

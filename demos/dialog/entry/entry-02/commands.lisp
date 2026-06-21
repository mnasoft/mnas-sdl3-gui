;;;; ./demos/dialog/entry/entry-02/entry-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-02)

(defun command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun register-commands ()
  "Register commands for entry-02 demo."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-02/quit
    "Quit entry-02 demo"
    :group :entry-02
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-02/run
    "Run command from entry"
    :group :entry-02
    :shortcut :return
    :execute (lambda (context)
               (declare (ignore context))
               (setf *status*
                     (format nil "Command executed: ~A"
                             (mnas-sdl3-gui/widgets:<entry>-text *command*)))
               t))
   :replace t))

(defun register-shortcuts ()
  "Register keyboard shortcuts for entry-02 demo."
  (mnas-sdl3-gui/commands:register-shortcut :entry-02/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :entry-02/run :return :replace t)
  t)

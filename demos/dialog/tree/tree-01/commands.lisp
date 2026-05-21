;;;; ./demos/dialog/tree/tree-01/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/tree-01)

(defun tree-01-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun tree-01-register-commands ()
  "Register tree-01 demo commands in shared command registry." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :tree-01/quit
    "Quit filesystem tree demo"
    :group :tree-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *tree-01-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :tree-01/load
    "Load filesystem tree"
    :group :tree-01
    :shortcut :return
    :can-execute (lambda (context)
                   (declare (ignore context))
                   (and *tree-01-tree* *tree-01-root-entry*))
    :execute (lambda (context)
               (declare (ignore context))
               (tree-01-load-tree)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :tree-01/toggle-hidden
    "Toggle hidden files visibility"
    :group :tree-01
    :shortcut :h
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (when *tree-01-show-hidden*
                 (setf (mnas-sdl3-gui/widgets:check-box-checked *tree-01-show-hidden*)
                       (not (mnas-sdl3-gui/widgets:check-box-checked *tree-01-show-hidden*)))
                 (setf (mnas-sdl3-gui/widgets:widget-value *tree-01-show-hidden*)
                       (mnas-sdl3-gui/widgets:check-box-checked *tree-01-show-hidden*)))
               (tree-01-load-tree)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :tree-01/clear-filter
    "Clear extension filter"
    :group :tree-01
    :shortcut :f
    :visible nil
    :execute (lambda (context)
               (declare (ignore context))
               (when *tree-01-filter-entry*
                 (setf (mnas-sdl3-gui/widgets:entry-text *tree-01-filter-entry*) ""
                       (mnas-sdl3-gui/widgets:entry-cursor *tree-01-filter-entry*) 0))
               (tree-01-load-tree)
               t))
   :replace t))

(defun tree-01-register-shortcuts ()
  "Register keyboard shortcut routes for tree-01 demo." 
  (mnas-sdl3-gui/commands:register-shortcut :tree-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :tree-01/load :return :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :tree-01/toggle-hidden :h :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :tree-01/clear-filter :f :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :tree-01/load :r :replace t))

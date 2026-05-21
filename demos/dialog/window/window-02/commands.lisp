;;;; ./demos/dialog/window/window-02/commands.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(defun window-02-command (id &rest context-plist)
  "Execute demo command ID with plist CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun window-02-register-commands ()
  "Register window-02 demo commands in shared command registry." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-02/quit
    "Quit popup demo"
    :group :window-02
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *window-02-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-02/escape
    "Context-aware escape for popup demo"
    :group :window-02
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (if *window-02-popup-visible*
                   (window-02-hide-popup)
                   (setf *window-02-open* nil))
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-02/toggle-popup
    "Toggle popup"
    :group :window-02
    :execute (lambda (context)
               (if *window-02-popup-visible*
                   (window-02-hide-popup)
                   (window-02-show-popup-at (getf context :x 40)
                                            (getf context :y 40)))
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-02/toggle-pin
    "Toggle sticky popup mode"
    :group :window-02
    :shortcut :p
    :checked nil
    :execute (lambda (context)
               (declare (ignore context))
               (setf *window-02-pin-popup* (not *window-02-pin-popup*))
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :window-02/select-popup-item
    "Select popup item"
    :group :window-02
    :can-execute (lambda (context)
                   (declare (ignore context))
                   *window-02-popup-visible*)
    :execute (lambda (context)
               (let ((index (getf context :index)))
                 (if (and (integerp index)
                          (>= index 0)
                          (< index (length *window-02-popup-items*)))
                     (setf *window-02-selected-item* (nth index *window-02-popup-items*))
                     (setf *window-02-selected-item* "No item selected"))
                 (window-02-hide-popup)
                 t)))
        :replace t)
        (mnas-sdl3-gui/commands:register-command
        (mnas-sdl3-gui/commands:make-command
         :window-02/reset-selection
         "Reset selected popup item"
         :group :window-02
         :shortcut :r
         :visible nil
         :execute (lambda (context)
                (declare (ignore context))
                (setf *window-02-selected-item* "No item selected")
                t))
   :replace t))

(defun window-02-register-shortcuts ()
  "Register keyboard shortcut routes for window-02 demo." 
  (mnas-sdl3-gui/commands:register-shortcut
   :window-02/escape
   :escape
        :replace t)
        (mnas-sdl3-gui/commands:register-shortcut
        :window-02/reset-selection
        :r
        :replace t)
        (mnas-sdl3-gui/commands:register-shortcut
        :window-02/toggle-pin
        :p
   :replace t))

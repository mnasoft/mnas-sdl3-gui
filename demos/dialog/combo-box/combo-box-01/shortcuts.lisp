;;;; ./demos/dialog/combo-box/combo-box-01/shortcuts.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defun combo-box-01-register-shortcuts ()
  "Register keyboard shortcuts for the combo-box-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut
   :combo-box-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut
   :combo-box-01/report :enter :replace t)
  t)

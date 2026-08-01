

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

(defun simple-01-register-shortcuts ()
  "Register keyboard shortcuts for simple-01 demo." 
  (mnas-sdl3-gui/commands:register-shortcut :simple-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :simple-01/ok :return :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :simple-01/cancel :escape :replace t)
  t)

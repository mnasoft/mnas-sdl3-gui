;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/check-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)


(mnas-sdl3-gui/widgets:widgets-for-window *window*)

(setf (mnas-sdl3-gui/widgets:widget-x *toolbar*) 100)
(setf (mnas-sdl3-gui/widgets:widget-y *toolbar*) 280)

(check-box-content-widgets)

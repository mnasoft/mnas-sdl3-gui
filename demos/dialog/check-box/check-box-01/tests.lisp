;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/check-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/check-box-01)

;;;; (mnas-sdl3-gui/demos/dialog/check-box-01:check-box-01)

(let* ((wdgets (mnas-sdl3-gui/widgets:widgets-for-window *window*))
       (num 4)
       (tgl (nth num wdgets)))
  (setf  (mnas-sdl3-gui/widgets:<widget>-padding tgl) 3)
  (list tgl (mnas-sdl3-gui/widgets:<widget>-padding tgl)))

        (mnas-sdl3-gui/widgets:widget-min-size tgl)))


(setf 
 (mnas-sdl3-gui/widgets:label
  (last
   (mnas-sdl3-gui/widgets:widgets-for-window *window*)))
 "CCCLLLQQQQ"
 )

(loop :for i :in (mnas-sdl3-gui/widgets:widgets-for-window *window*)
      :collect (mnas-sdl3-gui/widgets:label i))

(mnas-sdl3-gui/widgets:widget-min-size
 (nth 0 (mnas-sdl3-gui/widgets:widgets-for-window *window*)))

(setf (mnas-sdl3-gui/widgets:<widget>-x *toolbar*) 100)
(setf (mnas-sdl3-gui/widgets:<widget>-y *toolbar*) 280)

(mnas-debug:enable)
(mnas-debug:disable)
mnas-debug::*debug*

(check-box-content-widgets)

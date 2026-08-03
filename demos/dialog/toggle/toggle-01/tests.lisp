(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/toggle-01)
;;;; (mnas-sdl3-gui/demos/dialog/toggle-01:toggle-01)


(loop :for i :in (mnas-sdl3-gui/widgets:widgets-for-window *window*)
      :collect (mnas-sdl3-gui/widgets:label i))

(let* ((wdgets (mnas-sdl3-gui/widgets:widgets-for-window *window*))
       (num 4)
       (tgl (nth num wdgets)))
  ;;(setf (mnas-sdl3-gui/widgets:<widget>-padding tgl) 1)
  (list tgl
        (mnas-sdl3-gui/widgets:widget-min-size tgl)))



(mnas-sdl3-gui/widgets:widget-min-size
 (nth 4 (mnas-sdl3-gui/widgets:widgets-for-window *window*)))

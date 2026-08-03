(in-package :mnas-sdl3-gui/demos/dialog/widget-01)

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/widget-01)
;;;; (mnas-sdl3-gui/demos/dialog/widget-01:widget-01)

*window*

(defmacro mk-x-y-finder (x y)
  `(lambda (wdt)
     (and
      (= ,x (mnas-sdl3-gui/widgets:<widget>-x wdt))
      (= ,y (mnas-sdl3-gui/widgets:<widget>-y wdt)))))

(let* ((window *window*)
       (widgets (mnas-sdl3-gui/widgets:widgets-for-window window)))
  widgets)

(let* ((window *window*)
       (widgets (mnas-sdl3-gui/widgets:widgets-for-window window))
       (toggle (find-if (mk-x-y-finder 140 100) widgets)))
  (setf (mnas-sdl3-gui/widgets:<widget>-focused toggle) t)
  (setf (mnas-sdl3-gui/widgets:<toggle>-state   toggle) t)
  (mnas-sdl3-gui/widgets:widget-min-size toggle)) 

(type-of *window*)  ; => SB-SYS:SYSTEM-AREA-POINTER

(content-height (max 1 (- (<widget>-height widget) (* 2 padding))))

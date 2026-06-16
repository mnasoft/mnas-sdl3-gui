;;;; ./src/widgets/methods/<entry>-scroll-to-start.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-scroll-to-start ((widget <entry>))
  (setf (<entry>-scroll-offset widget) 0))

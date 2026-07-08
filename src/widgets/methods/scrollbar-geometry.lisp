;;;; ./src/widgets/methods/ignore-next-popup-mouse-down-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod scrollbar-geometry ((widget <combo-box-popup>) popup-x popup-y)
  (combo-box-popup-scrollbar-geometry widget popup-x popup-y))

(defmethod scrollbar-geometry ((widget <combo-box>) popup-x popup-y)
  (combo-box-popup-scrollbar-geometry widget popup-x popup-y))

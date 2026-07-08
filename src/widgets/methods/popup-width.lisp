;;;; ./src/widgets/methods/popup-width.lisp

(in-package :mnas-sdl3-gui/widgets)

#+nil
(defmethod popup-width ((widget <combo-box>))
  (<widget>-width widget))

#+nil
(defmethod popup-width ((widget <combo-box-popup>))
  (<widget>-width widget))


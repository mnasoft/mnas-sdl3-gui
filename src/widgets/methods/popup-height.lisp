;;;; ./src/widgets/methods/popup-height.lisp

(in-package :mnas-sdl3-gui/widgets)


(defmethod popup-height ((widget <combo-box>))
  (combo-box-popup-height widget))

(defmethod popup-height ((widget <combo-box-popup>))
  (<widget>-height widget))



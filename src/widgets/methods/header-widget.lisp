;;;; ./src/widgets/methods/header-widget.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod header-widget ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (and (typep owner '<combo-box>)
         (header-widget owner))))

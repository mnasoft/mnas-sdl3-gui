;;;; ./src/widgets/methods/initialize-instance.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod initialize-instance :after ((widget toggle) &key &allow-other-keys)
  (register-toggle-group-member widget))
;;;; ./src/widgets/methods/handle-text-input-event.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-text-input-event (null ev)
  nil)

(defmethod handle-text-input-event ((widgets cons) ev)
  (let ((widget (focused-<entry> widgets)))
    (when widget
      (handle-text-input-event widget ev))))

(defmethod handle-text-input-event ((widget <entry>) (ev sdl3:text-input-event))
  (let ((text (slot-value ev 'sdl3:%text)))
    (loop :for char :across text
          :do (handle-keyboard-event widget
                                      (make-widget-keyboard-input nil char)))
    :continue))

(defmethod handle-text-input-event ((widget <widget-container>) (ev sdl3:text-input-event))
  (let ((focused-child (focused-widget (children widget))))
    (when focused-child
      (handle-text-input-event focused-child ev))))

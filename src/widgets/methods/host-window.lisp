;;;; ./src/widgets/methods/host-window.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod host-window ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (and owner (<widget>-window owner))))

(defmethod (setf host-window) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (when owner
      (setf (<widget>-window owner) new-value)))
  new-value)

(defmethod host-window ((widget <combo-box>))
  (let ((popup (popup-widget widget)))
    (and popup (host-window popup))))

(defmethod (setf host-window) (new-value (widget <combo-box>))
  (let ((popup (popup-widget widget)))
    (if popup
        (setf (host-window popup) new-value)
        (setf (<widget>-window widget) new-value)))
  new-value)

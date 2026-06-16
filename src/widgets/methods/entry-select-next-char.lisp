;;;; ./src/widgets/methods/<entry>-select-next-char.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-select-next-char ((widget <entry>))
  (let ((anchor (<entry>-selection-anchor widget))
        (text-len (length (<entry>-text widget))))
    (when (< (<entry>-cursor widget) text-len)
      (incf (<entry>-cursor widget))
      (<entry>-ensure-cursor-visible widget)
      (<entry>-select-from-anchor widget anchor)))
  t)
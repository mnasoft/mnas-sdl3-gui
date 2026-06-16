;;;; ./src/widgets/methods/<entry>-show-text.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-show-text ((widget <entry>))
  "Return the display text for WIDGET using its show mask if present."
  (when (<entry>-show widget)
    (let* ((len (length (<entry>-text widget)))
           (mask (<entry>-show widget))
           (char (if (characterp mask)
                     mask
                     (if (> (length mask) 0)
                         (char mask 0)
                         #\*))))
      (make-string len :initial-element char))))

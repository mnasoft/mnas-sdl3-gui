;;;; ./src/widgets/methods/entry-copy-to-clipboard.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-copy-to-clipboard ((obj entry))
  (let ((selected (get-entry-selected-text obj)))
    (when (plusp (length selected))
      (sdl3:set-clipboard-text selected))))

(defmethod entry-copy-to-clipboard ((obj password-entry))
  ;; Do not place password text into the system clipboard.
  (declare (ignore obj))
  nil)

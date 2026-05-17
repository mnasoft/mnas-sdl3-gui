;;;; ./src/widgets/methods/entry-copy-to-clipboard.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod entry-copy-to-clipboard ((widget entry))
  (let ((selected (get-entry-selected-text widget)))
    (when (plusp (length selected))
      (sdl3:set-clipboard-text selected))))
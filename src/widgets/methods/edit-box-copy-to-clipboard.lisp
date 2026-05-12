;;;; ./src/widgets/methods/edit-box-copy-to-clipboard.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-copy-to-clipboard ((widget edit-box))
  (let ((selected (get-edit-box-selected-text widget)))
    (when (plusp (length selected))
      (sdl3:set-clipboard-text selected))))
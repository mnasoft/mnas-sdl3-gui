;;;; ./src/widgets/methods/edit-box-ensure-cursor-visible.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-ensure-cursor-visible ((widget edit-box))
  (let* ((cursor (max 0 (min (edit-box-cursor widget) (length (edit-box-text widget)))))
         (visible-width (edit-box-inner-width widget))
         (start (max 0 (min (edit-box-scroll-offset widget) cursor))))
    (when (< cursor start)
      (setf start cursor))
    (loop while (> (edit-box-text-width-between widget start cursor) visible-width)
          do (incf start))
    (setf (edit-box-scroll-offset widget) start)
    (normalize-edit-box-scroll-offset widget)))
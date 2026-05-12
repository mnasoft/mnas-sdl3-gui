;;;; ./src/widgets/methods/edit-box-move-to-next-word.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod edit-box-move-to-next-word ((widget edit-box))
  (let* ((text (edit-box-text widget))
         (cursor (edit-box-cursor widget))
         (len (length text)))
    (when (< cursor len)
      (loop while (< cursor len)
            do (incf cursor)
            while (and (< cursor len) (char-is-word-char-p (aref text (1- cursor)))))
      (loop while (< cursor len)
            while (not (char-is-word-char-p (aref text cursor)))
            do (incf cursor))
      (setf (edit-box-cursor widget) cursor)
      (clear-edit-box-selection widget)
      (edit-box-ensure-cursor-visible widget))))
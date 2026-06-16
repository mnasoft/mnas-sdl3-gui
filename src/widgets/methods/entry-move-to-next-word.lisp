;;;; ./src/widgets/methods/<entry>-move-to-next-word.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-move-to-next-word ((widget <entry>))
  (let* ((text (<entry>-text widget))
         (cursor (<entry>-cursor widget))
         (len (length text)))
    (when (< cursor len)
      (loop while (< cursor len)
            do (incf cursor)
            while (and (< cursor len) (char-is-word-char-p (aref text (1- cursor)))))
      (loop while (< cursor len)
            while (not (char-is-word-char-p (aref text cursor)))
            do (incf cursor))
      (setf (<entry>-cursor widget) cursor)
      (clear-<entry>-selection widget)
      (<entry>-ensure-cursor-visible widget))))
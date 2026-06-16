;;;; ./src/widgets/methods/<entry>-valid-text-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod <entry>-valid-text-p ((obj <entry>) text)
  "Return T when TEXT is accepted by WIDGET's validation function or no validator is set."
  (let ((validator (<entry>-validate obj)))
    (or (null validator)
        (funcall validator text))))

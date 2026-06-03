(progn
  (ql:quickload :mnas-sdl3-gui/demos/layout/grid-01)
  (let ((file "/home/mna/quicklisp/local-projects/sdl3/mnas-sdl3-gui/demos/layout/grid-01/grid-01.lisp"))
    (with-open-file (in file)
      (loop for form = (read in nil nil) while form do
        (when (and (consp form)
               (string= (string-upcase (symbol-name (if (symbolp (first form)) (first form) (if (consp (first form)) (first (first form)) '()))) ) "DEF-APP-INIT"))
          (format t "Found form: ~S~%~%" form)
          (format t "Macroexpand: ~S~%~%" (macroexpand-1 form))))))
  (sb-ext:quit))

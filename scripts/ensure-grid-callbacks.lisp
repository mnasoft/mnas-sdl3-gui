(progn
  (format t "Ensure grid demo callbacks: begin~%")
  (handler-case
      (progn
        (ql:quickload :mnas-sdl3-gui/demos/layout/grid-01)
        (format t "System loaded.~%")
        (let ((file "/home/mna/quicklisp/local-projects/sdl3/mnas-sdl3-gui/demos/layout/grid-01/grid-01.lisp")
              (demo-pkg-name "MNAS-SDL3-GUI/DEMOS/LAYOUT/GRID-01"))
          (let ((pkg (find-package demo-pkg-name)))
            (if (null pkg)
                (format t "Demo package ~A not found; cannot set package for reading.~%" demo-pkg-name)
                (progn
                  (format t "Reading file with *package* set to ~S~%" pkg)
                  (let ((*package* pkg))
                    (with-open-file (in file :direction :input :external-format :utf-8)
                      (loop for form = (read in nil nil) while form do
                            (let* ((head (if (symbolp (first form)) (first form) (if (consp (first form)) (first (first form)) nil)))
                                   (head-name (and head (string-upcase (symbol-name head)))))
                              (when (and head-name (search "DEF-APP-" head-name))
                                (format t "Found ~S -- macroexpanding...~%" head)
                                (let ((exp (macroexpand-1 form)))
                                  (format t "Expansion: ~S~%" exp)
                                  (format t "Evaluating expansion in package ~S~%" pkg)
                                  (handler-case
                                      (progn (eval exp) (format t "Eval ok.~%"))
                                    (error (e) (format t "Eval error: ~S~%" e))))))))))))))
    (error (e) (format t "Top-level error: ~S~%" e)))
  (format t "Ensure grid demo callbacks: done~%")
  (sb-ext:quit))

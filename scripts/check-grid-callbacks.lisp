(progn
  (ql:quickload :mnas-sdl3-gui/demos/layout/grid-01)
  (let ((pkg (find-package "MNAS-SDL3-GUI/DEMOS/LAYOUT/GRID-01")))
    (in-package :cl-user)
        (format t "package: ~S~%" pkg)
        (let* ((symbols '(grid-demo-init grid-demo-iterate grid-demo-event grid-demo-quit))
          (cffi-pkg (find-package "CFFI"))
          (get-callback-fn (and cffi-pkg
                 (multiple-value-bind (cb-sym cb-status) (find-symbol "GET-CALLBACK" cffi-pkg)
              (and cb-sym (fboundp cb-sym) (symbol-function cb-sym))))))
          (dolist (s symbols)
       (let* ((sym (intern (string-upcase (symbol-name s)) pkg))
         (fn-boundp (fboundp sym))
         (cb (if get-callback-fn
            (handler-case (funcall get-callback-fn sym) (error (e) :error))
            :no-cffi)))
         (format t "~S -> fboundp: ~S~%" sym fn-boundp)
         (format t "~S -> cffi callback: ~S~%~%" sym cb)))))
    (sb-ext:quit)))

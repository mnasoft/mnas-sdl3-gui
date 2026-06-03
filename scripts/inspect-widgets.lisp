;;; scripts/inspect-widgets.lisp
(eval-when (:load-toplevel :execute)
  (ql:quickload :mnas-sdl3-gui)
  (let* ((pkg (find-package "MNAS-SDL3-GUI/WIDGETS"))
         (wm (intern "WIDGET-MEASURE" pkg))
         (wa (intern "WIDGET-ARRANGE" pkg)))
    (format t "WIDGET-MEASURE symbol: ~S~%" wm)
    (format t "widget-measure symbol-function type: ~S~%" (type-of (symbol-function wm)))
    (format t "widget-measure symbol-function: ~S~%~%" (symbol-function wm))
    (handler-case
        (dolist (m (sb-mop:generic-function-methods (symbol-function wm)))
          (format t "MEASURE-METHOD: ~S~%  specializers: ~S~%  function: ~S~%~%"
                  m (sb-mop:method-specializers m) (sb-mop:method-function m)))
      (error (e) (format t "MEASURE-METHODS-ERROR: ~S~%~%" e)))
    (format t "WIDGET-ARRANGE symbol: ~S~%" wa)
    (format t "widget-arrange symbol-function type: ~S~%" (type-of (symbol-function wa)))
    (format t "widget-arrange symbol-function: ~S~%~%" (symbol-function wa))
    (handler-case
        (dolist (m (sb-mop:generic-function-methods (symbol-function wa)))
          (format t "ARRANGE-METHOD: ~S~%  specializers: ~S~%  function: ~S~%~%"
                  m (sb-mop:method-specializers m) (sb-mop:method-function m)))
      (error (e) (format t "ARRANGE-METHODS-ERROR: ~S~%~%" e)))
    (sb-ext:quit)))

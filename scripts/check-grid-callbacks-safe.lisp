(progn
  (handler-case
      (progn
        (format t "Quickloading demo system...~%")
        (ql:quickload :mnas-sdl3-gui/demos/layout/grid-01)
        (format t "Quickload done.~%")
        (let ((pkg (find-package "MNAS-SDL3-GUI/DEMOS/LAYOUT/GRID-01")))
          (if (null pkg)
              (format t "Package not found.~%")
              (progn
                (multiple-value-bind (init-sym init-status) (find-symbol "GRID-DEMO-INIT" pkg)
                  (format t "GRID-DEMO-INIT -> ~S / status=~S fboundp=~S~%" init-sym init-status (and init-sym (fboundp init-sym))))
                (multiple-value-bind (iter-sym iter-status) (find-symbol "GRID-DEMO-ITERATE" pkg)
                  (format t "GRID-DEMO-ITERATE -> ~S / status=~S fboundp=~S~%" iter-sym iter-status (and iter-sym (fboundp iter-sym))))
                (multiple-value-bind (event-sym event-status) (find-symbol "GRID-DEMO-EVENT" pkg)
                  (format t "GRID-DEMO-EVENT -> ~S / status=~S fboundp=~S~%" event-sym event-status (and event-sym (fboundp event-sym))))
                (multiple-value-bind (quit-sym quit-status) (find-symbol "GRID-DEMO-QUIT" pkg)
                  (format t "GRID-DEMO-QUIT -> ~S / status=~S fboundp=~S~%" quit-sym quit-status (and quit-sym (fboundp quit-sym))))

                ;; cffi:get-callback lookup
                (when (find-package "CFFI")
                  (multiple-value-bind (cb-sym cb-status) (find-symbol "GET-CALLBACK" (find-package "CFFI"))
                    (if (null cb-sym)
                        (format t "CFFI GET-CALLBACK not found.~%")
                        (progn
                          (format t "CFFI GET-CALLBACK symbol: ~S / status=~S~%" cb-sym cb-status)
                          (when (fboundp cb-sym)
                            (let ((cb-fn (symbol-function cb-sym)))
                              (format t "CFFI GET-CALLBACK function: ~S~%" cb-fn)
                              (dolist (sym (list init-sym iter-sym event-sym quit-sym))
                                (format t "Checking ~S: " sym)
                                (if (and sym (fboundp sym))
                                    (handler-case
                                        (let ((ptr (funcall cb-fn (symbol-function sym))))
                                          (format t "pointer=~S~%" ptr))
                                      (error (e) (format t "get-callback error: ~S~%" e)))
                                    (format t "not fbound~%"))))))))))))
    (error (e) (format t "Error during check: ~S~%" e)))
  (sb-ext:quit))

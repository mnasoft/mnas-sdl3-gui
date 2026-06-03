(progn
  (ql:quickload :mnas-sdl3-gui)
  (format t "Searching all packages for symbols containing GRID-DEMO...~%")
  (do-all-symbols (s)
    (when (and (stringp (symbol-name s)) (search "GRID-DEMO" (symbol-name s)))
      (format t "~S  fboundp=~S function=~S~%" s (fboundp s) (handler-case (symbol-function s) (error (e) :no-fn)))))
  (sb-ext:quit))

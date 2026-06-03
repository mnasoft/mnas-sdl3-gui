(progn
  (ql:quickload :mnas-sdl3-gui)
  ;; Load package.lisp for the demo so the package exists for subsequent load
  (load "/home/mna/quicklisp/local-projects/sdl3/mnas-sdl3-gui/demos/layout/grid-01/package.lisp" :verbose t)
  ;; Now load the demo source file directly
  (load "/home/mna/quicklisp/local-projects/sdl3/mnas-sdl3-gui/demos/layout/grid-01/grid-01.lisp" :verbose t)
  ;; Run demo entry point (prints debug info)
  (mnas-sdl3-gui/demos/layout/grid-01:grid-01)
  (sb-ext:quit))

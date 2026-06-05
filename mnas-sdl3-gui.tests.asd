(asdf:defsystem #:mnas-sdl3-gui.tests
  :description "Tests for mnas-sdl3-gui"
  :author "mna"
  :license "GPL-3.0"
  :depends-on (#:mnas-sdl3-gui
               #:fiveam)
  :serial t
  :components ((:file "tests/package")
               (:file "tests/mnas-sdl3-gui-tests"))
  :perform (test-op (o c)
             (declare (ignore o c))
             (uiop:symbol-call :mnas-sdl3-gui/tests :run-tests)))

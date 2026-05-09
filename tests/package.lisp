;;;; ./tests/package.lisp

(defpackage #:mnas-sdl3-gui/tests
  (:use #:cl #:fiveam)
  (:import-from #:mnas-sdl3-gui
                #:project-name
                #:hello)
  (:export #:run-tests))

(in-package #:mnas-sdl3-gui/tests)

;;;; ./tests/package.lisp

(defpackage #:mnas-sdl3-gui/tests
  (:use #:cl #:fiveam)
  (:import-from #:mnas-sdl3-gui
                #:project-name
                #:hello)
  (:import-from #:mnas-sdl3-gui/window-manager
                #:make-window-layer-manager
                #:register-window
                #:active-modal-id
                #:modal-trap-active-p
                #:set-focused-window
                #:focused-window-id
                #:event-target-window-id
                #:keyboard-target-window-id
                #:close-window)
  (:export #:run-tests))

(in-package #:mnas-sdl3-gui/tests)

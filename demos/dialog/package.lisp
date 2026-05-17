;;;; ./demos/dialog/package.lisp

(defpackage :mnas-sdl3-gui/demos/dialog
  (:use #:cl)
  (:export #:do-entry-dialog-demo
           #:do-check-box-demo
           #:do-pack-layout-demo
           #:do-two-list-boxes-demo
           #:do-combo-box-demo
           #:do-editable-combo-box-demo))

(in-package :mnas-sdl3-gui/demos/dialog)

;;;; (ql:quickload :mnas-sdl3-gui/demos)

;;;; (do-entry-dialog-demo)
;;;; (do-check-box-demo)
;;;; (do-pack-layout-demo)
;;;; (do-two-list-boxes-demo)
;;;; (do-combo-box-demo)

(defun do-entry-dialog-demo (&optional (style :flat))
  "Run the entry demo dialog from the entry-01 package."
  (mnas-sdl3-gui/demos/dialog/entry-01:entry-01 style))


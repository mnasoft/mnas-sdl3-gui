;;;; ./demos/dialog/package.lisp

(defpackage :mnas-sdl3-gui/demos/dialog
  (:use #:cl)
  (:export #:do-dialog-demo
           #:do-edit-box-dialog-demo
           #:do-cyrillic-font-demo
           #:do-toggle-group-demo
           #:do-check-box-demo
           #:do-pack-layout-demo
           #:do-two-list-boxes-demo
           #:do-combo-box-demo))

(in-package :mnas-sdl3-gui/demos/dialog)

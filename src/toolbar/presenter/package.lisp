;;;; ./src/toolbar/presenter/package.lisp

(in-package :cl)

(defpackage :mnas-sdl3-gui/toolbar/presenter
  (:documentation "Toolbar rendering and interaction.")
  (:use :cl)
  (:export
   #:render-toolbar
   #:render-toolbar-button
   #:toolbar-layout-horizontal
   #:toolbar-layout-vertical
   #:toolbar-buttons-at-position
   #:toolbar-button-clicked
   #:toolbar-from-command-group))

(in-package :mnas-sdl3-gui/toolbar)

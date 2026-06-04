;;;; ./src/toolbar/package.lisp

(in-package :cl)

(defpackage :mnas-sdl3-gui/toolbar
  (:documentation "Toolbar/panel presenter for Command Model.
   Different representation of commands compared to menu.")
  (:use :cl)
  (:export
   ;; Classes
   #:toolbar
   #:toolbar-button-spec
   ;; Compatibility accessors
   #:toolbar-buttons
   ;; widgetized button class
   #:toolbar-button
   ;; Functions
   #:toolbar-layout-horizontal
   #:toolbar-layout-vertical
   #:render-toolbar
   #:toolbar-buttons-at-position
   #:toolbar-button-clicked
   #:handle-toolbar-mouse-event
   #:update-toolbar-command-state
   #:register-toolbar-for-command-updates
   #:unregister-toolbar-for-command-updates))

(in-package :mnas-sdl3-gui/toolbar)

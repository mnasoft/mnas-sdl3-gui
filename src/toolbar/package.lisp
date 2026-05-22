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
   ;; Toolbar accessors
   #:toolbar-buttons
   #:toolbar-width
   #:toolbar-height
   #:toolbar-layout
   #:toolbar-background
   #:toolbar-padding
   ;; Button spec accessors
   #:button-command-id
   #:button-type
   #:button-group
   #:button-label
   #:button-hotkey
   #:button-width
   #:button-height
   #:button-x
   #:button-y
   ;; Functions
   #:make-toolbar
   #:make-button-spec
   #:toolbar-layout-horizontal
   #:toolbar-layout-vertical
   #:render-toolbar
   #:toolbar-buttons-at-position
   #:toolbar-button-clicked
   #:update-toolbar-command-state
   #:register-toolbar-for-command-updates
   #:unregister-toolbar-for-command-updates))

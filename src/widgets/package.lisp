;;;; ./src/widgets/package.lisp

(defpackage :mnas-sdl3-gui/widgets
  (:nicknames :gui/widgets)
  (:use #:cl)
  (:export
   ;; base widget class
   #:widget
   #:widget-x
   #:widget-y
   #:widget-width
   #:widget-height
   #:widget-enabled
   #:widget-focused
   #:widget-visible
   #:widget-value
   #:widget-on-change
   ;; concrete widgets
   #:label
   #:button
   #:toggle
   #:check-box
   #:edit-box
   #:list-box
   ;; label accessors
   #:label-text
   ;; button accessors
   #:button-text
   #:button-on-click
   ;; toggle accessors
   #:toggle-state
   #:toggle-label
   ;; check-box accessors
   #:check-box-checked
   #:check-box-label
   ;; edit-box accessors
   #:edit-box-text
   #:edit-box-cursor
   #:edit-box-max-length
   ;; list-box accessors
   #:list-box-items
   #:list-box-selected-index
   #:list-box-item-height
   ;; rendering
   #:render-widget
   ;; event handling
   #:handle-widget-click
   #:handle-widget-mouse-motion
   #:handle-widget-key-press))

(in-package :mnas-sdl3-gui/widgets)

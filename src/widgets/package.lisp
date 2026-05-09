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
  ;; style classes and helpers
  #:widget-style
  #:flat-widget-style
  #:windows-widget-style
  #:motif-widget-style
  #:*widget-style*
  #:make-widget-style
  #:set-widget-style
  #:widget-style-name
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
  #:button-pressed-p
  #:button-armed-p
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
  #:render-text
   #:render-widget
   ;; TTF/font rendering
   #:render-text-with-ttf
   #:*ttf-available-p*
   #:*ttf-font*
   #:*ttf-font-path*
   #:*ttf-font-size*
   #:init-ttf-font
   #:cleanup-ttf
   ;; Cyrillic approximation
   #:approximate-cyrillic-text
   ;; event handling
   #:handle-widget-click
  #:handle-widget-mouse-down
  #:handle-widget-mouse-up
   #:handle-widget-mouse-motion
   #:handle-widget-key-press))

(in-package :mnas-sdl3-gui/widgets)

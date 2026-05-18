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
  #:widget-z-order
   #:widget-enabled
   #:widget-focused
   #:widget-visible
   #:widget-value
   #:widget-on-change
  #:widget-min-size
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
   #:entry
  #:password-entry
  #:integer-entry
  #:real-entry
  #:tree-node
  #:tree-view
   #:list-box
   #:combo-box
   #:editable-combo-box
   ;; label accessors
   #:label-text
   ;; button accessors
   #:button-text
  #:button-pressed-p
  #:button-armed-p
   #:button-on-click
   ;; toggle accessors
   #:toggle-state
  #:toggle-group
   #:toggle-label
   ;; check-box accessors
   #:check-box-checked
   #:check-box-label
   ;; entry accessors
   #:entry-text
   #:entry-cursor
  #:entry-scroll-offset
   #:entry-max-length
   #:entry-show
   #:entry-validate
   #:entry-selection-start
   #:entry-selection-end
  ;; tree-node accessors
  #:tree-node-id
  #:tree-node-text
  #:tree-node-kind
  #:tree-node-path
  #:tree-node-children-loaded-p
  #:tree-node-modified-time
  #:tree-node-children
  #:tree-node-expanded-p
  #:tree-node-data
  ;; tree-view accessors/helpers
  #:tree-view-roots
  #:tree-view-selected-node
  #:tree-view-root-path
  #:tree-view-show-hidden-p
  #:tree-view-filter-extensions
  #:tree-view-sort-mode
  #:tree-view-max-depth
  #:tree-view-row-height
  #:tree-view-indent-width
  #:make-tree-node
  #:tree-node-directory-p
  #:tree-node-file-p
  #:tree-node-children-sorted
  #:make-filesystem-tree-node
  #:tree-view-normalize-extensions
  #:build-filesystem-tree
  #:tree-view-load-node-children
  #:tree-view-expand-node
  #:tree-view-toggle-node-expanded
  #:tree-view-load-directory
   ;; entry selection and clipboard utilities
   #:clear-entry-selection
   #:get-entry-selected-text
   #:set-entry-selection
   #:entry-copy-to-clipboard
   #:entry-paste-from-clipboard
   #:entry-delete-selection
   #:entry-move-to-previous-word
   #:entry-move-to-next-word
  #:entry-ensure-cursor-visible
  #:entry-scroll-to-start
  #:entry-scroll-to-end
   ;; list-box accessors
   #:list-box-items
   #:list-box-selected-index
  #:list-box-scroll-offset
   #:list-box-item-height
  ;; combo-box accessors
  #:combo-box-expanded-p
  #:combo-box-max-visible-items
  #:combo-box-add-item
  ;; editable combo-box accessors
  #:editable-combo-box-placeholder
  ;; layout managers
  #:pack-widget
  #:unpack-widget
  #:clear-pack-layout
  #:pack-layout-required-size
  #:pack-layout-widgets
  #:place-widget
   ;; rendering
  #:render-text
   #:render-widget
    #:render-widgets
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
  #:dispatch-widget-mouse-down
  #:dispatch-widget-mouse-up
  #:dispatch-widget-mouse-motion
  #:dispatch-widget-mouse-wheel
   #:handle-widget-mouse-motion
  #:handle-widget-key-press
  #:handle-widget-key-event
  #:focusable-widget-p
  #:focused-widget
  #:focused-entry
  #:dispatch-focused-widget-key-event
  #:dispatch-focused-text-input
  #:dispatch-widget-keyboard-event
  #:tab-navigation-backward-p
  #:start-widget-text-input
  #:stop-widget-text-input
  #:set-widget-focus
  #:move-widget-focus
  #:activate-widget
  ;; toggle group helpers
  #:clear-toggle-group-registry))

(in-package :mnas-sdl3-gui/widgets)

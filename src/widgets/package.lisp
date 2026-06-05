;;;; ./src/widgets/package.lisp

(defpackage :mnas-sdl3-gui/widgets
  (:nicknames :gui/widgets)
  (:use #:cl)
  ;; base widget class
  (:export #:widget
           #:widget-x
           #:widget-y
           #:widget-width
           #:widget-height
           #:widget-z-order
           #:widget-enabled
           #:enabled-p
           #:widget-focused
           #:widget-visible
           #:visible-p
           #:widget-focusable
           #:widget-value
           #:widget-on-change
           #:widget-min-size
           #:widget-measure
           #:widget-arrange
           #:widget-hit-test
           #:widget-container
           #:scroll-container
           #:row-stack
           #:column-stack
           #:split-pane
           #:canvas-2d-widget
           #:widget-children
           #:children
           #:scroll-container-scroll-offset
           #:row-stack-spacing
           #:row-stack-padding
           #:column-stack-spacing
           #:column-stack-padding
           #:split-pane-orientation
           #:split-pane-ratio
           #:split-pane-divider-size
           #:split-pane-padding
           #:split-pane-min-first-pane
           #:split-pane-min-second-pane
           #:canvas-2d-widget-scene
           #:canvas-2d-widget-viewport-scale
           #:canvas-2d-widget-viewport-offset-x
           #:canvas-2d-widget-viewport-offset-y
           #:canvas-2d-widget-pan-enabled
           #:canvas-2d-widget-zoom-enabled
           #:canvas-2d-pan-by
           #:canvas-2d-zoom-by
           #:make-widget-container
           #:make-scroll-container
           #:make-row-stack
           #:make-column-stack
           #:make-split-pane
           #:make-canvas-2d-widget
           #:set-scene
           #:request-redraw
           #:world-to-screen
           #:screen-to-world
           #:handle-viewport-resize
           #:widget-add-child
           #:widget-remove-child
           #:widget-clear-children
           #:normalize-scroll-container-scroll-offset
           #:scroll-container-max-scroll-offset
           #:scroll-container-content-height
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
           ;; toolbar widgets
           #:toolbar
           #:toolbar-button
           ;; toolbar accessors
           #:toolbar-buttons
           #:toolbar-layout
           #:toolbar-padding
           #:toolbar-width
           #:toolbar-height
           #:toolbar-x
           #:toolbar-y
           ;; button accessors
           #:button-width
           #:button-height
           #:button-x
           #:button-y
           #:button-command-id
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
           #:tree-view-scroll-offset
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
           #:tree-view-visible-row-count
           #:tree-view-max-scroll-offset
           #:normalize-tree-view-scroll-offset
           #:ensure-tree-view-selection-visible
           )
  ;; entry selection and clipboard utilities
  (:export #:clear-entry-selection
           #:get-entry-selected-text
           #:set-entry-selection
           #:entry-copy-to-clipboard
           #:entry-paste-from-clipboard
           #:entry-delete-selection
           #:entry-move-to-previous-word
           #:entry-move-to-next-word
           #:entry-ensure-cursor-visible
           #:entry-scroll-to-start
           #:entry-scroll-to-end)
  ;; list-box accessors
  (:export #:list-box-items
           #:list-box-selected-index
           #:list-box-scroll-offset
           #:list-box-item-height)
  ;; combo-box accessors
  (:export #:combo-box-expanded-p
           #:combo-box-max-visible-items
           #:combo-box-visible-item-count
           #:combo-box-main-height
           #:combo-box-content-width
           #:combo-box-popup-mode
           #:combo-box-popup-host-window
           #:combo-box-popup-window
           #:combo-box-popup-renderer
           #:combo-box-popup-window-id
           #:combo-box-popup-visible-p
           #:combo-box-popup-layer-manager
           #:combo-box-popup-window-enabled-p
           #:combo-box-enable-popup-window
           #:combo-box-disable-popup-window
           #:combo-box-handle-popup-mouse-down
           #:combo-box-handle-popup-mouse-up
           #:combo-box-handle-popup-mouse-motion
           #:combo-box-handle-popup-mouse-wheel
           #:update-widget-value
           #:sync-combo-box-expanded-state
           #:*combo-box-expanded-callback*
           #:combo-box-add-item)
  ;; editable combo-box accessors
  (:export #:editable-combo-box-placeholder)
  ;; layout managers
  (:export #:pack-widget
           #:unpack-widget
           #:clear-pack-layout
           #:pack-layout-required-size
           #:pack-layout-widgets
           #:place-widget
           )
  ;; grid layout  
  (:export #:grid-container
           #:widgets-in-render-order
           #:make-grid
           #:grid-add-child
           #:grid-rows
           #:grid-cols
           #:grid-child-constraints
           #:grid-row-spacing
           #:grid-col-spacing
           #:grid-padding
           )
  ;; rendering
  (:export #:render
           #:render-text
           )
  ;; TTF/font rendering
  (:export #:render-text-with-ttf
           #:*ttf-available-p*
           #:*ttf-font*
           #:*ttf-font-path*
           #:*ttf-font-size*
           #:init-ttf-font
           #:cleanup-ttf
           )
  ;; Cyrillic approximation
  (:export           
   #:approximate-cyrillic-text
   )
  ;; event handling
  (:export #:handle-widget-click
           #+nil #:handle-widget-mouse-down
           #+nil #:handle-widget-mouse-up
           #:handle-mouse-button-event
           #:handle-mouse-wheel-event
           #:handle-mouse-motion-event
           #:handle-mouse-device-event
           #:handle-widget-mouse-wheel
           #:handle-widget-mouse-motion
           #:widgets-for-window-id
           #:register-widget-for-window-id
           #:unregister-widget-for-window-id
           #:widgets-for-window
           #:register-widgets-for-window
           #:unregister-widgets-for-window
           #:clear-window-widget-registry
           #:destroy-window-and-unregister
           #:handle-widget-key-press
           #:handle-widget-key-event
           #:focusable-widget-p
           #:focused-widget
           #:focused-entry
           #:dispatch-focused-widget-key-event
           #:dispatch-focused-text-input
           #:tab-navigation-backward-p
           #:start-widget-text-input
           #:stop-widget-text-input
           #:set-widget-focus
           #:move-widget-focus
           #:activate-widget
           ;; toggle group helpers
           #:clear-toggle-group-registry))

(in-package :mnas-sdl3-gui/widgets)

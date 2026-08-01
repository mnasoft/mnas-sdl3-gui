;;;; ./src/widgets/package.lisp

(defpackage :mnas-sdl3-gui/widgets
  (:nicknames :gui/widgets)
  (:use #:cl)
;;; base widget class
  (:export #:<widget>
           #:toolbar
           #:toolbar-button
           #:button
           #:toggle
           #:check-box
           #:entry
           #:list-box
           #:combo-box
           #:editable-combo-box
           #:label
           #:tree-view
           #:<widget>-x
           #:<widget>-y
           #:<widget>-width
           #:<widget>-height
           #:<widget>-z-order
           #:<widget>-padding
           #:<widget>-border-width
           #:<widget>-margin
           #:widget-content-box
           #:<widget>-enabled
           #:enabled-p
           #:<widget>-focused
           #:<widget>-visible
           #:visible-p
           #:<widget>-focusable
           #:<widget>-value
           #:<widget>-on-change
           #:widget-min-size
           #:widget-measure
           #:widget-arrange
           #:widget-hit-test

           #:canvas-2d-widget)
  (:export #:<widget-container>
           #:<widget-container>-children
           #:children)
;;; scroll-container
  (:export #:<scroll-container>
           #:<scroll-container>-scroll-offset
           #:<scroll-container>-max-scroll-offset
           #:<scroll-container>-content-height
           )
  (:export #:<row-stack>
           #:<column-stack>)
  (:export #:<split-pane>
           #:<split-pane>-orientation
           #:<split-pane>-ratio
           #:<split-pane>-divider-size
           #:<split-pane>-padding
           #:<split-pane>-min-first-pane
           #:<split-pane>-min-second-pane)
  (:export #:canvas-2d-widget-scene
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

;;; style classes and helpers
           #:<widget-style>
           #:<flat-widget-style>
           #:<windows-widget-style>
           #:<motif-widget-style>
           #:*widget-style*
           #:make-widget-style
           #:set-widget-style
           #:<widget-style>-name
;;; concrete widgets
           :<label>
           :<list-box-item>
           :<button>
           :<toggle>
           :<check-box>
           :<entry>
           :<password-entry>
           :<integer-entry>
           :<real-entry>
           :<tree-node>
           :<tree-view>
           :<list-box>
           :<combo-box>
           :<combo-box-header>
           :<combo-box-popup>
           :<editable-combo-box>)
;;; toolbar widgets  
  (:export #:<toolbar>
           #:<toolbar-button>
;;; toolbar accessors
           #:toolbar-layout
           #:<toolbar>-padding
           #:toolbar-width
           #:toolbar-height
           #:toolbar-x
           #:toolbar-y
           #:<toolbar-button>-command-id
           #:<toolbar-button>-checked-p
           #:<toolbar-button>-label
           #:<toolbar-button>-hotkey)
;;; button accessors
    (:export
           #:button-width
           #:button-height
           #:button-x
           #:button-y

;;; <label> accessors
           #:<label>-text
           #:<list-box-item>-text
;;; button accessors
           #:<button>-text
           #:<button>-pressed-p
           #:<button>-armed-p
           #:<button>-on-click
;;; <toggle> accessors
           #:<toggle>-state
           #:<toggle>-group
           #:<toggle>-label
;;; <check-box> accessors
           #:<check-box>-checked
           #:<check-box>-label
;;; <entry> accessors
           #:<entry>-text
           #:<entry>-cursor
           #:<entry>-scroll-offset
           #:<entry>-max-length
           #:<entry>-show
           #:<entry>-validate
           #:<entry>-selection-start
           #:<entry>-selection-end
;;; <tree-node> accessors
           #:<tree-node>-id
           #:<tree-node>-text
           #:<tree-node>-kind
           #:<tree-node>-path
           #:<tree-node>-children-loaded-p
           #:<tree-node>-modified-time
           #:<tree-node>-children
           #:<tree-node>-expanded-p
           #:<tree-node>-data
;;; <tree-view> accessors/helpers
           #:<tree-view>-roots
           #:<tree-view>-selected-node
           #:<tree-view>-root-path
           #:<tree-view>-show-hidden-p
           #:<tree-view>-filter-extensions
           #:<tree-view>-sort-mode
           #:<tree-view>-max-depth
           #:<tree-view>-scroll-offset
           #:<tree-view>-row-height
           #:<tree-view>-indent-width
           #:make-tree-node
           #:<tree-node>-directory-p
           #:<tree-node>-file-p
           #:<tree-node>-children-sorted
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
;;; <entry> selection and clipboard utilities
  (:export #:clear-<entry>-selection
           #:get-<entry>-selected-text
           #:set-<entry>-selection
           #:<entry>-copy-to-clipboard
           #:<entry>-paste-from-clipboard
           #:<entry>-delete-selection
           #:<entry>-move-to-previous-word
           #:<entry>-move-to-next-word
           #:<entry>-ensure-cursor-visible
           #:<entry>-scroll-to-start
           #:<entry>-scroll-to-end)
;;; list-box accessors
  (:export #:list-box-items
           #:selected-index
           #:check-box-checked
           #:entry-text
           #:entry-cursor
           #:label-text
           #:tree-node-path
           #:tree-node-text
           #:tree-node-children
           #:tree-node-kind
           #:scroll-offset
           #:scrollbar-drag-offset
           #:item-height
           #:list-box-scroll-offset
           #:list-box-layout
           #:list-box-has-scrollbar)
;;; combo-box accessors
  (:export #:expanded-p
           #:max-visible-items
           #:ignore-next-popup-mouse-down-p
           #:combo-box-visible-item-count
           #:main-height
           #:combo-box-content-width
;;; header/popup accessors
           #:header-widget
           #:popup-widget
           :<combo-box-header>-display-text
;;; popup compatibility/accessors
           :<combo-box-popup>-mode
           #:host-window
           #:scrollbar-geometry
           #:scroll-offset-from-thumb-top
           :<combo-box-popup>-window
           #:popup-renderer
           :<combo-box-popup>-window-id
           #:popup-visible-p
           #:selected-item
           #:combo-box-popup-host-window
           :<combo-box-popup>-layer-manager
           :<combo-box-popup>-window-enabled-p
           #:enable-popup-window
           #:disable-popup-window
           #:show-popup-window
           #:hide-popup-window
           #:handle-popup-mouse-down
           #:handle-popup-mouse-up
           #:handle-popup-mouse-motion
           #:handle-popup-mouse-wheel
           #:update-<widget>-value
           #:sync-combo-box-expanded-state
           #:*combo-box-expanded-callback*
           #:combo-box-add-item)
;;; editable combo-box accessors
  (:export #:<editable-combo-box>-placeholder)
;;; layout managers
  (:export #:pack-widget
           #:unpack-widget
           #:clear-pack-layout
           #:pack-layout-required-size
           #:pack-layout-widgets
           #:place-widget
           )
;;; grid layout  
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
;;; rendering
  (:export #:render
           #:render-text
           #:render-toolbar
           #:toolbar-buttons-at-position
           #:toolbar-button-clicked
           #:update-toolbar-command-state
           #:register-toolbar-for-command-updates)
;;; TTF/font rendering
  (:export #:render-text-with-ttf
           #:*ttf-available-p*
           #:*ttf-font*
           #:*ttf-font-path*
           #:*ttf-font-size*
           #:init-ttf-font
           #:cleanup-ttf
           )
;;; Cyrillic approximation
  (:export #:approximate-cyrillic-text
           )
;;; event handling
  (:export #:handle-widget-click
           #:handle-mouse-button-event
           #:handle-mouse-wheel-event
           #:handle-mouse-motion-event
           #:handle-mouse-device-event
           #:widgets-for-window-id
           #:register-widget-for-window-id
           #:unregister-widget-for-window-id
           #:widgets-for-window
           #:register-widgets-for-window
           #:unregister-widgets-for-window
           #:clear-window-widget-registry
           #:destroy-window-and-unregister
           #:handle-keyboard-event
           #:handle-text-input-event
           #:make-widget-keyboard-input
           #:focusable-p
           #:focused
           #:focused
           #:tab-navigation-backward-p
           #:start-widget-text-input
           #:stop-widget-text-input
           #:set-widget-focus
           #:move-widget-focus
           #:activate-widget
;;; <toggle> group helpers
           #:clear-toggle-group-registry))

(in-package :mnas-sdl3-gui/widgets)

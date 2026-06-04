;;;; ./src/widgets/classes.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Widget classes

(defclass widget ()
  ((x
    :initarg :x :initform 0 :accessor widget-x
    :documentation "X coordinate of widget")
   (y
    :initarg :y :initform 0 :accessor widget-y
    :documentation "Y coordinate of widget")
   (width
    :initarg :width :initform 100 :accessor widget-width
    :documentation "Width of widget")
   (height
    :initarg :height :initform 30 :accessor widget-height
    :documentation "Height of widget")
   (window
    :initarg :window :initform nil :accessor widget-window
    :documentation "SDL window object or integer id associated with this widget")
   (z-order
    :initarg :z-order :initform 0 :accessor widget-z-order
    :documentation "Relative drawing order; higher values are rendered above lower ones")
   (enabled
    :initarg :enabled :initform t :accessor widget-enabled
    :documentation "Whether widget is enabled for interaction")
   (focused
    :initarg :focused :initform nil :accessor widget-focused
    :documentation "Whether widget has keyboard focus")
   (visible
    :initarg :visible :initform t :accessor widget-visible
    :documentation "Whether widget is visible")
   (focusable
    :initarg :focusable :initform t :accessor widget-focusable
    :documentation "Whether widget can receive keyboard focus.")
   (value
    :initarg :value :initform nil :accessor widget-value
    :documentation "Current value of widget")
   (on-change
    :initarg :on-change :initform nil :accessor widget-on-change
    :documentation "Callback function called when value changes"))
  (:documentation "Base class for all widgets"))

(defclass widget-container (widget)
  ((children :initarg :children :initform nil :accessor widget-children
             :documentation "Child widgets contained by this container."))
  (:documentation "Widget that groups child widgets and delegates rendering/events."))

(defclass scroll-container (widget-container)
  ((scroll-offset
    :initarg :scroll-offset :initform 0 :accessor scroll-container-scroll-offset
    :documentation "Vertical scroll offset for child content.")
   (auto-hide-scrollbar
    :initarg :auto-hide-scrollbar :initform t :accessor scroll-container-auto-hide-scrollbar
    :documentation "Hide scroll bar when content fits inside the container."))
  (:documentation "Scrollable container widget for vertically stacked child widgets."))

(defclass row-stack (widget-container)
  ((spacing
    :initarg :spacing :initform 4 :accessor row-stack-spacing
    :documentation "Horizontal spacing between child widgets.")
   (padding
    :initarg :padding :initform 4 :accessor row-stack-padding
    :documentation "Padding inside the row stack bounds."))
  (:documentation "Container widget that arranges children in a horizontal row."))

(defclass column-stack (widget-container)
  ((spacing :initarg :spacing :initform 4 :accessor column-stack-spacing
            :documentation "Vertical spacing between child widgets.")
   (padding :initarg :padding :initform 4 :accessor column-stack-padding
            :documentation "Padding inside the column stack bounds."))
  (:documentation "Container widget that arranges children in a vertical column."))

(defclass split-pane (widget-container)
  ((orientation
    :initarg :orientation :initform :horizontal
    :accessor split-pane-orientation
    :documentation "Split orientation: :horizontal for left/right, :vertical for top/bottom.")
   (split-ratio
    :initarg :split-ratio :initform 0.5 :accessor split-pane-ratio
    :documentation "Fraction of available space assigned to the first pane.")
   (divider-size
    :initarg :divider-size :initform 4 :accessor split-pane-divider-size
    :documentation "Thickness of the split divider in pixels.")
   (padding
    :initarg :padding :initform 8 :accessor split-pane-padding
    :documentation "Padding around the split-pane contents.")
   (min-first-pane
    :initarg :min-first-pane :initform 32 :accessor split-pane-min-first-pane
    :documentation "Minimum size of the first pane along the split axis.")
   (min-second-pane
    :initarg :min-second-pane :initform 32 :accessor split-pane-min-second-pane
    :documentation "Minimum size of the second pane along the split axis."))
  (:documentation "Container widget that divides available area into two panes with a movable split ratio."))

(defclass canvas-2d-widget (widget)
  ((scene
    :initarg :scene :initform nil :accessor canvas-2d-widget-scene
    :documentation "Scene model for 2D canvas rendering.")
   (viewport-scale
    :initarg :viewport-scale :initform 1.0 :accessor canvas-2d-widget-viewport-scale
    :documentation "Zoom scale for the 2D viewport.")
   (viewport-offset-x
    :initarg :viewport-offset-x :initform 0 :accessor canvas-2d-widget-viewport-offset-x
    :documentation "Horizontal viewport offset in pixels.")
   (viewport-offset-y
    :initarg :viewport-offset-y :initform 0 :accessor canvas-2d-widget-viewport-offset-y
    :documentation "Vertical viewport offset in pixels.")
   (redraw-requested
    :initarg :redraw-requested :initform nil :accessor canvas-2d-widget-redraw-requested
    :documentation "Flag requesting redraw on next frame.")
   (pan-enabled
    :initarg :pan-enabled :initform t :accessor canvas-2d-widget-pan-enabled
    :documentation "Enable panning for the canvas viewport.")
   (zoom-enabled
    :initarg :zoom-enabled :initform t :accessor canvas-2d-widget-zoom-enabled
    :documentation "Enable zooming for the canvas viewport."))
  (:documentation "Canvas widget specialized for 2D scene rendering and interaction."))

(defclass label (widget)
  ((text
    :initarg :text :initform "" :accessor label-text
    :documentation "Text content of label"))
  (:documentation "Simple text label widget"))

;;; Toolbar widgets moved here so they integrate with widget hierarchy.
(defclass toolbar-button (widget)
  ((command-id :initarg :command-id :accessor button-command-id)
   (type :initarg :type :initform :push :accessor button-type)
   (group :initarg :group :initform nil :accessor button-group)
   (label :initarg :label :initform "" :accessor button-label)
   (hotkey :initarg :hotkey :initform "" :accessor button-hotkey))

  (:documentation "Toolbar button implemented as a widget so it can be a child of toolbar."))

(defclass toolbar (widget-container)
  ((buttons :initarg :buttons :initform '() :accessor toolbar-buttons
            :documentation "Deprecated: use children slot directly. Kept for compatibility.")
   (layout :initarg :layout :initform :horizontal :accessor toolbar-layout
           :documentation "Layout mode: :horizontal or :vertical.")
   (background :initarg :background :initform '(245 245 245 255)
               :accessor toolbar-background)
   (padding :initarg :padding :initform 6 :accessor toolbar-padding))
  (:documentation "Toolbar container implemented as a widget-container; buttons are its children."))

(defclass button (widget)
  ((text
    :initarg :text :initform "Button" :accessor button-text
    :documentation "Button label text")
   (pressed
    :initarg :pressed :initform nil :accessor button-pressed-p
    :documentation "Whether button is currently shown as pressed")
   (armed
    :initarg :armed :initform nil :accessor button-armed-p
    :documentation "Whether mouse press started on this button")
   (on-click
    :initarg :on-click :initform nil :accessor button-on-click
    :documentation "Callback function called on button click"))
  (:documentation "Clickable button widget"))

(defclass toggle (widget)
  ((state
    :initarg :state :initform nil :accessor toggle-state
    :documentation "Current toggle state (selected or NIL)")
   (group
    :initarg :group :initform nil :accessor toggle-group
    :documentation "Group identifier for mutually exclusive toggles")
   (label
    :initarg :label :initform "Toggle" :accessor toggle-label
    :documentation "Label for toggle"))
  (:documentation "Radio-style toggle widget (single selection per group)"))

(defclass check-box (widget)
  ((checked :initarg :checked :initform nil :accessor check-box-checked
            :documentation "Whether checkbox is checked")
   (label :initarg :label :initform "Check" :accessor check-box-label
          :documentation "Label for checkbox"))
  (:documentation "Checkbox widget"))

(defclass entry (widget)
  ((text
    :initarg :text :initform "" :accessor entry-text
    :documentation "Text content of entry")
   (cursor
    :initarg :cursor :initform 0 :accessor entry-cursor
    :documentation "Cursor position in text")
   (scroll-offset
    :initarg :scroll-offset :initform 0 :accessor entry-scroll-offset
    :documentation "Character offset of the first visible glyph")
   (selection-start
    :initarg :selection-start :initform nil :accessor entry-selection-start
    :documentation "Start of text selection (NIL if no selection)")
   (selection-end
    :initarg :selection-end :initform nil :accessor entry-selection-end
    :documentation "End of text selection (NIL if no selection)")
   (max-length
    :initarg :max-length :initform 256 :accessor entry-max-length
    :documentation "Maximum length of text")
   (show
    :initarg :show :initform nil :accessor entry-show
    :documentation "Mask character or string used to display entry text.")
   (validate
    :initarg :validate :initform nil :accessor entry-validate
    :documentation "Optional validation function NEW-TEXT -> non-NIL.")
   )
  (:documentation "Text input box widget"))

(defclass password-entry (entry)
  ()
  (:default-initargs :show #\*)
  (:documentation "Entry widget specialized for password input with masked display."))

(defclass integer-entry (entry)
  ()
  (:documentation "Entry widget specialized for integer input."))

(defclass real-entry (entry)
  ()
  (:documentation "Entry widget specialized for real number input."))

(defclass tree-node ()
  ((id
    :initarg :id :initform nil :accessor tree-node-id
    :documentation "Optional node identifier.")
   (text
    :initarg :text :initform "" :accessor tree-node-text
    :documentation "Display label for the node.")
   (kind
    :initarg :kind :initform :item :accessor tree-node-kind
    :documentation "Node kind keyword, e.g. :directory or :file.")
   (path :initarg :path :initform nil :accessor tree-node-path
         :documentation "Optional filesystem path associated with node.")
   (children-loaded-p
    :initarg :children-loaded-p :initform nil :accessor tree-node-children-loaded-p
    :documentation "Whether children are already loaded for this node.")
   (modified-time
    :initarg :modified-time :initform nil :accessor tree-node-modified-time
    :documentation "Optional filesystem write timestamp.")
   (children
    :initarg :children :initform nil :accessor tree-node-children
    :documentation "Child nodes list.")
   (expanded-p
    :initarg :expanded-p :initform nil :accessor tree-node-expanded-p
    :documentation "Whether children are visible.")
   (data
    :initarg :data :initform nil :accessor tree-node-data
    :documentation "Optional user payload for the node."))
  (:documentation "Node model used by tree-view widget."))

(defclass tree-view (widget)
  ((roots :initarg :roots :initform nil :accessor tree-view-roots
          :documentation "Top-level tree-node list.")
   (selected-node :initarg :selected-node :initform nil :accessor tree-view-selected-node
                  :documentation "Currently selected node object.")
   (root-path :initarg :root-path :initform nil :accessor tree-view-root-path
              :documentation "Filesystem root path used to build tree roots.")
   (show-hidden-p :initarg :show-hidden-p :initform nil :accessor tree-view-show-hidden-p
                  :documentation "Whether to show hidden filesystem entries.")
  (filter-extensions :initarg :filter-extensions :initform nil :accessor tree-view-filter-extensions
               :documentation "List of allowed file extensions (e.g. '(\"lisp\" \"asd\")); NIL means all.")
  (sort-mode :initarg :sort-mode :initform :name :accessor tree-view-sort-mode
          :documentation "Filesystem sort mode: :name, :type, or :date.")
  (max-depth :initarg :max-depth :initform nil :accessor tree-view-max-depth
          :documentation "Optional depth limit for filesystem tree expansion.")
     (scroll-offset :initarg :scroll-offset :initform 0 :accessor tree-view-scroll-offset
        :documentation "Index of the first visible tree row.")
   (row-height :initarg :row-height :initform 22 :accessor tree-view-row-height
               :documentation "Single visible row height in pixels.")
   (indent-width :initarg :indent-width :initform 16 :accessor tree-view-indent-width
                 :documentation "Indent width per depth level."))
  (:documentation "Tree widget with expandable/collapsible nodes."))

(defclass list-box (widget)
  ((items :initarg :items :initform nil :accessor list-box-items
          :documentation "List of items in the box")
   (selected-index
    :initarg :selected-index :initform 0 :accessor list-box-selected-index
    :documentation "Index of currently selected item")
   (scroll-offset
    :initarg :scroll-offset :initform 0 :accessor list-box-scroll-offset
    :documentation "Index of the first visible item")
   (scrollbar-dragging-p
    :initarg :scrollbar-dragging-p :initform nil
    :accessor list-box-scrollbar-dragging-p
    :documentation "Whether the list-box scrollbar thumb is currently dragged")
   (scrollbar-drag-offset
    :initarg :scrollbar-drag-offset :initform 0
    :accessor list-box-scrollbar-drag-offset
    :documentation "Mouse Y offset inside the dragged scrollbar thumb")
   (item-height
    :initarg :item-height :initform 24 :accessor list-box-item-height
    :documentation "Height of each item"))
  (:documentation "Scrollable list box widget"))

(defclass combo-box (list-box)
  ((main-height
    :initarg :main-height :initform 30 :accessor combo-box-main-height
    :documentation "Collapsed header height of the combo-box")
   (expanded-p
    :initarg :expanded-p :initform nil :accessor combo-box-expanded-p
    :documentation "Whether combo-box popup list is currently visible")
   (max-visible-items
    :initarg :max-visible-items :initform 6 :accessor combo-box-max-visible-items
    :documentation "Maximum number of visible rows in the popup list")
   (popup-mode
    :initarg :popup-mode :initform :inline :accessor combo-box-popup-mode
    :documentation "Popup mode: :inline renders in-window, :window uses a transient popup window.")
   (popup-host-window
    :initarg :popup-host-window :initform nil
    :accessor combo-box-popup-host-window
    :documentation "SDL host window for popup when popup-mode is :window.")
   (popup-window
    :initarg :popup-window :initform nil :accessor combo-box-popup-window
    :documentation "SDL popup window for dropdown list (when popup-mode is :window).")
   (popup-renderer
    :initarg :popup-renderer :initform nil :accessor combo-box-popup-renderer
    :documentation "SDL renderer for popup window (when popup-mode is :window).")
   (popup-window-id
    :initarg :popup-window-id :initform 0 :accessor combo-box-popup-window-id
    :documentation "SDL window id for popup window (when popup-mode is :window).")
   (popup-visible-p
    :initarg :popup-visible-p :initform nil :accessor combo-box-popup-visible-p
    :documentation "Whether popup window is currently shown.")
   (popup-layer-manager :initarg :popup-layer-manager :initform nil
                        :accessor combo-box-popup-layer-manager
                        :documentation "Optional window-layer-manager for popup focus/z-order."))
  (:documentation "Drop-down selection widget backed by a popup list."))

  (defclass combo-box-popup (widget)
    ((owner :initarg :owner :accessor combo-box-popup-owner
      :documentation "Owner combo-box widget for this popup proxy."))
    (:documentation "Transient proxy widget representing a combo-box popup window in render order."))

(defclass editable-combo-box (entry combo-box)
  ((placeholder :initarg :placeholder :initform ""
                :accessor editable-combo-box-placeholder
                :documentation "Placeholder text shown when the input is empty."))
  (:documentation "Editable combo-box with inline text entry and drop-down item selection."))

;;; Rendering style classes

(defclass widget-style ()
  ()
  (:documentation "Base rendering style for widgets."))

(defclass flat-widget-style (widget-style)
  ()
  (:documentation "Flat widget rendering style."))

(defclass windows-widget-style (widget-style)
  ()
  (:documentation "Windows-like beveled widget rendering style."))

(defclass motif-widget-style (widget-style)
  ()
  (:documentation "Motif-like beveled widget rendering style."))

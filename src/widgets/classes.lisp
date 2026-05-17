;;;; ./src/widgets/classes.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Widget classes

(defclass widget ()
  ((x :initarg :x :initform 0 :accessor widget-x
      :documentation "X coordinate of widget")
   (y :initarg :y :initform 0 :accessor widget-y
      :documentation "Y coordinate of widget")
   (width :initarg :width :initform 100 :accessor widget-width
          :documentation "Width of widget")
   (height :initarg :height :initform 30 :accessor widget-height
           :documentation "Height of widget")
     (z-order :initarg :z-order :initform 0 :accessor widget-z-order
        :documentation "Relative drawing order; higher values are rendered above lower ones")
   (enabled :initarg :enabled :initform t :accessor widget-enabled
            :documentation "Whether widget is enabled for interaction")
   (focused :initarg :focused :initform nil :accessor widget-focused
            :documentation "Whether widget has keyboard focus")
   (visible :initarg :visible :initform t :accessor widget-visible
            :documentation "Whether widget is visible")
   (value :initarg :value :initform nil :accessor widget-value
          :documentation "Current value of widget")
   (on-change :initarg :on-change :initform nil :accessor widget-on-change
              :documentation "Callback function called when value changes"))
  (:documentation "Base class for all widgets"))

(defclass label (widget)
  ((text :initarg :text :initform "" :accessor label-text
         :documentation "Text content of label"))
  (:documentation "Simple text label widget"))

(defclass button (widget)
  ((text :initarg :text :initform "Button" :accessor button-text
         :documentation "Button label text")
   (pressed :initarg :pressed :initform nil :accessor button-pressed-p
            :documentation "Whether button is currently shown as pressed")
   (armed :initarg :armed :initform nil :accessor button-armed-p
          :documentation "Whether mouse press started on this button")
   (on-click :initarg :on-click :initform nil :accessor button-on-click
             :documentation "Callback function called on button click"))
  (:documentation "Clickable button widget"))

(defclass toggle (widget)
  ((state :initarg :state :initform nil :accessor toggle-state
          :documentation "Current toggle state (selected or NIL)")
   (group :initarg :group :initform nil :accessor toggle-group
          :documentation "Group identifier for mutually exclusive toggles")
   (label :initarg :label :initform "Toggle" :accessor toggle-label
          :documentation "Label for toggle"))
  (:documentation "Radio-style toggle widget (single selection per group)"))

(defclass check-box (widget)
  ((checked :initarg :checked :initform nil :accessor check-box-checked
            :documentation "Whether checkbox is checked")
   (label :initarg :label :initform "Check" :accessor check-box-label
          :documentation "Label for checkbox"))
  (:documentation "Checkbox widget"))

(defclass entry (widget)
  ((text :initarg :text :initform "" :accessor entry-text
         :documentation "Text content of entry")
   (cursor :initarg :cursor :initform 0 :accessor entry-cursor
           :documentation "Cursor position in text")
   (scroll-offset :initarg :scroll-offset :initform 0 :accessor entry-scroll-offset
                  :documentation "Character offset of the first visible glyph")
   (selection-start :initarg :selection-start :initform nil :accessor entry-selection-start
                    :documentation "Start of text selection (NIL if no selection)")
   (selection-end :initarg :selection-end :initform nil :accessor entry-selection-end
                  :documentation "End of text selection (NIL if no selection)")
   (max-length :initarg :max-length :initform 256 :accessor entry-max-length
               :documentation "Maximum length of text")
   (show :initarg :show :initform nil :accessor entry-show
         :documentation "Mask character or string used to display entry text.")
   (validate :initarg :validate :initform nil :accessor entry-validate
             :documentation "Optional validation function NEW-TEXT -> non-NIL.")
   )
  (:documentation "Text input box widget"))

(defclass list-box (widget)
  ((items :initarg :items :initform nil :accessor list-box-items
          :documentation "List of items in the box")
   (selected-index :initarg :selected-index :initform 0 :accessor list-box-selected-index
                   :documentation "Index of currently selected item")
   (scroll-offset :initarg :scroll-offset :initform 0 :accessor list-box-scroll-offset
                  :documentation "Index of the first visible item")
   (scrollbar-dragging-p :initarg :scrollbar-dragging-p :initform nil
                         :accessor list-box-scrollbar-dragging-p
                         :documentation "Whether the list-box scrollbar thumb is currently dragged")
   (scrollbar-drag-offset :initarg :scrollbar-drag-offset :initform 0
                          :accessor list-box-scrollbar-drag-offset
                          :documentation "Mouse Y offset inside the dragged scrollbar thumb")
   (item-height :initarg :item-height :initform 24 :accessor list-box-item-height
                :documentation "Height of each item"))
  (:documentation "Scrollable list box widget"))

(defclass combo-box (list-box)
  ((main-height :initarg :main-height :initform 30 :accessor combo-box-main-height
                :documentation "Collapsed header height of the combo-box")
   (expanded-p :initarg :expanded-p :initform nil :accessor combo-box-expanded-p
               :documentation "Whether combo-box popup list is currently visible")
   (max-visible-items :initarg :max-visible-items :initform 6 :accessor combo-box-max-visible-items
                      :documentation "Maximum number of visible rows in the popup list"))
  (:documentation "Drop-down selection widget backed by a popup list."))

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
;;;; ./src/widgets/base.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Base Widget Class

(defclass widget ()
  ((x :initarg :x :initform 0 :accessor widget-x
      :documentation "X coordinate of widget")
   (y :initarg :y :initform 0 :accessor widget-y
      :documentation "Y coordinate of widget")
   (width :initarg :width :initform 100 :accessor widget-width
          :documentation "Width of widget")
   (height :initarg :height :initform 30 :accessor widget-height
           :documentation "Height of widget")
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

;;; Concrete Widget Classes

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
          :documentation "Current toggle state (T or NIL)")
   (label :initarg :label :initform "Toggle" :accessor toggle-label
          :documentation "Label for toggle"))
  (:documentation "Toggle switch widget (on/off)"))

(defclass check-box (widget)
  ((checked :initarg :checked :initform nil :accessor check-box-checked
            :documentation "Whether checkbox is checked")
   (label :initarg :label :initform "Check" :accessor check-box-label
          :documentation "Label for checkbox"))
  (:documentation "Checkbox widget"))

(defclass edit-box (widget)
  ((text :initarg :text :initform "" :accessor edit-box-text
         :documentation "Text content of edit box")
   (cursor :initarg :cursor :initform 0 :accessor edit-box-cursor
           :documentation "Cursor position in text")
   (max-length :initarg :max-length :initform 256 :accessor edit-box-max-length
               :documentation "Maximum length of text"))
  (:documentation "Text input box widget"))

(defclass list-box (widget)
  ((items :initarg :items :initform nil :accessor list-box-items
          :documentation "List of items in the box")
   (selected-index :initarg :selected-index :initform 0 :accessor list-box-selected-index
                   :documentation "Index of currently selected item")
   (item-height :initarg :item-height :initform 24 :accessor list-box-item-height
                :documentation "Height of each item"))
  (:documentation "Scrollable list box widget"))

;;; Widget Utilities

(defun contains-point-p (widget x y)
  "Check if point (x, y) is inside widget bounds."
  (and (<= (widget-x widget) x (+ (widget-x widget) (widget-width widget)))
       (<= (widget-y widget) y (+ (widget-y widget) (widget-height widget)))))

(defun update-widget-value (widget new-value)
  "Update widget value and trigger on-change callback if defined."
  (unless (eql (widget-value widget) new-value)
    (setf (widget-value widget) new-value)
    (when (widget-on-change widget)
      (funcall (widget-on-change widget) widget new-value))))

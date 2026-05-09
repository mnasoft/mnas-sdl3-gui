;;;; ./src/widgets/base.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Base Widget Class

;; Declared here to keep compilation of this module warning-free before
;; SDL3_ttf initialization module sets the runtime values.
(defvar *ttf-available-p* nil)
(defvar *ttf-font* nil)

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

(defparameter +layout-font-char-width+ 8)
(defparameter +layout-font-text-height+ 16)

(defun widget-text-pixel-size (text)
  "Return TEXT width and height using SDL3_ttf metrics when available."
  (if (and (boundp '*ttf-available-p*)
           (boundp '*ttf-font*)
           *ttf-available-p*
           *ttf-font*)
      (handler-case
          (multiple-value-bind (w h)
              (sdl3-ttf:ttf-get-string-size *ttf-font* text)
            (values (or w 0) (or h +layout-font-text-height+)))
        (error ()
          (values (* (length text) +layout-font-char-width+)
                  +layout-font-text-height+)))
      (values (* (length text) +layout-font-char-width+)
              +layout-font-text-height+)))

(defgeneric widget-min-size (widget)
  (:documentation "Return minimal width and height for WIDGET as two values."))

(defmethod widget-min-size ((widget widget))
  (values (max 1 (widget-width widget))
          (max 1 (widget-height widget))))

(defmethod widget-min-size ((widget label))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (label-text widget))
    (values (max 24 (+ tw 8))
            (max 20 (+ th 6)))))

(defmethod widget-min-size ((widget button))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (button-text widget))
    (values (max 64 (+ tw 24))
            (max 28 (+ th 12)))))

(defmethod widget-min-size ((widget toggle))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (toggle-label widget))
    (declare (ignore th))
    ;; Radio glyph width (40) + spacing (9) + label text.
    (values (max 80 (+ 40 9 tw))
            24)))

(defmethod widget-min-size ((widget check-box))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (check-box-label widget))
    (values (max 72 (+ 16 4 tw))
            (max 22 (+ th 6)))))

(defmethod widget-min-size ((widget edit-box))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (edit-box-text widget))
    (values (max 120 (+ tw 12))
            (max 30 (+ th 10)))))

(defmethod widget-min-size ((widget list-box))
  (let* ((longest-item (or (loop for item in (list-box-items widget)
                                 maximize (length (format nil "~a" item)))
                          8))
         (lines (max 3 (min 8 (length (list-box-items widget)))))
         (text-width (* longest-item +layout-font-char-width+))
         (min-height (+ (* lines (list-box-item-height widget)) 4)))
    (values (max 120 (+ text-width 12))
            (max min-height 72))))

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

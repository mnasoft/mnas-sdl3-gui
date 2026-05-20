;;;; ./src/toolbar/classes.lisp

(in-package :mnas-sdl3-gui/toolbar)

(defclass toolbar-button-spec ()
  ((command-id :initarg :command-id :accessor button-command-id
               :documentation "Command ID this button executes.")
   (type :initarg :type :initform :push :accessor button-type
         :documentation "Button type: :push, :toggle, or :radio.")
   (group :initarg :group :initform nil :accessor button-group
          :documentation "Radio group name (for :radio buttons).")
   (label :initarg :label :initform "" :accessor button-label
          :documentation "Display label for button.")
   (hotkey :initarg :hotkey :initform "" :accessor button-hotkey
           :documentation "Keyboard shortcut hint (e.g. 'Ctrl+N').")
   (width :initarg :width :initform 40 :accessor button-width
          :documentation "Button width in pixels.")
   (height :initarg :height :initform 32 :accessor button-height
           :documentation "Button height in pixels.")
   (x :initarg :x :initform 0 :accessor button-x
      :documentation "X position relative to toolbar.")
   (y :initarg :y :initform 0 :accessor button-y
      :documentation "Y position relative to toolbar.")))

(defclass toolbar ()
  ((buttons :initarg :buttons :initform '() :accessor toolbar-buttons
            :documentation "List of toolbar-button-spec instances.")
   (width :initarg :width :initform 0 :accessor toolbar-width
          :documentation "Toolbar width in pixels.")
   (height :initarg :height :initform 40 :accessor toolbar-height
           :documentation "Toolbar height in pixels.")
   (layout :initarg :layout :initform :horizontal :accessor toolbar-layout
           :documentation "Layout mode: :horizontal or :vertical.")
   (background :initarg :background :initform '(245 245 245 255)
               :accessor toolbar-background
               :documentation "Background color (R G B A).")
   (padding :initarg :padding :initform 6 :accessor toolbar-padding
            :documentation "Padding between buttons.")))

(defun make-toolbar (&key (width 0) (height 40) (layout :horizontal))
  "Create a new empty toolbar."
  (make-instance 'toolbar
                 :width width
                 :height height
                 :layout layout))

(defun make-button-spec (command-id &key (type :push) (label "") (hotkey "")
                                         (width 40) (height 32))
  "Create a button specification."
  (make-instance 'toolbar-button-spec
                 :command-id command-id
                 :type type
                 :label label
                 :hotkey hotkey
                 :width width
                 :height height))

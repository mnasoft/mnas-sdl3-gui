;;;; ./demos/dialog/widget/widget-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/widget-01)

(defparameter *window-dialog* nil)
(defparameter *renderer-dialog* nil)
(defparameter *widget-01-layer-manager* nil)
(defparameter *widgets* nil)
(defparameter *widget-root* nil)
(defparameter *widget-01-toolbar* nil)
(defparameter *widget-01-open* t)
(defparameter *status-message* "Widget demo. Click, type, and interact with controls.")
(defparameter *dialog-style* :flat)

(defparameter +widget-01-toolbar-x+ 20.0)
(defparameter +widget-01-toolbar-y+ 400.0)
(defparameter +widget-01-toolbar-width+ 300.0)
(defparameter +widget-01-toolbar-height+ 34.0)

(defun widget-01-entry-widget ()
  "Return first entry-like widget from the demo list." 
  (find-if (lambda (widget)
             (typep widget 'mnas-sdl3-gui/widgets:entry))
           *widgets*))

(defun widget-01-apply-style (style)
  "Apply STYLE to current widget set and keep status synchronized." 
  (setf *dialog-style* style)
  (mnas-sdl3-gui/widgets:set-widget-style style)
  (setf *status-message* (format nil "Style switched to ~(~A~)." style)))

(defun make-widget-01-toolbar ()
  "Create toolbar as a secondary presenter of widget-01 commands." 
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar :layout :horizontal :height 34)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :widget-01/style-flat :label "Flat" :width 58 :type :radio :group :style)
           (mnas-sdl3-gui/toolbar:make-button-spec :widget-01/style-windows :label "Windows" :width 78 :type :radio :group :style)
           (mnas-sdl3-gui/toolbar:make-button-spec :widget-01/style-motif :label "Motif" :width 62 :type :radio :group :style)
           (mnas-sdl3-gui/toolbar:make-button-spec :widget-01/clear-entry :label "Clear" :width 56)
           (mnas-sdl3-gui/toolbar:make-button-spec :widget-01/quit :label "Quit" :width 52)))
    toolbar))

(defun widget-01-sync-command-state ()
  "Sync full-state command properties for toolbar rendering." 
  (let ((flat (mnas-sdl3-gui/commands:find-command :widget-01/style-flat))
        (windows (mnas-sdl3-gui/commands:find-command :widget-01/style-windows))
        (motif (mnas-sdl3-gui/commands:find-command :widget-01/style-motif))
        (clear (mnas-sdl3-gui/commands:find-command :widget-01/clear-entry))
        (entry (widget-01-entry-widget)))
    (when flat
      (mnas-sdl3-gui/commands:set-command-checked flat (eq *dialog-style* :flat)))
    (when windows
      (mnas-sdl3-gui/commands:set-command-checked windows (eq *dialog-style* :windows)))
    (when motif
      (mnas-sdl3-gui/commands:set-command-checked motif (eq *dialog-style* :motif)))
    (when clear
      (mnas-sdl3-gui/commands:set-command-visible clear (and entry (> (length (mnas-sdl3-gui/widgets:entry-text entry)) 0))))))

;;; Create demo widgets

(defun create-demo-widgets ()
  "Create a collection of widgets for the demo."
  (list
    ;; Title label
    (make-instance 'mnas-sdl3-gui/widgets:label
                   :x 20 :y 20 :width 350 :height 30
                   :text "Widget Controls Demo")
    
    ;; Simple button
    (make-instance 'mnas-sdl3-gui/widgets:button
                   :x 20 :y 70 :width 100 :height 30
                   :text "Click Me"
                   :on-click (lambda (widget)
                              (setf *status-message* "Button clicked!")))
    
    ;; Toggle switch
    (make-instance 'mnas-sdl3-gui/widgets:toggle
                   :x 140 :y 70 :width 200 :height 30
                   :label "Enable Feature"
                   :state nil)
    
    ;; First checkbox
    (make-instance 'mnas-sdl3-gui/widgets:check-box
                   :x 20 :y 120 :width 150 :height 30
                   :label "Checkbox 1"
                   :checked nil)
    
    ;; Second checkbox
    (make-instance 'mnas-sdl3-gui/widgets:check-box
                   :x 20 :y 160 :width 150 :height 30
                   :label "Checkbox 2"
                   :checked t)
    
    ;; Edit box
    (make-instance 'mnas-sdl3-gui/widgets:entry
                   :x 20 :y 210 :width 300 :height 35
                   :text "Type here..."
                   :cursor 0
                   :max-length 100)

    ;; Editable combo box with dropdown and item creation
    (make-instance 'mnas-sdl3-gui/widgets:editable-combo-box
                   :x 20 :y 260 :width 300 :height 30
                   :main-height 30
                   :items '("Preset A" "Preset B" "Preset C")
                   :selected-index 0
                   :text ""
                   :cursor 0
                   :max-length 100
                   :max-visible-items 5
                   :placeholder "Type new item or select from list")

    ;; List box with items
    (make-instance 'mnas-sdl3-gui/widgets:list-box
                   :x 20 :y 310 :width 300 :height 150
                   :items '("Option 1" "Option 2" "Option 3" "Option 4" "Option 5"
              "Option 6" "Option 7" "Option 8")
                   :selected-index 0
                   :item-height 24)))

;;; SDL3 demo callbacks

(sdl3:def-app-init dialog-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "mnas-sdl3-gui widget demo" "1.0"
                         "com.mna.sdl3.gui.widgets.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from dialog-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Widget Controls Demo" 400 500 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from dialog-init :failure))
        (progn
          (setf *window-dialog* window
                *renderer-dialog* renderer
                *widget-01-layer-manager* (mnas-sdl3-gui/window-manager:make-window-layer-manager)
                *widgets* (create-demo-widgets)
                *widget-root* (mnas-sdl3-gui/widgets:make-widget-container
                               :x 0 :y 0 :width 400 :height 500
                               :children *widgets*)
                *widget-01-open* t
                *status-message* "Widget demo. Click, type, and interact with controls.")
          (mnas-sdl3-gui/window-manager:register-window
           *widget-01-layer-manager*
           (sdl3:get-window-id window)
           :host
           :payload *widget-root*)
          ;; Apply selected widget style and initialize TTF for Unicode text rendering.
          (widget-01-register-commands)
          (widget-01-register-shortcuts)
          (setf *widget-01-toolbar* (make-widget-01-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *widget-01-toolbar*)
          (widget-01-apply-style *dialog-style*)
          (widget-01-sync-command-state)
          (mnas-sdl3-gui/widgets:set-widget-focus (list *widget-root*) *widget-root*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input *window-dialog*))))
  :continue)

(sdl3:def-app-iterate dialog-iterate ()
  (unless *widget-01-open*
    (return-from dialog-iterate :success))

  ;; Clear screen with light gray background
  (sdl3:set-render-draw-color *renderer-dialog* 245 245 245 255)
  (sdl3:render-clear *renderer-dialog*)

  (widget-01-sync-command-state)
  
    ;; Render all widgets through the root container.
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order (list *widget-root*))
        do (mnas-sdl3-gui/widgets:render *renderer-dialog* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/toolbar:render-toolbar
   *widget-01-toolbar*
   *renderer-dialog*
   +widget-01-toolbar-x+
   +widget-01-toolbar-y+)
  
    ;; Render style and status text through SDL3_ttf-aware pipeline.
    (mnas-sdl3-gui/widgets:render-text
     *renderer-dialog*
     (format nil "Style: ~(~a~)" *dialog-style*)
     20.0 440.0 '(32 32 32 255))
    (mnas-sdl3-gui/widgets:render-text
     *renderer-dialog* *status-message* 20.0 464.0 '(52 52 52 255))

  (sdl3:render-present *renderer-dialog*)
  :continue)

(sdl3:def-app-event dialog-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (widget-01-command :widget-01/quit)
       :success)
      (sdl3:mouse-motion-event
         (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
        (list *widget-root*)
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((x (round (slot-value ev 'sdl3:%x)))
               (y (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (if (and (>= x (round +widget-01-toolbar-x+))
                        (<= x (+ (round +widget-01-toolbar-x+) (round +widget-01-toolbar-width+)))
                        (>= y (round +widget-01-toolbar-y+))
                        (<= y (+ (round +widget-01-toolbar-y+) (round +widget-01-toolbar-height+))))
                   (let ((button (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                  *widget-01-toolbar*
                                  (- x (round +widget-01-toolbar-x+))
                                  (- y (round +widget-01-toolbar-y+)))))
                     (when button
                       (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                        *widget-01-toolbar*
                        button
                        (list :x x :y y))))
                          (mnas-sdl3-gui/widgets:handle-widget-mouse-down
                        (or (mnas-sdl3-gui/window-manager:window-root-widgets
                          *widget-01-layer-manager*
                          (sdl3:get-window-id *window-dialog*))
                            (list *widget-root*)) x y))
                  (mnas-sdl3-gui/widgets:handle-widget-mouse-up
                   (or (mnas-sdl3-gui/window-manager:window-root-widgets
                     *widget-01-layer-manager*
                     (sdl3:get-window-id *window-dialog*))
                    (list *widget-root*)) x y))))
       :continue)
            (sdl3:mouse-wheel-event
             (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
            (or (mnas-sdl3-gui/window-manager:window-root-widgets
               *widget-01-layer-manager*
               (sdl3:get-window-id *window-dialog*))
              (list *widget-root*))
            (round (slot-value ev 'sdl3:%mouse-x))
            (round (slot-value ev 'sdl3:%mouse-y))
            (round (slot-value ev 'sdl3:%x))
            (round (slot-value ev 'sdl3:%y)))
             :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context nil)
             (mnas-sdl3-gui/widgets:handle-widget-key-event
            (or (mnas-sdl3-gui/window-manager:window-root-widgets
               *widget-01-layer-manager*
               (sdl3:get-window-id *window-dialog*))
              (list *widget-root*))
            (slot-value ev 'sdl3:%key)
            nil
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                   (widget-01-command :widget-01/quit))))
         (unless *widget-01-open*
           (return-from dialog-event :success)))
       :continue)
          (sdl3:text-input-event
           ;; Text input comes from current keyboard layout/IME and is UTF-8 safe.
           (mnas-sdl3-gui/widgets:dispatch-focused-text-input
            (or (mnas-sdl3-gui/window-manager:window-root-widgets
                 *widget-01-layer-manager*
                 (sdl3:get-window-id *window-dialog*))
                (list *widget-root*))
            (slot-value ev 'sdl3:%text))
           :continue)
      (t
       :continue))))

(sdl3:def-app-quit dialog-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *window-dialog*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (sdl3:destroy-renderer *renderer-dialog*)
  (sdl3:destroy-window *window-dialog*)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun widget-01 (&optional (style :flat))
  "Run the widget dialog demo with STYLE (:flat, :windows, :motif)."
  (setf *dialog-style* style
        *widget-01-open* t)
  (sdl3:enter-app-main-callbacks
   'dialog-init
   'dialog-iterate
   'dialog-event
   'dialog-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/widget)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/widget-01)
;;;; (widget-01)

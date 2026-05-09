;;;; ./demos/dialog/widgets-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *window-dialog* nil)
(defparameter *renderer-dialog* nil)
(defparameter *widgets* nil)
(defparameter *status-message* "Widget demo. Click, type, and interact with controls.")
(defparameter *dialog-style* :flat)

(defun focused-edit-box ()
  "Return currently focused edit-box widget, or NIL."
  (find-if (lambda (widget)
             (and (typep widget 'mnas-sdl3-gui/widgets:edit-box)
                  (mnas-sdl3-gui/widgets:widget-focused widget)))
           *widgets*))

(defun insert-text-into-focused-edit-box (text)
  "Insert TEXT into currently focused edit-box, character by character."
  (let ((edit-box (focused-edit-box)))
    (when edit-box
      (loop for ch across text
            do (mnas-sdl3-gui/widgets:handle-widget-key-press edit-box nil ch)))))

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
    (make-instance 'mnas-sdl3-gui/widgets:edit-box
                   :x 20 :y 210 :width 300 :height 35
                   :text "Type here..."
                   :cursor 0
                   :max-length 100)
    
    ;; List box with items
    (make-instance 'mnas-sdl3-gui/widgets:list-box
                   :x 20 :y 270 :width 300 :height 150
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
        (setf *window-dialog* window
              *renderer-dialog* renderer
              *widgets* (create-demo-widgets)
              *status-message* "Widget demo. Click, type, and interact with controls.")))
        ;; Apply selected widget style and initialize TTF for Unicode text rendering.
        (mnas-sdl3-gui/widgets:set-widget-style *dialog-style*)
        (mnas-sdl3-gui/widgets:init-ttf-font)
        (sdl3:start-text-input *window-dialog*)
  :continue)

(sdl3:def-app-iterate dialog-iterate ()
  ;; Clear screen with light gray background
  (sdl3:set-render-draw-color *renderer-dialog* 245 245 245 255)
  (sdl3:render-clear *renderer-dialog*)
  
  ;; Render all widgets
  (loop for widget in *widgets*
        do (mnas-sdl3-gui/widgets:render-widget *renderer-dialog* widget))
  
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
       :success)
      (sdl3:mouse-motion-event
       (loop for widget in *widgets*
             do (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
                 widget
                 (round (slot-value ev 'sdl3:%x))
                 (round (slot-value ev 'sdl3:%y))))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (if (slot-value ev 'sdl3:%down)
         (loop for widget in *widgets*
           when (mnas-sdl3-gui/widgets:handle-widget-mouse-down
             widget
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y)))
           do (return))
         (loop for widget in *widgets*
           when (mnas-sdl3-gui/widgets:handle-widget-mouse-up
             widget
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y)))
           do (return))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (cond
           ((eq (slot-value ev 'sdl3:%key) :escape)
            (return-from dialog-event :success))
           (t
            ;; Find focused widget and send key event
            (loop for widget in *widgets*
                  when (mnas-sdl3-gui/widgets:widget-focused widget)
                  do (mnas-sdl3-gui/widgets:handle-widget-key-press
                      widget
                      (slot-value ev 'sdl3:%key)
                      nil)))))
       :continue)
              (sdl3:text-input-event
               ;; Text input comes from current keyboard layout/IME and is UTF-8 safe.
               (insert-text-into-focused-edit-box (slot-value ev 'sdl3:%text))
               :continue)
      (t
       :continue))))

(sdl3:def-app-quit dialog-quit (result)
  (declare (ignore result))
  (when *window-dialog*
    (sdl3:stop-text-input *window-dialog*))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (sdl3:destroy-renderer *renderer-dialog*)
  (sdl3:destroy-window *window-dialog*)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-dialog-demo (&optional (style :flat))
  "Run the widget dialog demo with STYLE (:flat, :windows, :motif)."
  (setf *dialog-style* style)
  (sdl3:enter-app-main-callbacks
   'dialog-init
   'dialog-iterate
   'dialog-event
   'dialog-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (do-dialog-demo)

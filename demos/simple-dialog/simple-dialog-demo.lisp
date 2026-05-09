;;;; ./demos/simple-dialog/simple-dialog-demo.lisp

(in-package :mnas-sdl3-gui/demos/simple-dialog)

(defparameter *window* nil)
(defparameter *renderer* nil)
(defparameter *dialog-result* nil)
(defparameter *dialog-open* t)
(defparameter *dialog-style* :windows)

;; Dialog state
(defparameter *ok-button* nil)
(defparameter *cancel-button* nil)
(defparameter *extra-button* nil)
(defparameter *message* "Are you sure you want to continue?")

(defun dialog-widgets ()
  "Return focus-traversable widgets in the simple dialog."
  (list *ok-button* *cancel-button* *extra-button*))

(defun dialog-tab-backward-p (ev)
  "Return true when Tab navigation should move backward."
  (let ((mods (slot-value ev 'sdl3:%mod)))
    (typecase mods
      (list (or (member :alt mods) (member :lalt mods) (member :ralt mods)
                (member :shift mods) (member :lshift mods) (member :rshift mods)))
      (symbol (member mods '(:alt :lalt :ralt :shift :lshift :rshift)))
      (integer (not (zerop (logand mods #x0303))))
      (t nil))))

;;; Dialog initialization

(defun create-dialog-buttons ()
  "Create OK and Cancel buttons for the dialog."
  ;; Dialog centered at 320x240 with size 300x150
  ;; OK button: bottom left
  ;; Cancel button: bottom right
  (setf *ok-button* (make-instance 'mnas-sdl3-gui/widgets:button
                                   :x 70 :y 370 :width 80 :height 40
                                   :text "OK"
                                   :on-click (lambda (widget)
                                              (declare (ignore widget))
                                              (setf *dialog-result* :ok
                                                    *dialog-open* nil))))
  (setf *cancel-button* (make-instance 'mnas-sdl3-gui/widgets:button
                                       :x 250 :y 370 :width 80 :height 40
                                       :text "Cancel"
                                       :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (setf *dialog-result* :cancel
                                                        *dialog-open* nil))))
  (setf *extra-button* (make-instance 'mnas-sdl3-gui/widgets:button
                                      :x 160 :y 320 :width 130 :height 34
                                      :text "Кнопка_1"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (format t "[DEMO] Нажата кнопка: Кнопка_1~%"))))
  (values))

;;; Rendering

(defun render-dialog-background (renderer)
  "Render semi-transparent dialog background."
  ;; Semi-transparent overlay covering whole window
  (sdl3:set-render-draw-color renderer 0 0 0 100)
  (sdl3:render-fill-rect renderer
                         (make-instance 'sdl3:frect :%x 0.0 :%y 0.0 :%w 400.0 :%h 500.0))
  
  ;; Dialog box background (white)
  (sdl3:set-render-draw-color renderer 240 240 240 255)
  (sdl3:render-fill-rect renderer
                         (make-instance 'sdl3:frect :%x 50.0 :%y 150.0 :%w 300.0 :%h 200.0))
  
  ;; Dialog box border (dark gray)
  (sdl3:set-render-draw-color renderer 50 50 50 255)
  (sdl3:render-rect renderer
                    (make-instance 'sdl3:frect :%x 50.0 :%y 150.0 :%w 300.0 :%h 200.0)))

(defun render-dialog-content (renderer)
  "Render dialog title, message, and buttons."
  ;; Title and message via SDL3_ttf-aware text pipeline.
  (mnas-sdl3-gui/widgets:render-text renderer "Confirmation Dialog" 70.0 170.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text renderer
                                     (format nil "Style: ~(~a~)" *dialog-style*)
                                     70.0 192.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text renderer *message* 70.0 230.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text renderer
                                     "Tab/Shift+Tab: focus, Space: activate button"
                                     70.0 252.0 '(0 0 0 255))
  
  ;; Render buttons
  (mnas-sdl3-gui/widgets:render-widget *renderer* *ok-button*)
  (mnas-sdl3-gui/widgets:render-widget *renderer* *cancel-button*)
  (mnas-sdl3-gui/widgets:render-widget *renderer* *extra-button*))

;;; Event handling

(defun handle-dialog-mouse-down (x y)
  "Handle mouse press in dialog."
  (let ((mx (float x 1.0))
        (my (float y 1.0)))
    (loop for widget in (dialog-widgets)
          when (mnas-sdl3-gui/widgets:handle-widget-mouse-down widget mx my)
          do (mnas-sdl3-gui/widgets:set-widget-focus (dialog-widgets) widget)
             (return))))

(defun handle-dialog-mouse-up (x y)
  "Handle mouse release in dialog."
  (mnas-sdl3-gui/widgets:handle-widget-mouse-up *ok-button* (float x 1.0) (float y 1.0))
  (mnas-sdl3-gui/widgets:handle-widget-mouse-up *cancel-button* (float x 1.0) (float y 1.0))
  (mnas-sdl3-gui/widgets:handle-widget-mouse-up *extra-button* (float x 1.0) (float y 1.0)))

;;; SDL3 demo callbacks

(sdl3:def-app-init simple-dialog-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Simple Dialog Demo" "1.0"
                         "com.mna.sdl3.gui.simple-dialog")
  (when (not (sdl3:init :video))
    (format t "Failed to initialize SDL3: ~a~%" (sdl3:get-error))
    (return-from simple-dialog-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Simple Dialog Demo" 400 500 0)
    (if (not ok)
        (progn
          (format t "Failed to create window/renderer: ~a~%" (sdl3:get-error))
          (return-from simple-dialog-init :failure))
      (progn
        (setf *window* window
          *renderer* renderer
          *dialog-result* nil
          *dialog-open* t)
        (mnas-sdl3-gui/widgets:set-widget-style *dialog-style*)
        (mnas-sdl3-gui/widgets:init-ttf-font)
        (create-dialog-buttons)
        (mnas-sdl3-gui/widgets:move-widget-focus (dialog-widgets)))))
  :continue)

(sdl3:def-app-iterate simple-dialog-iterate ()
  ;; If dialog is closed, quit the app
  (unless *dialog-open*
    (return-from simple-dialog-iterate :success))
  
  ;; Render
  (sdl3:set-render-draw-color *renderer* 220 220 220 255)
  (sdl3:render-clear *renderer*)
  
  (render-dialog-background *renderer*)
  (render-dialog-content *renderer*)
  
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event simple-dialog-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *dialog-open* nil)
       :success)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (if (slot-value ev 'sdl3:%down)
             (handle-dialog-mouse-down (round (slot-value ev 'sdl3:%x))
                                       (round (slot-value ev 'sdl3:%y)))
             (handle-dialog-mouse-up (round (slot-value ev 'sdl3:%x))
                                     (round (slot-value ev 'sdl3:%y)))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (cond
           ((eq (slot-value ev 'sdl3:%key) :escape)
            (setf *dialog-open* nil)
            :success)
           ((eq (slot-value ev 'sdl3:%key) :tab)
            (mnas-sdl3-gui/widgets:move-widget-focus
             (dialog-widgets)
             :backward (dialog-tab-backward-p ev))
            :continue)
           ((eq (slot-value ev 'sdl3:%key) :space)
            (let ((focused (mnas-sdl3-gui/widgets:focused-widget (dialog-widgets))))
              (when focused
                (mnas-sdl3-gui/widgets:handle-widget-key-press focused :space nil)))
            :continue)
           (t :continue)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit simple-dialog-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (sdl3:destroy-window *window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

;;; Public demo function

(defun do-simple-dialog-demo (&optional (style :windows))
  "Run the simple dialog demo.
   Returns :ok or :cancel depending on which button was clicked."
  (setf *dialog-style* style)
  (sdl3:enter-app-main-callbacks
   'simple-dialog-init
   'simple-dialog-iterate
   'simple-dialog-event
   'simple-dialog-quit)
  *dialog-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (do-simple-dialog-demo)

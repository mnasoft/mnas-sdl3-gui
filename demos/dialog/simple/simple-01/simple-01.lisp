;;;; ./demos/simple-dialog/simple-dialog-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

(defun simple-01-sync-command-state ()
  "Sync command state for simple-01 toolbar." 
  (dolist (id '(:simple-01/ok :simple-01/cancel :simple-01/quit))
    (let ((cmd (mnas-sdl3-gui/commands:find-command id)))
      (when cmd
          (mnas-sdl3-gui/commands:set-command-enabled cmd t)))))

(defun dialog-widgets ()
  "Return focus-traversable widgets in the simple dialog."
  (if *dialog-root*
      (mnas-sdl3-gui/widgets:children *dialog-root*)
      (list *ok-button* *cancel-button* *extra-button*)))

(defun simple-01-root-widgets ()
  "Return the current widget root list for the simple dialog demo."
  (or (and *simple-01-layer-manager*
           (mnas-sdl3-gui/window-manager:window-root-widgets
            *simple-01-layer-manager* *window-id*))
      (list *dialog-root*)))

;;; Dialog initialization

(defun create-dialog-buttons ()
  "Create OK and Cancel buttons for the dialog."
  ;; Dialog centered at 320x240 with size 300x150
  ;; OK button: bottom left
  ;; Cancel button: bottom right
  (setf *ok-button* (make-instance 'mnas-sdl3-gui/widgets:<button>
                                   :x 70 :y 370 :width 80 :height 40
                                   :text "OK"
                                   :on-click (lambda (widget)
                                              (declare (ignore widget))
                                              (setf *dialog-result* :ok
                                                    *dialog-open* nil))))
  (setf *cancel-button* (make-instance 'mnas-sdl3-gui/widgets:<button>
                                       :x 250 :y 370 :width 80 :height 40
                                       :text "Cancel"
                                       :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (setf *dialog-result* :cancel
                                                        *dialog-open* nil))))
  (setf *extra-button* (make-instance 'mnas-sdl3-gui/widgets:<button>
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
  
    ;; Render buttons through the demo root widget container.
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order (simple-01-root-widgets))
        do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*)))

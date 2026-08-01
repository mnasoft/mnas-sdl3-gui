

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

;;; SDL3 demo callbacks

(sdl3:def-app-init simple-dialog-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Simple Dialog Demo" "1.0"
                         "com.mna.sdl3.gui.simple-dialog")
  (when (not (sdl3:init :video))
    (format t "Failed to initialize SDL3: ~a~%" (sdl3:get-error))
    (return-from simple-dialog-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Simple Dialog Demo" 400 +simple-dialog-window-height+ 0)
    (if (not ok)
        (progn
          (format t "Failed to create window/renderer: ~a~%" (sdl3:get-error))
          (return-from simple-dialog-init :failure))
        (progn
          (setf *window*        window
                *window-id*     (sdl3:get-window-id window)
                *renderer*      renderer
                *dialog-result* nil
                *dialog-open*   t)
          (simple-01-register-commands)
          (simple-01-register-shortcuts)
          (setf *toolbar* (simple-01-create-toolbar))
          (mnas-sdl3-gui/widgets:set-widget-style *dialog-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-dialog-buttons)
          (setf *dialog-root*
                (mnas-sdl3-gui/widgets:make-widget-container
                 :x 0 :y 0 :width 400 :height +simple-dialog-window-height+
                 :children (dialog-widgets))
                *simple-01-layer-manager*
                (mnas-sdl3-gui/window-manager:make-window-layer-manager))
          (mnas-sdl3-gui/window-manager:register-window
           *simple-01-layer-manager*
           *window-id*
           :host
           :payload *dialog-root*
           :open-p t)
          (mnas-sdl3-gui/widgets:set-widget-focus (dialog-widgets) (first (dialog-widgets))))))
  :continue)

(sdl3:def-app-iterate simple-dialog-iterate ()
  ;; If dialog is closed, quit the app
  (unless *dialog-open*
    (return-from simple-dialog-iterate :success))
  
  ;; Render
  (sdl3:set-render-draw-color *renderer* 220 220 220 255)
  (sdl3:render-clear *renderer*)
  
  (simple-01-sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render-toolbar
     *toolbar*
     *renderer*
     0.0
     (- +simple-dialog-window-height+ +simple-dialog-toolbar-height+)))
  
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
         (let ((toolbar-y-offset (- +simple-dialog-window-height+ +simple-dialog-toolbar-height+)))
           (if (and (slot-value ev 'sdl3:%down)
                    (and *toolbar*
                         (mnas-sdl3-gui/widgets:toolbar-buttons-at-position
                          *toolbar*
                          (round (slot-value ev 'sdl3:%x))
                          (- (round (slot-value ev 'sdl3:%y)) toolbar-y-offset))))
               (mnas-sdl3-gui/widgets:toolbar-button-clicked
                *toolbar*
                (mnas-sdl3-gui/widgets:toolbar-buttons-at-position
                 *toolbar*
                 (round (slot-value ev 'sdl3:%x))
                 (- (round (slot-value ev 'sdl3:%y)) toolbar-y-offset))
                (list :window-id *window-id*))
               (mnas-sdl3-gui/widgets:handle-mouse-button-event
                (simple-01-root-widgets)
                ev))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *window-id*))
           (mnas-sdl3-gui/widgets:handle-keyboard-event
            (simple-01-root-widgets)
            ev)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit simple-dialog-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

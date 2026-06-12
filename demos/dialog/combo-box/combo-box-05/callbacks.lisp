;;;; ./demos/dialog/combo-box/combo-box-05/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-05)

(sdl3:def-app-init combo-box-05-demo-init (argc argv)
  (declare (ignore argc argv))
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from combo-box-05-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Combo Box 05" 380 120 0)
    (unless ok (format t "create-window failed: ~A~%" (sdl3:get-error)) (return-from combo-box-05-demo-init :failure))
    (setf *window* window
          *renderer* renderer
          *open* t)
    (mnas-sdl3-gui/widgets:set-widget-style :flat)
    (mnas-sdl3-gui/widgets:init-ttf-font)
    (create-combo-box-05-widgets *window*)
    ;; ensure popup uses host window for global positioning
    ;(mnas-sdl3-gui/widgets:combo-box-enable-popup-window *widget* *window*)
    (mnas-sdl3-gui/widgets:set-widget-focus *widgets* *widget*)
    :continue))

(sdl3:def-app-iterate combo-box-05-demo-iterate ()
  (unless *open* (return-from combo-box-05-demo-iterate :success))
  (sdl3:set-render-draw-color *renderer* 240 240 240 255)
  (sdl3:render-clear *renderer*)
  (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *widgets*)
    do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
  (mnas-sdl3-gui/widgets:render-text *renderer*
    (format nil "selected=~A" (mnas-sdl3-gui/widgets:combo-box-selected-item *widget*))
    20.0 84.0 '(120 120 120 255))
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event combo-box-05-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event (setf *open* nil) :success)
      (sdl3:mouse-motion-event
       (let* ((win-id (slot-value ev 'sdl3:%window-id))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
         (cond
          (associated
           (dolist (w associated)
             (mnas-sdl3-gui/widgets:handle-mouse-motion-event w ev)))
          ((= win-id (sdl3:get-window-id *window*))
           (mnas-sdl3-gui/widgets:handle-mouse-motion-event (list *widgets*) ev))))
       :continue)
      (sdl3:mouse-wheel-event
       (let* ((win-id (slot-value ev 'sdl3:%window-id))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
         (cond
          (associated
           (dolist (w associated)
             (mnas-sdl3-gui/widgets:handle-mouse-wheel-event w ev)))
          ((= win-id (sdl3:get-window-id *window*))
           (mnas-sdl3-gui/widgets:handle-mouse-wheel-event *widgets* ev))))
       :continue)
        (sdl3:mouse-button-event
         (let* ((win-id (slot-value ev 'sdl3:%window-id))
                (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
           (cond
             (associated
              (dolist (w associated)
                (mnas-sdl3-gui/widgets:handle-mouse-button-event w ev)))
             ((= win-id (sdl3:get-window-id *window*))
              (mnas-sdl3-gui/widgets:handle-mouse-button-event *widgets* ev))))
         :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down) (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:handle-widget-key-event *widgets* (slot-value ev 'sdl3:%key) nil :mods (slot-value ev 'sdl3:%mod)))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input *widgets* (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit combo-box-05-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *widget*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer* (sdl3:destroy-renderer *renderer*))
  (when *window* (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit)
  :success)

;;;; ./demos/dialog/widget/widget-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/widget-01)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "mnas-sdl3-gui widget demo" "1.0"
                         "com.mna.sdl3.gui.widgets.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))
  (multiple-value-bind (ok window render)
      (sdl3:create-window-and-renderer "Widget Controls Demo" 400 500 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from callback-init :failure))
        (progn
          (setf *window* window
                *render* render
                *layer-manager* (mnas-sdl3-gui/window-manager:make-window-layer-manager)
                *widgets* (create-demo-widgets)
                *widget-root* (mnas-sdl3-gui/widgets:make-widget-container
                               :x 0 :y 0 :width 400 :height 500
                               :children *widgets*)
                *open* t
                *status-message* "Widget demo. Click, type, and interact with controls.")
          (mnas-sdl3-gui/window-manager:register-window
           *layer-manager*
           (sdl3:get-window-id window)
           :host
           :payload *widget-root*)
          (register-commands)
          (register-shortcuts)
          (setf *toolbar* (make-toolbar window))
          (apply-style *style*)
          (sync-command-state)
          (mnas-sdl3-gui/widgets:set-widget-focus (list *widget-root*) *widget-root*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input *window*))))
  :continue)

(sdl3:def-app-iterate callbacks-iterate ()
  (unless *open*
    (return-from callbacks-iterate :success))
  (sdl3:set-render-draw-color *render* 245 245 245 255)
  (sdl3:render-clear *render*)
  (sync-command-state)
 
  (loop :for widget :in
                    (mnas-sdl3-gui/widgets:widgets-in-render-order (list *widget-root*))
        :do (mnas-sdl3-gui/widgets:render
             *render*
             widget
             mnas-sdl3-gui/widgets:*widget-style*))
  
  #+nil (mnas-sdl3-gui/widgets:render
   *render*
   (mnas-sdl3-gui/widgets:widgets-for-window *window*)
   mnas-sdl3-gui/widgets:*widget-style*)
  
  (mnas-sdl3-gui/widgets:render-text *render* (format nil "Style: ~(~a~)" *style*) 20.0 440.0 '(32 32 32 255))
  (mnas-sdl3-gui/widgets:render-text *render* *status-message* 20.0 464.0 '(52 52 52 255))

  (sdl3:render-present *render*)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (command :widget-01/quit)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:handle-mouse-motion-event
        (list *widget-root*)
        ev)
       :continue)
      #+nil(sdl3:mouse-button-event
            (when (= (slot-value ev 'sdl3:%button) 1)
              (let ((x (round (slot-value ev 'sdl3:%x)))
                    (y (round (slot-value ev 'sdl3:%y))))
                (if (slot-value ev 'sdl3:%down)
                    (if (and (>= x (round +toolbar-x+))
                             (<= x (+ (round +toolbar-x+) (round +toolbar-width+)))
                             (>= y (round +toolbar-y+))
                             (<= y (+ (round +toolbar-y+) (round +toolbar-height+))))
                        (let ((button (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                       *toolbar*
                                       (- x (round +toolbar-x+))
                                       (- y (round +toolbar-y+)))))
                          (when button
                            (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                             *toolbar*
                             button
                             (list :x x :y y))))
                        (mnas-sdl3-gui/widgets:handle-mouse-button-event
                         (or (mnas-sdl3-gui/window-manager:window-root-widgets
                              *layer-manager*
                              (sdl3:get-window-id *window*))
                             (list *widget-root*)) ev))
                    (mnas-sdl3-gui/widgets:handle-mouse-button-event
                     (or (mnas-sdl3-gui/window-manager:window-root-widgets
                          *layer-manager*
                          (sdl3:get-window-id *window*))
                         (list *widget-root*)) ev))))
            :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
        (or (mnas-sdl3-gui/window-manager:window-root-widgets
             *layer-manager*
             (sdl3:get-window-id *window*))
            (list *widget-root*))
        ev)
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context nil)
           (mnas-sdl3-gui/widgets:handle-keyboard-event
            (or (mnas-sdl3-gui/window-manager:window-root-widgets
                 *layer-manager*
                 (sdl3:get-window-id *window*))
                (list *widget-root*))
            ev))
         (unless *open*
           (return-from callback-event :success)))
       :continue)
      (sdl3:text-input-event
       ;; Text input comes from current keyboard layout/IME and is UTF-8 safe.
       (mnas-sdl3-gui/widgets:handle-text-input-event
        (or (mnas-sdl3-gui/window-manager:window-root-widgets
             *layer-manager*
             (sdl3:get-window-id *window*))
            (list *widget-root*))
        ev)
       :continue)
      (t
       :continue))))

(sdl3:def-app-quit callback-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (sdl3:destroy-renderer *render*)
  (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

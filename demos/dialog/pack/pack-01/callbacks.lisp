;;;; ./demos/dialog/pack-layout-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/pack-01)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Pack Layout Demo" "1.0"
                         "com.mna.sdl3.gui.pack-layout.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))
  (setf *layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  ;; Init TTF before size calculation to get accurate glyph metrics.
  (mnas-sdl3-gui/widgets:init-ttf-font)
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Pack Layout Demo" 800 600 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from callback-init :failure))
        (progn
          (setf *window* window
                *renderer* renderer
                *window-id* (sdl3:get-window-id window)
                *open* t
                *status* "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")
          (create-widgets window)
          (mnas-sdl3-gui/window-manager:register-window
           *layer-manager*
           *window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *layer-manager*
           *window-id*)
          (register-commands)
          (register-shortcuts)
          (create-toolbar window)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (mnas-sdl3-gui/widgets:move-widget-focus
           (mnas-sdl3-gui/widgets:widgets-for-window window)
           ))))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))

  (sdl3:set-render-draw-color *renderer* 242 242 242 255)
  (sdl3:render-clear *renderer*)
  (sync-command-state)
  (loop :for widget :in (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        :do (mnas-sdl3-gui/widgets:render
             *renderer*
             widget
             mnas-sdl3-gui/widgets:*widget-style*))
  (mnas-sdl3-gui/widgets:render-text
   *renderer* *status* 16.0 *status-y* '(45 45 45 255))

  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event (setf *open* nil) :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *layer-manager*
                              window-id))))
           (case action
             (:close-root
              (setf *open* nil)
              (return-from callback-event :success))
             (otherwise
              (setf *open* nil)
              (return-from callback-event :success)))))
       :continue)
      (sdl3:mouse-motion-event (mnas-sdl3-gui/widgets:handle-mouse-motion-event (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev) :continue)
      (sdl3:mouse-button-event (mnas-sdl3-gui/widgets:handle-mouse-button-event (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev) :continue)
      (sdl3:mouse-wheel-event  (mnas-sdl3-gui/widgets:handle-mouse-wheel-event  (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev) :continue)
      (sdl3:keyboard-event     (mnas-sdl3-gui/widgets:handle-keyboard-event     (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev) :continue)
      (sdl3:text-input-event   (mnas-sdl3-gui/widgets:handle-text-input-event   (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev) :continue)
      (t :continue))))

(sdl3:def-app-quit callback-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

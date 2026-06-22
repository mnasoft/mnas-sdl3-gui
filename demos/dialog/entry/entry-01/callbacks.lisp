;;;; ./demos/dialog/entry/entry-01/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)
 
(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Edit Box Dialog Demo" "1.0"
                         "com.mna.sdl3.gui.entry-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))
  (setf *layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Entry Dialog + OK" 400 240 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from callback-init :failure))
        (progn
          (setf *window* window
                *renderer* renderer
                *window-id* (sdl3:get-window-id window)
                *open* t
                *result* nil
                *active-modifiers* nil)
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
          (setf *toolbar* (create-toolbar window))
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          ;; TTF must be initialized after SDL video subsystem is ready.
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-widgets window)
          (sync-command-state)
          (mnas-sdl3-gui/widgets:set-widget-focus (widgets)
                                                  *input*))))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))

  (sdl3:set-render-draw-color *renderer* 230 230 230 255)
  (sdl3:render-clear *renderer*)
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     *title* 40.0 40.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     *hint* 40.0 62.0 '(70 70 70 255))

  (sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render
     *renderer*
     *toolbar*
     mnas-sdl3-gui/widgets:*widget-style*))

  (loop :for widget :in (mnas-sdl3-gui/widgets:widgets-in-render-order (widgets))
        :do
           (mnas-sdl3-gui/widgets:render
            *renderer*
            widget mnas-sdl3-gui/widgets:*widget-style*))
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (mnas-debug:with
      (mnas-sdl3-gui/events:update-from-sdl-event ev)
      (mnas-sdl3-gui/events:log-event ev))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:handle-mouse-motion-event
        (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        ev)
       :continue)
      (sdl3:mouse-button-event
       (mnas-sdl3-gui/widgets:handle-mouse-button-event
        (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        ev)
       :continue)
      (sdl3:keyboard-event
       (mnas-sdl3-gui/widgets:handle-keyboard-event (widgets) ev))
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        (widgets)
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit callback-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

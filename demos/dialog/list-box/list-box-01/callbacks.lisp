;;;; ./demos/dialog/list-box/list-box-01/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(sdl3:def-app-init list-box-01-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Two List-Boxes Demo" "1.0"
                         "com.mna.sdl3.gui.list-box-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from list-box-01-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer
       "Two List-Boxes Demo"
       640
       +list-box-01-window-height+
       0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from list-box-01-demo-init :failure))
        (progn
          (setf *window* window
                *window-id* (sdl3:get-window-id window)
                *renderer* renderer
                *open* t
                *result* nil)
          (list-box-01-register-commands)
          (list-box-01-register-shortcuts)
          (setf *toolbar* (list-box-01-create-toolbar))
          #+nil (mnas-sdl3-gui/widgets:register-toolbar-for-command-updates *toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-list-box-01-demo-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus *widgets*
                                                  *left*))))
  :continue)

(sdl3:def-app-iterate list-box-01-demo-iterate ()
  (unless *open*
    (return-from list-box-01-demo-iterate :success))

  (sdl3:set-render-draw-color *renderer* 236 236 236 255)
  (sdl3:render-clear *renderer*)
  (list-box-01-sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render
     *renderer*
     *toolbar*
     mnas-sdl3-gui/widgets:*widget-style*))

  (loop for widget in (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        #+nil (mnas-sdl3-gui/widgets:widgets-in-render-order *widgets*)
        
        do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event list-box-01-demo-event (type event)
  (declare (ignore type))
  (mnas-debug:with
    (mnas-sdl3-gui/events:update-from-sdl-event ev)
    (mnas-sdl3-gui/events:log-event ev))
  (let ((ev (sdl3:event-unmarshal event)))
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
      (sdl3:mouse-wheel-event
       ;; Temporary debug: log received mouse-wheel events at app level
       (handler-case
           (let ((mx (handler-case (slot-value ev 'sdl3:%x) (error () nil)))
                 (my (handler-case (slot-value ev 'sdl3:%y) (error () nil)))
                 (myrel (handler-case (slot-value ev 'sdl3:%yrel) (error () nil))))
             (format t "[app-event] mouse-wheel x=~S y=~S yrel=~S~%" mx my myrel)
             (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
              (mnas-sdl3-gui/widgets:widgets-for-window *window*)
              ev))
         (error (e)
           (format t "[app-event] mouse-wheel: error inspecting event: ~S~%" e)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *window-id*))
           (mnas-sdl3-gui/widgets:handle-widget-key-event
            *widgets*
            (slot-value ev 'sdl3:%key)
            nil
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (setf *result* nil
                               *open* nil)
                         :success)
            :on-return (lambda ()
                         (setf *result*
                               (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *left*)
                                                (mnas-sdl3-gui/widgets:list-box-items *left*))
                                     :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *right*)
                                                 (mnas-sdl3-gui/widgets:list-box-items *right*)))
                               *open* nil)
                         :success))))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit list-box-01-demo-quit (result)
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

;;;; ./demos/dialog/list-box/list-box-01/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Two List-Boxes Demo" "1.0"
                         "com.mna.sdl3.gui.list-box-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer
       "Two List-Boxes Demo"
       640
       +window-height+
       0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from callback-init :failure))
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

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))

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

(sdl3:def-app-event callback-event (type event)
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
       (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
        (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        ev)
       :continue)
      (sdl3:keyboard-event
       (mnas-sdl3-gui/widgets:handle-keyboard-event
        (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        ev)
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:handle-text-input-event
        *widgets*
        ev)
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

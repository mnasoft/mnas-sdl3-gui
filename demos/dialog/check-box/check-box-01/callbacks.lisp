;;;; ./demos/dialog/check-box/check-box-01/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)

(sdl3:def-app-init check-box-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Check-Box Demo" "1.0"
                         "com.mna.sdl3.gui.check-box.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from check-box-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer
       "Check-Box Demo"
       +window-width+
       +window-height+
       0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from check-box-demo-init :failure))
        (progn
          (setf *window* window
                *renderer* renderer
                *window-id* (sdl3:get-window-id window)
                *open* t)
          (check-box-register-commands)
          (check-box-register-shortcuts)
          (setf *toolbar* (check-box-create-toolbar window))
          #+nil (mnas-sdl3-gui/widgets:register-toolbar-for-command-updates *toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-check-box-widgets window)
          (mnas-sdl3-gui/widgets:move-widget-focus (check-box-content-widgets)))))
  :continue)

(sdl3:def-app-iterate check-box-demo-iterate ()
  (unless *open*
    (return-from check-box-demo-iterate :success))
  (sdl3:set-render-draw-color *renderer* 240 240 240 255)
  (sdl3:render-clear *renderer*)
  (check-box-01-sync-command-state)
  (mnas-sdl3-gui/widgets:render *renderer* *toolbar* mnas-sdl3-gui/widgets:*widget-style*)
  (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order (check-box-content-widgets))
        do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     *status*
                                     20.0 238.0 '(40 40 40 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     "Tab/Shift+Tab: focus, Space: toggle check-box"
                                     20.0 260.0 '(90 90 90 255))

  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event check-box-demo-event (type event)
  (declare (ignore type))
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
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *window-id*))
           (mnas-sdl3-gui/widgets:handle-widget-key-event
            (mnas-sdl3-gui/widgets:widgets-for-window *window*)
            (slot-value ev 'sdl3:%key)
            nil
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (setf *open* nil)
                         :success))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit check-box-demo-quit (result)
  (declare (ignore result))
  (when *window*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

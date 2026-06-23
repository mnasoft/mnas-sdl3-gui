;;;; ./demos/dialog/entry/entry-02/entry-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-02)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Entry Demo" "1.0"
                         "com.mna.sdl3.gui.entry-02.demo")
  (when (not (sdl3:init :video))
    (format t "~A~%" (sdl3:get-error))
    (return-from callback-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Entry Widget Demo" 500 520 0)
    (if (not ok)
        (progn
          (format t "~A~%" (sdl3:get-error))
          (return-from callback-init :failure))
        (progn
          (setf *window* window
                *window-id* (sdl3:get-window-id window)
                *renderer* renderer
                *open* t
                *result* nil
                *active-modifiers* nil)
          (register-commands)
          (register-shortcuts)
          (setf *toolbar* (create-toolbar window))
          #+nil(mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-widgets window)
          (mnas-sdl3-gui/widgets:set-widget-focus (widgets)
                                                  *name*))))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))
  (sdl3:set-render-draw-color *renderer* 245 245 245 255)
  (sdl3:render-clear *renderer*)
  (sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render
     *renderer*
     *toolbar*
     mnas-sdl3-gui/widgets:*widget-style*))
  (loop :for widget :in (mnas-sdl3-gui/widgets:widgets-in-render-order *widgets*)
        :do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:handle-mouse-motion-event
        *widgets*
        ev)
       :continue)
      (sdl3:mouse-button-event
       (mnas-sdl3-gui/widgets:handle-mouse-button-event
        (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        ev)
       :continue)
      (sdl3:keyboard-event
       (mnas-sdl3-gui/widgets:handle-keyboard-event
            (mnas-sdl3-gui/widgets:widgets-for-window *window*)
            ev))
      #+nil
      (sdl3:keyboard-event
       (update-modifier-state ev)
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (key-modifiers ev)
                  :context (list :window-id *window-id*))
           (mnas-sdl3-gui/widgets:handle-keyboard-event
            *widgets*
            (slot-value ev 'sdl3:%key)
            nil
            :mods (key-modifiers ev)
            :on-escape (lambda ()
                         (setf *open* nil)
                         :success)
            :on-return (lambda ()
                         (setf *status*
                               (format nil "Command executed: ~A"
                                       (mnas-sdl3-gui/widgets:<entry>-text *command*)))
                         :success))))
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

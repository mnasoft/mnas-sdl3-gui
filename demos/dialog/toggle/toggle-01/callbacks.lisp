;;;; ./demos/dialog/toggle/toggle-01/toggle-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Toggle Group Demo" "1.0"
                         "com.mna.sdl3.gui.toggle-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer
       "Toggle Groups"
       +window-width+
       +window-height+
       0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from callback-init :failure))
        (progn
          (setf *window* window
                *renderer* renderer
                *window-id* (sdl3:get-window-id window)
                *open* t)
          (setf *layer-manager*
                (mnas-sdl3-gui/window-manager:make-window-layer-manager))
          (mnas-sdl3-gui/window-manager:register-window
           *layer-manager*
           *window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *layer-manager*
           *window-id*)
          (toggle-01-register-commands)
          (toggle-01-register-shortcuts)
          (setf *toolbar* (toggle-01-create-toolbar window))
          #+nil(mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *toolbar*)
          #+nil(setf *widgets* widgets)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-widgets window)
          (toggle-01-sync-command-state)
          (mnas-sdl3-gui/widgets:move-widget-focus *widgets*))))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))

  (sdl3:set-render-draw-color *renderer* 240 240 240 255)
  (sdl3:render-clear *renderer*)

  (toggle-01-sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render
          *renderer*
          *toolbar*
          mnas-sdl3-gui/widgets:*widget-style*))

      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *widgets*)
        do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     *status*
                                     20.0 *status-y* '(40 40 40 255))

  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     "Click one toggle in each group to switch selection."
                                     20.0 (+ *status-y* 18.0) '(90 90 90 255))

  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let ((window-id (slot-value ev 'sdl3:%window-id))
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
      #+nil
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (let ((button (and *toolbar*
                                  (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                   *toolbar*
                                   mx
                                   my))))
                    (if button
                    (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                     *toolbar*
                     button
                     (list :window-id *window-id*))
                    (mnas-sdl3-gui/widgets:handle-mouse-button-event
                     *widgets* ev)))
                   (mnas-sdl3-gui/widgets:handle-mouse-button-event *widgets* ev))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *window-id*))
           (mnas-sdl3-gui/widgets:handle-keyboard-event
            *widgets*
            ev))
         (unless *open*
           (return-from callback-event :success)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit callback-quit (result)
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

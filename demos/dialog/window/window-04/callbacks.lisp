;;;; ./demos/dialog/window/window-04/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-04)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Transparent Window Demo" "1.0"
                         "com.mna.sdl3.gui.window-04-transparent.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))

  (setf *layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))

  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Transparent Window Demo"
                                       +width+
                                       +height+
                                       :transparent)
    (unless ok
      (format t "Failed to create transparent window: ~a~%" (sdl3:get-error))
      (return-from callback-init :failure))
    (setf *window* window
          *renderer* renderer
          *window-id* (sdl3:get-window-id window)
          *open* t)
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
    (setf *toolbar* (make-window-04-toolbar window))
    (window-04-apply-opacity)
    (window-04-sync-command-state)
    (mnas-sdl3-gui/widgets:init-ttf-font))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))
  (window-04-render-content)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (window-04-command :window-04/quit)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (window-04-handle-window-event (slot-value ev 'sdl3:%window-id))
         :continue)
       :continue)
      (sdl3:mouse-button-event
       (when (and (slot-value ev 'sdl3:%down)
                  (= (slot-value ev 'sdl3:%button) +mouse-left+))
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                           *layer-manager*
                                           window-id)
                                          window-id)
                                      window-id))
                (x (round (slot-value ev 'sdl3:%x)))
                (y (round (slot-value ev 'sdl3:%y))))
           (window-04-handle-mouse-event target-window-id x y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (let* ((event-window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:keyboard-target-window-id
                                           *layer-manager*
                                           event-window-id)
                                          event-window-id)
                                      event-window-id)))
           (when (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id target-window-id))
             (unless *open*
               (return-from callback-event :success)))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit callback-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

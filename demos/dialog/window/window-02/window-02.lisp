;;;; ./demos/dialog/window/window-02/window-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(sdl3:def-app-init window-02-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Popup Menu Window Demo" "1.0"
                         "com.mna.sdl3.gui.window-02-popup-menu.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from window-02-init :failure))

  (setf *layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))

  (multiple-value-bind (ok-main main-window main-renderer)
      (sdl3:create-window-and-renderer "Popup Menu Host Window"
                                       +main-width+
                                       +main-height+
                                       0)
    (unless ok-main
      (format t "Failed to create main window: ~a~%" (sdl3:get-error))
      (return-from window-02-init :failure))
    (setf *main-window* main-window
          *main-renderer* main-renderer
          *main-id* (sdl3:get-window-id main-window))
    (mnas-sdl3-gui/window-manager:register-window
     *layer-manager*
     *main-id*
     :main
     :open-p t))

  (let ((popup-window (sdl3:create-popup-window
                       *main-window*
                       0
                       0
                       +popup-width+
                       (window-02-popup-height)
                       :popup-menu)))
    (when (window-02-null-pointer-p popup-window)
      (format t "Failed to create popup-menu window: ~a~%" (sdl3:get-error))
      (return-from window-02-init :failure))
    (let ((popup-renderer (sdl3:create-renderer popup-window "")))
      (when (window-02-null-pointer-p popup-renderer)
        (format t "Failed to create popup-menu renderer: ~a~%" (sdl3:get-error))
        (return-from window-02-init :failure))
      (setf *popup-window* popup-window
            *popup-renderer* popup-renderer
            *popup-id* (sdl3:get-window-id popup-window)))
    (mnas-sdl3-gui/window-manager:register-window
     *layer-manager*
     *popup-id*
     :popup-menu
     :parent-id *main-id*
     :open-p nil))

  (mnas-sdl3-gui/widgets:init-ttf-font)
  (window-02-register-commands)
  (window-02-register-shortcuts)
  (setf *toolbar* (make-window-02-toolbar))
  (window-02-hide-popup)
  (setf *open* t
        *pin-popup* nil
        *selected-item* "No item selected")
  (window-02-sync-command-state)
  :continue)

(sdl3:def-app-iterate window-02-iterate ()
  (unless *open*
    (return-from window-02-iterate :success))
  (window-02-sync-command-state)
  (window-02-render-main)
  (window-02-render-popup)
  :continue)

(sdl3:def-app-event window-02-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (window-02-command :window-02/quit)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (window-02-handle-window-event (slot-value ev 'sdl3:%window-id))
         :continue)
       :continue)
      (sdl3:mouse-motion-event
       (window-02-handle-mouse-motion
        (slot-value ev 'sdl3:%window-id)
        (slot-value ev 'sdl3:%y))
       :continue)
      (sdl3:mouse-button-event
       (window-02-handle-mouse-event
        (slot-value ev 'sdl3:%window-id)
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y))
        (slot-value ev 'sdl3:%button)
        (slot-value ev 'sdl3:%down))
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
               (return-from window-02-event :success)))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit window-02-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *popup-renderer*
    (sdl3:destroy-renderer *popup-renderer*))
  (when *popup-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *popup-window* :layer-manager *layer-manager*))
  (when *main-renderer*
    (sdl3:destroy-renderer *main-renderer*))
  (when *main-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *main-window* :layer-manager *layer-manager*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

;;;; ./demos/dialog/window/window-03/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-03)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Transparent Window Demo" "1.0"
                         "com.mna.sdl3.gui.window-03-transparent.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))
  #+nil
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
    (register-commands)
    (register-shortcuts)
    (setf *toolbar* (make-toolbar window))
    (window-03-apply-opacity)
    (window-03-sync-command-state)
    (mnas-sdl3-gui/widgets:init-ttf-font))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))
  (window-03-render-content)
  :continue)

(sdl3:def-app-event callback-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (mnas-sdl3-gui/commands:execute-command :window-03/quit)
       :success)
      (sdl3:mouse-button-event
       (gui/widgets:handle-mouse-button-event (gui/widgets:widgets-for-window *window*) ev) :continue)
      (sdl3:keyboard-event
       (gui/widgets:handle-keyboard-event (gui/widgets:widgets-for-window *window*) ev) :continue)
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

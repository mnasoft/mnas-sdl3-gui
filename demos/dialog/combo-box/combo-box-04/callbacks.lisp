;;;; ./demos/dialog/combo-box/combo-box-04/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-04)

(sdl3:def-app-init combo-box-04-demo-init (argc argv)
  (declare (ignore argc argv))
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from combo-box-04-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Combo Box 04" 380 120 0)
    (unless ok
      (format t "create-window failed: ~A~%" (sdl3:get-error))
      (return-from combo-box-04-demo-init :failure))
    (setf *window* window
          *renderer* renderer
          *open* t)
    (mnas-sdl3-gui/widgets:set-widget-style :flat)
    (mnas-sdl3-gui/widgets:init-ttf-font)
    (let ((widgets (create-combo-box-04-widgets *window*)))
      (mnas-sdl3-gui/widgets:set-widget-focus widgets (first widgets)))
    :continue))

(sdl3:def-app-iterate combo-box-04-demo-iterate ()
  (unless *open*
    (return-from combo-box-04-demo-iterate :success))
    (sdl3:set-render-draw-color *renderer* 240 240 240 255)
    (sdl3:render-clear *renderer*)
    (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window *window*)))
      (when widgets
        (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order widgets)
          do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))))
  #+nil
  (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window *window*)))
    (mnas-sdl3-gui/widgets:render-text *renderer*
                                       (format nil "Selection: ~A"
                                               (and widgets (mnas-sdl3-gui/widgets:<widget>-value (first widgets))))
                                       20.0 90.0 '(80 80 80 255)))
  ;; popup windows are rendered via transient popup proxies appended by
  ;; `widgets-in-render-order', so no explicit popup calls are needed here.
  (sdl3:render-present *renderer*)
  :continue)

 (sdl3:def-app-event combo-box-04-demo-event (type event)
   (declare (ignore type))
   (let ((ev (sdl3:event-unmarshal event)))
     (typecase ev
       (sdl3:quit-event
        (setf *open* nil)
        :success)
       (sdl3:mouse-button-event
        (let* ((win-id (slot-value ev 'sdl3:%window-id))
               (down (slot-value ev 'sdl3:%down))
               (x (round (slot-value ev 'sdl3:%x)))
               (y (round (slot-value ev 'sdl3:%y)))
               (main-id (sdl3:get-window-id *window*))
               (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
          (format t "[demo event] mouse-button win-id=~S down=~A x=~D y=~D~%" win-id down x y)
          (cond
           ((and associated (not (= win-id main-id)))
            (dolist (w associated)
              (mnas-sdl3-gui/widgets:handle-mouse-button-event w ev)))
           ((and down (= win-id main-id))
            (mnas-sdl3-gui/widgets:handle-mouse-button-event
             (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev))))
        :continue)
       (sdl3:mouse-motion-event
        (let* ((win-id (slot-value ev 'sdl3:%window-id))
               (main-id (sdl3:get-window-id *window*))
               (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
          (cond
           ((and associated (not (= win-id main-id)))
            (dolist (w associated)
              (mnas-sdl3-gui/widgets:handle-mouse-motion-event w ev)))
           ((= win-id main-id)
            (mnas-sdl3-gui/widgets:handle-mouse-motion-event
             (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev))))
        :continue)
       (sdl3:mouse-wheel-event
        (let* ((win-id (slot-value ev 'sdl3:%window-id))
               (main-id (sdl3:get-window-id *window*))
               (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
          (cond
           ((and associated (not (= win-id main-id)))
            (dolist (w associated)
              (mnas-sdl3-gui/widgets:handle-mouse-wheel-event w ev)))
           ((= win-id main-id)
            (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
             (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev))))
        :continue)
       (sdl3:keyboard-event
        (when (and (slot-value ev 'sdl3:%down)
                   (not (slot-value ev 'sdl3:%repeat)))
          (mnas-sdl3-gui/widgets:handle-widget-key-event
           (mnas-sdl3-gui/widgets:widgets-for-window *window*)
           (slot-value ev 'sdl3:%key)
           nil
           :mods (slot-value ev 'sdl3:%mod)))
        :continue)
       (t :continue))))

(sdl3:def-app-quit combo-box-04-demo-quit (result)
  (declare (ignore result))
  (let ((widgets (and *window* (mnas-sdl3-gui/widgets:widgets-for-window *window*))))
    (when widgets
      (dolist (w widgets)
        (when (typep w 'mnas-sdl3-gui/widgets:<combo-box>)
          (mnas-sdl3-gui/widgets:combo-box-disable-popup-window w)))))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit)
  :success)

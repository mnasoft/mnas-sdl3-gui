(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(sdl3:def-app-init combo-box-01-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Combo-Box Demo" "1.0"
                         "com.mna.sdl3.gui.combo-box.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from combo-box-01-init :failure))
  (setf *layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Combo-Box Demo" 620 +combo-box-01-window-height+ 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from combo-box-01-init :failure))
        (progn
          (setf *window* window
                *window-id* (sdl3:get-window-id window)
                *renderer* renderer
                *open* t
                *status* "Use mouse, arrows, PgUp/PgDown, Return and Escape.")
              (mnas-sdl3-gui/window-manager:register-window
               *layer-manager*
               *window-id*
               :main
               :open-p t)
          (combo-box-01-register-commands)
          (combo-box-01-register-shortcuts)
          (setf *toolbar* (combo-box-01-create-toolbar window))
          #+nil (mnas-sdl3-gui/widgets:register-toolbar-for-command-updates *toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-combo-box-01-widgets window)
          (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
           *small*
           *window*
           :layer-manager *layer-manager*)
          (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
           *large*
           *window*
           :layer-manager *layer-manager*)
          (mnas-sdl3-gui/widgets:set-widget-focus
           (mnas-sdl3-gui/widgets:widgets-for-window *window*)
           *small*))))
  :continue)

(sdl3:def-app-iterate combo-box-01-iterate ()
  (unless *open*
    (return-from combo-box-01-iterate :success))
  (sdl3:set-render-draw-color *renderer* 240 240 240 255)
  (sdl3:render-clear *renderer*)
  (combo-box-01-sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render
     *renderer*
     *toolbar*
     mnas-sdl3-gui/widgets:*widget-style*))
  (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window *window*)))
    (when widgets
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order widgets)
        do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))))
  ;; popup windows are rendered via transient popup proxies appended by
  ;; `widgets-in-render-order', so no explicit popup calls are needed here.
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     *status*
                                     20.0 252.0 '(40 40 40 255))
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event combo-box-01-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:window-event
       (let* ((window-id (slot-value ev 'sdl3:%window-id))
              (main-id (and *window* (sdl3:get-window-id *window*)))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id window-id)))
         (when (and (eq (slot-value ev 'sdl3:%type) :window-close-requested)
                    associated
                    (not (= window-id main-id)))
           (dolist (widget associated)
             (mnas-sdl3-gui/widgets:sync-combo-box-expanded-state widget nil))))
       :continue)
      (sdl3:mouse-motion-event
       (let* ((window-id (slot-value ev 'sdl3:%window-id))
              (main-id (and *window* (sdl3:get-window-id *window*)))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id window-id))
              (mx (round (slot-value ev 'sdl3:%x)))
              (my (round (slot-value ev 'sdl3:%y))))
         (cond
          ((and associated (not (= window-id main-id)))
            (dolist (widget associated)
              (mnas-sdl3-gui/widgets:handle-mouse-motion-event widget ev)))
           ((= window-id main-id)
            (mnas-sdl3-gui/widgets:handle-mouse-motion-event
             (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev))))
       :continue)
      (sdl3:mouse-button-event
       #+nil (mnas-sdl3-gui/widgets:handle-mouse-button-event *toolbar* ev)
       (mnas-sdl3-gui/widgets:handle-mouse-button-event
        (mnas-sdl3-gui/widgets:widgets-for-window *window*) ev)
       (let* ((window-id (slot-value ev 'sdl3:%window-id))
              (main-id (and *window* (sdl3:get-window-id *window*)))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id window-id))
              (down (slot-value ev 'sdl3:%down))
              (mx (round (slot-value ev 'sdl3:%x)))
              (my (round (slot-value ev 'sdl3:%y)))
              (toolbar-y-offset (- +combo-box-01-window-height+ +combo-box-01-toolbar-height+)))
         (mnas-debug:%log "window-id:~A~%" window-id)
         (mnas-debug:%log "main-id:~A~%"   main-id)
         (mnas-debug:%log "associated:~S~%" associated)
         (when (= (slot-value ev 'sdl3:%button) 1)
           (cond
             ((and associated (not (= window-id main-id)))
              (dolist (widget associated)
                (if down
                    (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down widget mx my)
                    (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up widget mx my))))
             ((and (not down) (= window-id main-id))
              (mnas-sdl3-gui/widgets:handle-mouse-button-event
               (mnas-sdl3-gui/widgets:widgets-for-window *window*)
               ev)))
           :continue)))
      (sdl3:mouse-wheel-event
       (let* ((window-id (slot-value ev 'sdl3:%window-id))
              (main-id (and *window* (sdl3:get-window-id *window*)))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id window-id))
              (dy (round (slot-value ev 'sdl3:%y)))
              (mx (round (slot-value ev 'sdl3:%mouse-x)))
              (my (round (slot-value ev 'sdl3:%mouse-y)))
              (x (round (slot-value ev 'sdl3:%x)))
              (y (round (slot-value ev 'sdl3:%y))))
            (cond
           ((and associated (not (= window-id main-id)))
            (dolist (widget associated)
              (mnas-sdl3-gui/widgets:handle-mouse-wheel-event widget ev)))
           ((= window-id main-id)
            (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
             (mnas-sdl3-gui/widgets:widgets-for-window *window*)
             ev))))
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

(sdl3:def-app-quit combo-box-01-quit (result)
  #+nil (declare (ignore result))
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *small*)
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *large*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

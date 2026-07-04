(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defvar *combo-box-01-current-application* nil)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (let ((app *combo-box-01-current-application*))
    (unless app
      (return-from callback-init :failure))
    (sdl3:set-app-metadata (mnas-sdl3-gui/app:<app>-title app) "1.0"
                           "com.mna.sdl3.gui.combo-box.demo")
    (unless (sdl3:init :video)
      (format t "~a~%" (sdl3:get-error))
      (return-from callback-init :failure))
    (let ((layer-manager (mnas-sdl3-gui/window-manager:make-window-layer-manager)))
      (setf (mnas-sdl3-gui/app:<app>-layer-manager app) layer-manager)
      (multiple-value-bind (ok window renderer)
          (sdl3:create-window-and-renderer
           (mnas-sdl3-gui/app:<app>-title app)
           (mnas-sdl3-gui/app:<app>-width app)
           (mnas-sdl3-gui/app:<app>-height app)
           0)
        (if ok
            (let ((window-id (sdl3:get-window-id window))
                  (status "Use mouse, arrows, PgUp/PgDown, Return and Escape."))
              (setf (mnas-sdl3-gui/app:<app>-window app) window
                    (mnas-sdl3-gui/app:<app>-window-id app) window-id
                    (mnas-sdl3-gui/app:<app>-renderer app) renderer
                    (mnas-sdl3-gui/app:<app>-open-p app) t
                    (mnas-sdl3-gui/app:<app>-status app) status)
              (mnas-sdl3-gui/window-manager:register-window
               layer-manager
               window-id
               :main
               :open-p t)
              (combo-box-01-register-commands app)
              (combo-box-01-register-shortcuts)
              (setf (mnas-sdl3-gui/app:<app>-toolbar app) (combo-box-01-create-toolbar window))
              (mnas-sdl3-gui/widgets:set-widget-style (mnas-sdl3-gui/app:<app>-style app))
              (mnas-sdl3-gui/widgets:init-ttf-font)
              (create-widgets app window)
              (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
               (<combo-box-01-app>-small-widget app)
               window
               :layer-manager layer-manager)
              (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
               (combo-box-01-large-widget app)
               window
               :layer-manager layer-manager)
              (mnas-sdl3-gui/widgets:set-widget-focus
               (mnas-sdl3-gui/widgets:widgets-for-window window)
               (<combo-box-01-app>-small-widget app))
              :continue)
            (progn
              (format t "~a~%" (sdl3:get-error))
              :failure))))))

(sdl3:def-app-iterate callback-iterate ()
  (let ((app *combo-box-01-current-application*))
    (unless app
      (return-from callback-iterate :success))
    (unless (mnas-sdl3-gui/app:<app>-open-p app)
      (return-from callback-iterate :success))
    (let ((renderer (mnas-sdl3-gui/app:<app>-renderer app))
          (window (mnas-sdl3-gui/app:<app>-window app))
          (toolbar (mnas-sdl3-gui/app:<app>-toolbar app))
          (status (mnas-sdl3-gui/app:<app>-status app)))
      (sdl3:set-render-draw-color renderer 240 240 240 255)
      (sdl3:render-clear renderer)
      (sync-command-state app)
      (when toolbar
        (mnas-sdl3-gui/widgets:render
         renderer
         toolbar
         mnas-sdl3-gui/widgets:*widget-style*))
      (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window window)))
        (when widgets
          (loop :for widget :in (mnas-sdl3-gui/widgets:widgets-in-render-order widgets)
                do (mnas-sdl3-gui/widgets:render renderer widget mnas-sdl3-gui/widgets:*widget-style*))))
      (mnas-sdl3-gui/widgets:render-text
       renderer
       status
       20.0 252.0 '(40 40 40 255))
      (sdl3:render-present renderer)))
  :continue)

(sdl3:def-app-event callback-event (event-type event)
  (declare (ignore event-type))
  (let ((app *combo-box-01-current-application*))
    (unless app
      (return-from callback-event :continue))
    (let* ((window (mnas-sdl3-gui/app:<app>-window app))
           (ev (sdl3:event-unmarshal event))
           (main-id (and window (sdl3:get-window-id window)))
           (event-window-id (ignore-errors (slot-value ev 'sdl3:%window-id))))
      (typecase ev
        (sdl3:quit-event
         (setf (mnas-sdl3-gui/app:<app>-open-p app) nil)
         :success)
        (sdl3:window-event
         (let* ((associated (and event-window-id
                                 (mnas-sdl3-gui/widgets:widgets-for-window-id event-window-id))))
           (when (and (eq (slot-value ev 'sdl3:%type) :window-close-requested)
                      associated
                      event-window-id
                      (not (= event-window-id main-id)))
             (dolist (widget associated)
               (mnas-sdl3-gui/widgets:sync-combo-box-expanded-state widget nil)))
           :continue))
        (sdl3:mouse-motion-event
         (let* ((associated (and event-window-id
                                 (mnas-sdl3-gui/widgets:widgets-for-window-id event-window-id)))
                (mx (ignore-errors (round (slot-value ev 'sdl3:%x))))
                (my (ignore-errors (round (slot-value ev 'sdl3:%y)))))
           (declare (ignore mx my))
           (cond
             ((and associated event-window-id (not (= event-window-id main-id)))
              (dolist (widget associated)
                (mnas-sdl3-gui/widgets:handle-mouse-motion-event widget ev)))
             ((and event-window-id (= event-window-id main-id))
              (mnas-sdl3-gui/widgets:handle-mouse-motion-event
               (mnas-sdl3-gui/widgets:widgets-for-window window) ev)))
           :continue))
        (sdl3:mouse-button-event
         (let* ((associated (and event-window-id
                                 (mnas-sdl3-gui/widgets:widgets-for-window-id event-window-id)))
                (down (ignore-errors (slot-value ev 'sdl3:%down)))
                (mx   (ignore-errors (round (slot-value ev 'sdl3:%x))))
                (my   (ignore-errors (round (slot-value ev 'sdl3:%y)))))
           (declare (ignore mx my))
           (mnas-sdl3-gui/widgets:handle-mouse-button-event
            (mnas-sdl3-gui/widgets:widgets-for-window window) ev)
           (when (and (= (ignore-errors (slot-value ev 'sdl3:%button)) 1)
                      event-window-id)
             (cond
               ((and associated (not (= event-window-id main-id)))
                (dolist (widget associated)
                  (if down
                      (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down widget mx my)
                      (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up widget mx my))))
               ((and (not down) (= event-window-id main-id))
                (mnas-sdl3-gui/widgets:handle-mouse-button-event
                 (mnas-sdl3-gui/widgets:widgets-for-window window)
                 ev))))
           :continue))
        (sdl3:mouse-wheel-event
         (let* ((associated (and event-window-id
                                 (mnas-sdl3-gui/widgets:widgets-for-window-id event-window-id)))
                (dy (ignore-errors (round (slot-value ev 'sdl3:%y))))
                (mx (ignore-errors (round (slot-value ev 'sdl3:%mouse-x))))
                (my (ignore-errors (round (slot-value ev 'sdl3:%mouse-y)))))
           (declare (ignore dy mx my))
           (cond
             ((and associated event-window-id (not (= event-window-id main-id)))
              (dolist (widget associated)
                (mnas-sdl3-gui/widgets:handle-mouse-wheel-event widget ev)))
             ((and event-window-id (= event-window-id main-id))
              (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
               (mnas-sdl3-gui/widgets:widgets-for-window window)
               ev)))
           :continue))
        (sdl3:keyboard-event
         (when (and (ignore-errors (slot-value ev 'sdl3:%down))
                    (not (ignore-errors (slot-value ev 'sdl3:%repeat))))
           (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                    (ignore-errors (slot-value ev 'sdl3:%key))
                    :mods (ignore-errors (slot-value ev 'sdl3:%mod))
                    :context (list :window-id (mnas-sdl3-gui/app:<app>-window-id app)))
             (mnas-sdl3-gui/widgets:handle-keyboard-event
              (mnas-sdl3-gui/widgets:widgets-for-window window)
              ev)))
         :continue)
        (t :continue)))))

(sdl3:def-app-quit callback-quit (result)
  (let ((app *combo-box-01-current-application*))
    (when app
      (setf (mnas-sdl3-gui/app:<app>-result app) result)
      (mnas-sdl3-gui/app:finalize-application app result))
    (mnas-sdl3-gui/app:run-quit-hooks result)
    (sdl3:pump-events)
    (sdl3:quit-sub-system :video)
    (sdl3:quit)))

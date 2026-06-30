;;;; ./demos/dialog/window/window-01/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

(sdl3:def-app-init callback-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata *demo-title* "1.0"
                         "com.mna.sdl3.gui.window.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from callback-init :failure))

  (setf *layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))

  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer *demo-title*
                                       *width*
                                       *height*
                                       (flags-as-list))
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from callback-init :failure))
        (progn
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
          (setf *toolbar* (make-toolbar))
          (sync-command-state)
          (mnas-sdl3-gui/widgets:init-ttf-font))))
  :continue)

(sdl3:def-app-iterate callback-iterate ()
  (unless *open*
    (return-from callback-iterate :success))
  (update-window-size)
  (sync-command-state)
  (sdl3:set-render-draw-color *renderer* 32 34 37 255)
  (sdl3:render-clear *renderer*)

  (when *show-grid*
    (sdl3:set-render-draw-color *renderer* 44 48 54 255)
    (loop for x from 0 below *width* by 24
          do (sdl3:render-line *renderer*
                               (float x 1.0) 0.0
                               (float x 1.0) (float *height* 1.0)))
    (loop for y from 0 below *height* by 24
          do (sdl3:render-line *renderer*
                               0.0 (float y 1.0)
                               (float *width* 1.0) (float y 1.0))))

  (mnas-sdl3-gui/widgets:render-text *renderer*
                                      *demo-title*
                                      24.0 24.0 '(220 220 220 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     (format nil "Size: ~Dx~D"
                                             *width*
                                             *height*)
                                     24.0 56.0 '(180 180 180 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     (format nil "Flags: ~{~S~^ ~}"
                                             (flags-as-list))
                                     24.0 96.0 '(160 160 160 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     "M: open modal-1  N: open modal-2  Backspace/Escape: close top modal"
                                     24.0 128.0 '(160 160 160 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     "Escape with empty stack exits demo."
                                     24.0 152.0 '(160 160 160 255))

  (mnas-sdl3-gui/widgets:render-toolbar
   *toolbar*
   *renderer*
   +toolbar-x+
   +toolbar-y+)

  (when *layer-manager*
    (mnas-sdl3-gui/widgets:render-text
     *renderer*
     (format nil "Focused: ~A  Active modal: ~A  Trap: ~A"
             (or (mnas-sdl3-gui/window-manager:focused-window-id *layer-manager*) :none)
             (or (mnas-sdl3-gui/window-manager:active-modal-id *layer-manager*) :none)
             (if (mnas-sdl3-gui/window-manager:modal-trap-active-p *layer-manager*) :on :off))
     24.0 184.0 '(246 214 102 255)))

  (when *modal-1-open*
    (sdl3:set-render-draw-color *renderer* 48 62 96 255)
    (sdl3:render-fill-rect *renderer*
                           (make-instance 'sdl3:frect :%x 120.0 :%y 210.0 :%w 380.0 :%h 100.0))
    (mnas-sdl3-gui/widgets:render-text *renderer*
                                       "Modal-1 active"
                                       140.0 236.0 '(232 240 255 255)))

  (when *modal-2-open*
    (sdl3:set-render-draw-color *renderer* 86 52 98 255)
    (sdl3:render-fill-rect *renderer*
                           (make-instance 'sdl3:frect :%x 190.0 :%y 236.0 :%w 260.0 :%h 86.0))
    (mnas-sdl3-gui/widgets:render-text *renderer*
                                       "Modal-2 active (nested)"
                                       208.0 262.0 '(255 238 255 255)))

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
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *layer-manager*
                              window-id))))
           (declare (ignore action))
           (unless (close-top-modal)
             (setf *open* nil)
             (return-from callback-event :success))))
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
           (when *layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *layer-manager*
              target-window-id))
           (when (and (= target-window-id *window-id*)
                      (>= x (round +toolbar-x+))
                      (<= x (+ (round +toolbar-x+) (round +toolbar-width+)))
                      (>= y (round +toolbar-y+))
                      (<= y (+ (round +toolbar-y+) (round +toolbar-height+))))
             (let ((button (mnas-sdl3-gui/widgets:toolbar-buttons-at-position
                            *toolbar*
                            (- x (round +toolbar-x+))
                            (- y (round +toolbar-y+)))))
               (when button
                 (mnas-sdl3-gui/widgets:toolbar-button-clicked
                  *toolbar*
                  button
                  (list :window-id target-window-id)))))))
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
           (when *layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *layer-manager*
              target-window-id))
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

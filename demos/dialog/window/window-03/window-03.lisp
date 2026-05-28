;;;; ./demos/dialog/window/window-03/window-03.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-03)

(defparameter *window-03-window* nil)
(defparameter *window-03-renderer* nil)
(defparameter *window-03-window-id* 0)
(defparameter *window-03-layer-manager* nil)
(defparameter *window-03-toolbar* nil)
(defparameter *window-03-open* t)
(defparameter *window-03-opacity* 0.82)
(defparameter *window-03-frost* t)

(defparameter +window-03-width+ 680)
(defparameter +window-03-height+ 360)
(defparameter +window-03-default-opacity+ 0.82)
(defparameter +window-03-opacity-step+ 0.05)
(defparameter +window-03-toolbar-x+ 28.0)
(defparameter +window-03-toolbar-y+ 22.0)
(defparameter +window-03-mouse-left+ 1)

(defun make-window-03-toolbar ()
  "Create toolbar with commands reflecting full-state behavior." 
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar :layout :horizontal :height 40)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :window-03/decrease-opacity :label "-" :width 34)
           (mnas-sdl3-gui/toolbar:make-button-spec :window-03/increase-opacity :label "+" :width 34)
           (mnas-sdl3-gui/toolbar:make-button-spec :window-03/reset-opacity :label "Reset" :width 62)
           (mnas-sdl3-gui/toolbar:make-button-spec :window-03/toggle-frost :label "Frost" :width 62 :type :toggle)
           (mnas-sdl3-gui/toolbar:make-button-spec :window-03/quit :label "Quit" :width 52)))
    toolbar))

(defun window-03-sync-command-state ()
  "Sync dynamic visible/checked command state for toolbar rendering." 
  (let ((reset-cmd (mnas-sdl3-gui/commands:find-command :window-03/reset-opacity))
        (frost-cmd (mnas-sdl3-gui/commands:find-command :window-03/toggle-frost)))
    (when reset-cmd
      (mnas-sdl3-gui/commands:set-command-visible reset-cmd
                                                  (> (abs (- *window-03-opacity* +window-03-default-opacity+)) 0.001)))
    (when frost-cmd
      (mnas-sdl3-gui/commands:set-command-checked frost-cmd *window-03-frost*))))

(defun window-03-clamp-opacity (value)
  (min 1.0 (max 0.15 value)))

(defun window-03-apply-opacity ()
  (when *window-03-window*
    (setf *window-03-opacity* (window-03-clamp-opacity *window-03-opacity*))
    (sdl3:set-window-opacity *window-03-window* *window-03-opacity*)))

(sdl3:def-app-init window-03-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Transparent Window Demo" "1.0"
                         "com.mna.sdl3.gui.window-03-transparent.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from window-03-init :failure))

  (setf *window-03-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))

  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Transparent Window Demo"
                                       +window-03-width+
                                       +window-03-height+
                                       :transparent)
    (unless ok
      (format t "Failed to create transparent window: ~a~%" (sdl3:get-error))
      (return-from window-03-init :failure))
    (setf *window-03-window* window
          *window-03-renderer* renderer
          *window-03-window-id* (sdl3:get-window-id window)
          *window-03-open* t)
        (mnas-sdl3-gui/window-manager:register-window
         *window-03-layer-manager*
         *window-03-window-id*
         :main
         :open-p t)
        (mnas-sdl3-gui/window-manager:set-focused-window
         *window-03-layer-manager*
         *window-03-window-id*)
        (window-03-register-commands)
        (window-03-register-shortcuts)
        (setf *window-03-toolbar* (make-window-03-toolbar))
        (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *window-03-toolbar*)
    (window-03-apply-opacity)
        (window-03-sync-command-state)
    (mnas-sdl3-gui/widgets:init-ttf-font))
  :continue)

(sdl3:def-app-iterate window-03-iterate ()
  (unless *window-03-open*
    (return-from window-03-iterate :success))

  ;; Full clear with alpha 0 keeps the window content transparent where nothing is drawn.
  (sdl3:set-render-draw-color *window-03-renderer* 0 0 0 0)
  (sdl3:render-clear *window-03-renderer*)

  (window-03-sync-command-state)

  (sdl3:set-render-draw-color
   *window-03-renderer*
   (if *window-03-frost* 24 34)
   (if *window-03-frost* 30 44)
   (if *window-03-frost* 40 58)
   220)
  (sdl3:render-fill-rect
   *window-03-renderer*
   (make-instance 'sdl3:frect :%x 28.0 :%y 72.0 :%w 624.0 :%h 266.0))
  (sdl3:set-render-draw-color *window-03-renderer* 90 160 245 255)
  (sdl3:render-rect
   *window-03-renderer*
   (make-instance 'sdl3:frect :%x 28.0 :%y 72.0 :%w 624.0 :%h 266.0))
  (mnas-sdl3-gui/toolbar:render-toolbar
   *window-03-toolbar*
   *window-03-renderer*
   +window-03-toolbar-x+
   +window-03-toolbar-y+)

  (mnas-sdl3-gui/widgets:render-text
   *window-03-renderer*
   "Transparent Window Demo (:transparent)"
   48.0 98.0 '(230 240 255 255))
  (mnas-sdl3-gui/widgets:render-text
   *window-03-renderer*
   "Toolbar/full-state: + - Reset Frost Quit"
   48.0 126.0 '(182 206 245 255))
  (mnas-sdl3-gui/widgets:render-text
   *window-03-renderer*
   (format nil "Window opacity: ~,2f" *window-03-opacity*)
   48.0 154.0 '(255 224 132 255))
  (mnas-sdl3-gui/widgets:render-text
   *window-03-renderer*
   "Behind this panel desktop should remain visible."
   48.0 184.0 '(196 210 220 255))
  (sdl3:render-present *window-03-renderer*)
  :continue)

(sdl3:def-app-event window-03-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (window-03-command :window-03/quit)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *window-03-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *window-03-layer-manager*
                              window-id))))
           (case action
             (:close-root
              (window-03-command :window-03/quit)
              (return-from window-03-event :success))
             (otherwise
              (window-03-command :window-03/quit)
              (return-from window-03-event :success)))))
       :continue)
      (sdl3:mouse-button-event
       (when (and (slot-value ev 'sdl3:%down)
                  (= (slot-value ev 'sdl3:%button) +window-03-mouse-left+))
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *window-03-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                           *window-03-layer-manager*
                                           window-id)
                                          window-id)
                                      window-id))
                (x (round (slot-value ev 'sdl3:%x)))
                (y (round (slot-value ev 'sdl3:%y))))
           (when *window-03-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *window-03-layer-manager*
              target-window-id))
           (when (= target-window-id *window-03-window-id*)
             (let ((button (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                            *window-03-toolbar*
                            (- x (round +window-03-toolbar-x+))
                            (- y (round +window-03-toolbar-y+)))))
               (when button
                 (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                  *window-03-toolbar*
                  button
                  (list :window-id target-window-id)))))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (let* ((event-window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *window-03-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:keyboard-target-window-id
                                           *window-03-layer-manager*
                                           event-window-id)
                                          event-window-id)
                                      event-window-id)))
           (when *window-03-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *window-03-layer-manager*
              target-window-id))
           (when (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id target-window-id))
             (unless *window-03-open*
               (return-from window-03-event :success)))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit window-03-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *window-03-renderer*
    (sdl3:destroy-renderer *window-03-renderer*))
  (when *window-03-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window-03-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun window-03 ()
  "Run dedicated demo for :transparent window flag." 
  (setf *window-03-window* nil
        *window-03-renderer* nil
        *window-03-window-id* 0
        *window-03-layer-manager* nil
        *window-03-toolbar* nil
        *window-03-open* t
        *window-03-opacity* +window-03-default-opacity+
        *window-03-frost* t)
  (sdl3:enter-app-main-callbacks
   'window-03-init
   'window-03-iterate
   'window-03-event
   'window-03-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-03)
;;;; (window-03)

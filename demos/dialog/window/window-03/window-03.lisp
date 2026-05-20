;;;; ./demos/dialog/window/window-03/window-03.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-03)

(defparameter *window-03-window* nil)
(defparameter *window-03-renderer* nil)
(defparameter *window-03-window-id* 0)
(defparameter *window-03-layer-manager* nil)
(defparameter *window-03-open* t)
(defparameter *window-03-opacity* 0.82)

(defparameter +window-03-width+ 680)
(defparameter +window-03-height+ 360)
(defparameter +window-03-opacity-step+ 0.05)

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
    (window-03-apply-opacity)
    (mnas-sdl3-gui/widgets:init-ttf-font))

  :continue)

(sdl3:def-app-iterate window-03-iterate ()
  (unless *window-03-open*
    (return-from window-03-iterate :success))

  ;; Full clear with alpha 0 keeps the window content transparent where nothing is drawn.
  (sdl3:set-render-draw-color *window-03-renderer* 0 0 0 0)
  (sdl3:render-clear *window-03-renderer*)

  (sdl3:set-render-draw-color *window-03-renderer* 24 30 40 220)
  (sdl3:render-fill-rect *window-03-renderer*
                         (make-instance 'sdl3:frect :%x 28.0 :%y 22.0 :%w 624.0 :%h 316.0))
  (sdl3:set-render-draw-color *window-03-renderer* 90 160 245 255)
  (sdl3:render-rect *window-03-renderer*
                    (make-instance 'sdl3:frect :%x 28.0 :%y 22.0 :%w 624.0 :%h 316.0))

  (mnas-sdl3-gui/widgets:render-text *window-03-renderer*
                                     "Transparent Window Demo (:transparent)"
                                     48.0 52.0 '(230 240 255 255))
  (mnas-sdl3-gui/widgets:render-text *window-03-renderer*
                                     "Up/Down: opacity   Escape: exit"
                                     48.0 92.0 '(182 206 245 255))
  (mnas-sdl3-gui/widgets:render-text *window-03-renderer*
                                     (format nil "Window opacity: ~,2f" *window-03-opacity*)
                                     48.0 132.0 '(255 224 132 255))
  (mnas-sdl3-gui/widgets:render-text *window-03-renderer*
                                     "Behind this panel desktop should remain visible."
                                     48.0 172.0 '(196 210 220 255))

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
    (sdl3:destroy-window *window-03-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun window-03 ()
  "Run dedicated demo for :transparent window flag." 
  (setf *window-03-window* nil
        *window-03-renderer* nil
    *window-03-window-id* 0
    *window-03-layer-manager* nil
        *window-03-open* t
        *window-03-opacity* 0.82)
  (sdl3:enter-app-main-callbacks
   'window-03-init
   'window-03-iterate
   'window-03-event
   'window-03-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-03)
;;;; (mnas-sdl3-gui/demos/dialog/window-03:window-03)

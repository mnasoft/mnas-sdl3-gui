;;;; ./demos/dialog/toolbar/toolbar-demo/toolbar-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toolbar-demo)

(defun make-toolbar-demo-widget (window)
  (let ((tb (make-instance 'mnas-sdl3-gui/widgets:toolbar
                           :layout :horizontal
                           :height 34
                           :window window
                           )))
    (setf (mnas-sdl3-gui/widgets:widget-children tb)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button
                          :command-id :toolbar/demo-new
                          :label "New"
                          :width 66
                          :height 32
                          :window window
                          )
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button
                          :command-id :toolbar/demo-open
                          :label "Open"
                          :width 70
                          :height 32
                          :window window
                          )
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button
                          :command-id :toolbar/demo-quit
                          :label "Quit"
                          :width 64
                          :height 32
                          :window window)))
    tb))

(sdl3:def-app-init toolbar-demo-init (argc argv)
  (declare (ignore argc argv))
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from toolbar-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Toolbar Demo" 420 110 0)
    (unless ok
      (format t "create-window failed: ~A~%" (sdl3:get-error))
      (return-from toolbar-demo-init :failure))
    (setf *window* window
          *renderer* renderer
          *toolbar* (make-toolbar-demo-widget window)
          *open* t)
    (register-toolbar-demo-commands)
    (mnas-sdl3-gui/widgets:set-widget-style :flat)
    (mnas-sdl3-gui/widgets:init-ttf-font)
    :continue))

(sdl3:def-app-iterate toolbar-demo-iterate ()
  (unless *open*
    (return-from toolbar-demo-iterate :success))
  (sdl3:set-render-draw-color *renderer* 242 242 242 255)
  (sdl3:render-clear *renderer*)
  (mnas-sdl3-gui/widgets:render *renderer* *toolbar* mnas-sdl3-gui/widgets:*widget-style*) 
  
  (mnas-sdl3-gui/widgets:render-text
   *renderer*
   "Toolbar demo (style like combo-box-04)"
   12.0 64.0 '(80 80 80 255))
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event toolbar-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:mouse-button-event
       (mnas-sdl3-gui/widgets:handle-mouse-button-event
              (mnas-sdl3-gui/widgets:widgets-for-window *window*)
              ev)
       :continue)
      (t :continue))))

(sdl3:def-app-quit toolbar-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (sdl3:destroy-window *window*))
  (sdl3:quit)
  :success)

(defun toolbar-demo ()
  "Run toolbar demo."
  (sdl3:enter-app-main-callbacks
   'toolbar-demo-init
   'toolbar-demo-iterate
   'toolbar-demo-event
   'toolbar-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/toolbar-demo)
;;;; (toolbar-demo)

;;;; (setf (mnas-sdl3-gui/widgets:widget-visible *toolbar*) t)
;;;; (setf (mnas-sdl3-gui/widgets:widget-x  *toolbar*) 50)
;;;; (setf (mnas-sdl3-gui/widgets:widget-y  *toolbar*) 50)

;;;; ./demos/canvas/canvas-window-demo.lisp

(in-package :mnas-sdl3-gui/demos/canvas)

(defparameter *demo-canvas-window* nil)
(defparameter *demo-canvas-running* nil)

(sdl3:def-app-init demo-canvas-window-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Canvas Window Demo" "0.1" "com.mna.sdl3.gui.canvas-window")
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from demo-canvas-window-init :failure))
  (mnas-sdl3-gui/widgets:init-ttf-font)
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Canvas Demo" 640 480 0)
    (unless ok
      (format t "create-window failed: ~A~%" (sdl3:get-error))
      (return-from demo-canvas-window-init :failure))
    (let ((canvas (make-canvas-demo :w 640 :h 480)))
      (setf *demo-canvas-window* (list :window window :renderer renderer :canvas canvas))
      (setf *demo-canvas-running* t)))
  :continue)

(sdl3:def-app-iterate demo-canvas-window-iterate ()
  (unless *demo-canvas-running*
    (return-from demo-canvas-window-iterate :success))
  (let* ((entry *demo-canvas-window*)
         (renderer (getf entry :renderer))
         (canvas (getf entry :canvas)))
        (sdl3:set-render-draw-color renderer 240 240 240 255)
        (sdl3:render-clear renderer)
            (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order (list canvas))
              do (mnas-sdl3-gui/widgets:render renderer widget mnas-sdl3-gui/widgets:*widget-style*))
    (sdl3:render-present renderer))
  :continue)

(sdl3:def-app-event demo-canvas-window-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *demo-canvas-running* nil)
       :success)
      (t :continue))))

(defun run-demo-canvas-window ()
  "Start the canvas window demo.
Pass the callback symbol to `sdl3:run-app` so CFFI can resolve it." 
  (sdl3:run-app 'demo-canvas-window-init))

;;;; (ql:quickload :mnas-sdl3-gui/demos/canvas)
;;;; (mnas-sdl3-gui/demos/canvas::run-demo-canvas-window)

;;;; ./demos/input-events/input-events-demo.lisp

(in-package :mnas-sdl3-gui/demos/input-events)

(defparameter *input-demo-window* nil)
(defparameter *input-demo-running* nil)

(sdl3:def-app-init input-events-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Input Events Demo" "0.1" "com.mna.sdl3.gui.input-events")
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from input-events-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Input Events Demo" 640 480 0)
    (unless ok
      (format t "create-window failed: ~A~%" (sdl3:get-error))
      (return-from input-events-init :failure))
    (setf *input-demo-window* (list :window window :renderer renderer))
    (setf *input-demo-running* t))
  :continue)

(sdl3:def-app-iterate input-events-iterate ()
  (unless *input-demo-running*
    (return-from input-events-iterate :success))
  (let ((renderer (getf *input-demo-window* :renderer)))
    (sdl3:set-render-draw-color renderer 200 200 200 255)
    (sdl3:render-clear renderer)
    (sdl3:render-present renderer))
  :continue)

(sdl3:def-app-event input-events-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *input-demo-running* nil)
       :success)
      (t
       ;; update tracker and print human-readable log
       (mnas-sdl3-gui/events:update-from-sdl-event ev)
       (mnas-sdl3-gui/events:log-event ev)
       :continue))))

(sdl3:def-app-quit input-events-quit (result)
  (declare (ignore result))
  (when *input-demo-window*
    (sdl3:destroy-renderer (getf *input-demo-window* :renderer))
    (sdl3:destroy-window (getf *input-demo-window* :window)))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun run-input-events-demo (&optional (style :windows))
  "Start the input events demo.
Call `(sdl3:run-app 'input-events-init)` or quickload the file and
call this function."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'input-events-init
   'input-events-iterate
   'input-events-event
   'input-events-quit)
  #+nil
  (sdl3:run-app 'input-events-init)
  :done
  )

;;;; Usage:
;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos/input-events)

;;;; (mnas-sdl3-gui/demos/input-events:run-input-events-demo)
;;;; (run-input-events-demo)

;;;; ./demos/dialog/window/window-01/window-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

(defparameter *window-01-window* nil)
(defparameter *window-01-renderer* nil)
(defparameter *window-01-open* t)
(defparameter *window-01-width* 640)
(defparameter *window-01-height* 360)

(defun update-window-01-window-size ()
  "Query current window client size and update demo state."
  (when *window-01-window*
    (multiple-value-bind (ok width height)
        (sdl3:get-window-size *window-01-window*)
      (when ok
        (setf *window-01-width* width
              *window-01-height* height)))))

(sdl3:def-app-init window-01-window-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Resizable Window Demo" "1.0"
                         "com.mna.sdl3.gui.window-01-window.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from window-01-window-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Resizable Window Demo"
                                       *window-01-width*
                                       *window-01-height*
                                       :resizable)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from window-01-window-demo-init :failure))
        (progn
          (setf *window-01-window* window
                *window-01-renderer* renderer
                *window-01-open* t)
          (mnas-sdl3-gui/widgets:init-ttf-font))))
  :continue)

(sdl3:def-app-iterate window-01-window-demo-iterate ()
  (unless *window-01-open*
    (return-from window-01-window-demo-iterate :success))
  (update-window-01-window-size)
  (sdl3:set-render-draw-color *window-01-renderer* 32 34 37 255)
  (sdl3:render-clear *window-01-renderer*)
  (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
                                     "Resizable window demo"
                                     24.0 24.0 '(220 220 220 255))
  (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
                                     (format nil "Size: ~Dx~D"
                                             *window-01-width*
                                             *window-01-height*)
                                     24.0 56.0 '(180 180 180 255))
  (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
                                     "Resize the window to see live dimensions. Press Escape or close to exit."
                                     24.0 96.0 '(160 160 160 255))
  (sdl3:render-present *window-01-renderer*)
  :continue)

(sdl3:def-app-event window-01-window-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *window-01-open* nil)
       :success)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (when (eq (slot-value ev 'sdl3:%key) :escape)
           (setf *window-01-open* nil)
           :success))
       :continue)
      (t :continue))))

(sdl3:def-app-quit window-01-window-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *window-01-renderer*
    (sdl3:destroy-renderer *window-01-renderer*))
  (when *window-01-window*
    (sdl3:destroy-window *window-01-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun window-01 ()
  "Run a resizable window demo."
  (sdl3:enter-app-main-callbacks
   'window-01-window-demo-init
   'window-01-window-demo-iterate
   'window-01-window-demo-event
   'window-01-window-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-01)
;;;; (window-01)

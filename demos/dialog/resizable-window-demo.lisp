;;;; ./demos/dialog/resizable-window-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *resizable-window* nil)
(defparameter *resizable-renderer* nil)
(defparameter *resizable-open* t)
(defparameter *resizable-window-width* 640)
(defparameter *resizable-window-height* 360)

(defun update-resizable-window-size ()
  "Query current window client size and update demo state."
  (when *resizable-window*
    (multiple-value-bind (ok width height)
        (sdl3:get-window-size *resizable-window*)
      (when ok
        (setf *resizable-window-width* width
              *resizable-window-height* height)))))

(sdl3:def-app-init resizable-window-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Resizable Window Demo" "1.0"
                         "com.mna.sdl3.gui.resizable-window.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from resizable-window-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Resizable Window Demo"
                                       *resizable-window-width*
                                       *resizable-window-height*
                                       :resizable)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from resizable-window-demo-init :failure))
        (progn
          (setf *resizable-window* window
                *resizable-renderer* renderer
                *resizable-open* t)
          (mnas-sdl3-gui/widgets:init-ttf-font))))
  :continue)

(sdl3:def-app-iterate resizable-window-demo-iterate ()
  (unless *resizable-open*
    (return-from resizable-window-demo-iterate :success))
  (update-resizable-window-size)
  (sdl3:set-render-draw-color *resizable-renderer* 32 34 37 255)
  (sdl3:render-clear *resizable-renderer*)
  (mnas-sdl3-gui/widgets:render-text *resizable-renderer*
                                     "Resizable window demo"
                                     24.0 24.0 '(220 220 220 255))
  (mnas-sdl3-gui/widgets:render-text *resizable-renderer*
                                     (format nil "Size: ~Dx~D"
                                             *resizable-window-width*
                                             *resizable-window-height*)
                                     24.0 56.0 '(180 180 180 255))
  (mnas-sdl3-gui/widgets:render-text *resizable-renderer*
                                     "Resize the window to see live dimensions. Press Escape or close to exit."
                                     24.0 96.0 '(160 160 160 255))
  (sdl3:render-present *resizable-renderer*)
  :continue)

(sdl3:def-app-event resizable-window-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *resizable-open* nil)
       :success)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (when (eq (slot-value ev 'sdl3:%key) :escape)
           (setf *resizable-open* nil)
           :success))
       :continue)
      (t :continue))))

(sdl3:def-app-quit resizable-window-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *resizable-renderer*
    (sdl3:destroy-renderer *resizable-renderer*))
  (when *resizable-window*
    (sdl3:destroy-window *resizable-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-resizable-window-demo ()
  "Run an empty demo with an SDL resizable window."
  (sdl3:enter-app-main-callbacks
   'resizable-window-demo-init
   'resizable-window-demo-iterate
   'resizable-window-demo-event
   'resizable-window-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (mnas-sdl3-gui/demos/dialog:do-resizable-window-demo)

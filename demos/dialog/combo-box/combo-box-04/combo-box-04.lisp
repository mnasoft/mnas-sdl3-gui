;;;; ./demos/dialog/combo-box/combo-box-04.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-04)

;;; Minimal non-editable combo-box popup demo

(defparameter *window*   nil)
(defparameter *renderer* nil)
(defparameter *open* t)

(defun create-combo-box-04-widgets (&optional window)
  (let ((combo
          (make-instance
           'mnas-sdl3-gui/widgets:combo-box
           :x 20 :y 20 :width 320 :height 34
           :items (loop for i from 1 to 20 collect (format nil "Item ~2,'0D" i))
           :selected-index 0
           :max-visible-items 5
           :placeholder "Choose..."
           :popup-host-window window
           :window window))
        (combo-1
          (make-instance
           'mnas-sdl3-gui/widgets:combo-box
           :x 20 :y 60 :width 320 :height 34
           :items (loop for i from 1 to 20 collect (format nil "Atem ~2,'0D" i))
           :selected-index 0
           :max-visible-items 5
           :placeholder "Choose..."
           :popup-host-window window
           :window window)))
        (let ((widgets (list combo combo-1)))
          (when window
            (mnas-sdl3-gui/widgets:register-widgets-for-window window widgets))
          widgets)))

(sdl3:def-app-init combo-box-04-demo-init (argc argv)
  (declare (ignore argc argv))
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from combo-box-04-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Combo Box 04" 380 120 0)
    (unless ok
      (format t "create-window failed: ~A~%" (sdl3:get-error))
      (return-from combo-box-04-demo-init :failure))
    (setf *window* window
          *renderer* renderer
          *open* t)
    (mnas-sdl3-gui/widgets:set-widget-style :flat)
    (mnas-sdl3-gui/widgets:init-ttf-font)
    (let ((widgets (create-combo-box-04-widgets *window*)))
      (mnas-sdl3-gui/widgets:set-widget-focus widgets (first widgets)))
    :continue))

(sdl3:def-app-iterate combo-box-04-demo-iterate ()
  (unless *open*
    (return-from combo-box-04-demo-iterate :success))
    (sdl3:set-render-draw-color *renderer* 240 240 240 255)
    (sdl3:render-clear *renderer*)
    (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window *window*)))
      (when widgets
        (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order widgets)
          do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))))
  #+nil
  (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window *window*)))
    (mnas-sdl3-gui/widgets:render-text *renderer*
                                       (format nil "Selection: ~A"
                                               (and widgets (mnas-sdl3-gui/widgets:widget-value (first widgets))))
                                       20.0 90.0 '(80 80 80 255)))
  ;; popup windows are rendered via transient popup proxies appended by
  ;; `widgets-in-render-order', so no explicit popup calls are needed here.
  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event combo-box-04-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:mouse-button-event
       (let ((win-id (slot-value ev 'sdl3:%window-id))
             (down (slot-value ev 'sdl3:%down))
             (x (round (slot-value ev 'sdl3:%x)))
             (y (round (slot-value ev 'sdl3:%y))))
        (format t "[demo event] mouse-button win-id=~S down=~A x=~D y=~D~%" win-id down x y)
        (let* ((main-id (sdl3:get-window-id *window*))
               (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
          (format t "[demo] main-id=~S associated-count=~A~%" main-id (if associated (length associated) 0))
          (cond
            ;; treat registry associations only for non-main/top-level windows
            ((and associated (not (= win-id main-id)) down)
             (format t "[demo] branch=associated-down win-id=~S~%" win-id)
             (dolist (w associated)
               (format t "[demo] associated widget=~S~%" (type-of w))
               (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down w x y)))
            ((and associated (not (= win-id main-id)) (not down))
             (format t "[demo] branch=associated-up win-id=~S~%" win-id)
             (dolist (w associated)
               (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up w x y)))
            ((and down (= win-id main-id))
             (format t "[demo] branch=main-down~%")
             (mnas-sdl3-gui/widgets:handle-widget-mouse-down
              (mnas-sdl3-gui/widgets:widgets-for-window *window*) x y)))))
       :continue)
      (sdl3:mouse-motion-event
       (let* ((win-id (slot-value ev 'sdl3:%window-id))
              (mx (round (slot-value ev 'sdl3:%x)))
              (my (round (slot-value ev 'sdl3:%y)))
              (main-id (sdl3:get-window-id *window*))
              (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
         (cond
           ((and associated (not (= win-id main-id)))
            (dolist (w associated)
              (mnas-sdl3-gui/widgets:handle-widget-mouse-motion w mx my)))
           ((= win-id main-id)
            (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
             (mnas-sdl3-gui/widgets:widgets-for-window *window*) mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (let ((win-id (slot-value ev 'sdl3:%window-id)))
         (let* ((main-id (sdl3:get-window-id *window*))
                (dy (round (slot-value ev 'sdl3:%y)))
                (mx (round (slot-value ev 'sdl3:%mouse-x)))
                (my (round (slot-value ev 'sdl3:%mouse-y)))
                (x (round (slot-value ev 'sdl3:%x)))
                (y (round (slot-value ev 'sdl3:%y)))
                (associated (mnas-sdl3-gui/widgets:widgets-for-window-id win-id)))
           (cond
             ((and associated (not (= win-id main-id)))
              (dolist (w associated)
                (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel w 0 0 0 dy)))
             ((= win-id main-id)
              (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
               (mnas-sdl3-gui/widgets:widgets-for-window *window*) mx my x y)))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
              (not (slot-value ev 'sdl3:%repeat)))
        (mnas-sdl3-gui/widgets:handle-widget-key-event
         (mnas-sdl3-gui/widgets:widgets-for-window *window*)
         (slot-value ev 'sdl3:%key)
         nil
         :mods (slot-value ev 'sdl3:%mod)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit combo-box-04-demo-quit (result)
  (declare (ignore result))
  (let ((widgets (and *window* (mnas-sdl3-gui/widgets:widgets-for-window *window*))))
    (when widgets
      (dolist (w widgets)
        (when (typep w 'mnas-sdl3-gui/widgets:combo-box)
          (mnas-sdl3-gui/widgets:combo-box-disable-popup-window w)))))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit)
  :success)

(defun combo-box-04 ()
  "Run minimal combo-box demo."
  (sdl3:enter-app-main-callbacks
   'combo-box-04-demo-init
   'combo-box-04-demo-iterate
   'combo-box-04-demo-event
   'combo-box-04-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-04)
;;;; (combo-box-04)

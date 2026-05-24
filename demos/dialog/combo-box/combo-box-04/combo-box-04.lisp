;;;; ./demos/dialog/combo-box/combo-box-04.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-04)

;;; Minimal non-editable combo-box popup demo

(defparameter *window*   nil)
(defparameter *renderer* nil)
(defparameter *widgets*  nil)
(defparameter *combo*    nil)
(defparameter *combo-1*  nil)
(defparameter *open* t)

(defun create-combo-box-04-widgets ()
  (let ((combo (make-instance 'mnas-sdl3-gui/widgets:combo-box
                              :x 20 :y 20 :width 320 :height 34
                              :items '("Item 01" "Item 02" "Item 03" "Item 04" "Item 05")
                              :selected-index 0
                              :max-visible-items 5
                              :placeholder "Choose..."))
        (combo-1 (make-instance 'mnas-sdl3-gui/widgets:combo-box
                              :x 20 :y 60 :width 320 :height 34
                              :items '("Atem 01" "Atem 02" "Atem 03" "Atem 04" "Atem 05")
                              :selected-index 0
                              :max-visible-items 5
                              :placeholder "Choose...")))
    (setf *combo*   combo
          *combo-1* combo-1 
          *widgets* (list combo combo-1))
    *widgets*))

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
    (create-combo-box-04-widgets)
    (mnas-sdl3-gui/widgets:combo-box-enable-popup-window *combo*   *window*)
    (mnas-sdl3-gui/widgets:combo-box-enable-popup-window *combo-1* *window*)
    (mnas-sdl3-gui/widgets:set-widget-focus *widgets* *combo*)
    :continue))

(sdl3:def-app-iterate combo-box-04-demo-iterate ()
  (unless *open*
    (return-from combo-box-04-demo-iterate :success))
  (sdl3:set-render-draw-color *renderer* 240 240 240 255)
  (sdl3:render-clear *renderer*)
  (mnas-sdl3-gui/widgets:render-widgets *renderer* *widgets*)
  #+nil
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     (format nil "Selection: ~A" (mnas-sdl3-gui/widgets:widget-value *combo*))
                                     20.0 90.0 '(80 80 80 255))
  (mnas-sdl3-gui/widgets:combo-box-render-popup-window *combo*)
  (mnas-sdl3-gui/widgets:combo-box-render-popup-window *combo-1*)
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
         (cond
           ((and down
                 (= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo*)))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down
             *combo* x y))
           ((and (not down)
                 (= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo*)))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up
             *combo* x y))
           
           ((and down
                 (= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-1*)))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down
             *combo-1* x y))
           ((and (not down)
                 (= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-1*)))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up
             *combo-1* x y))
           
           ((and down (= win-id (sdl3:get-window-id *window*)))
            (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down
             *widgets* x y)))
         :continue))
      (sdl3:mouse-motion-event
       (let ((win-id (slot-value ev 'sdl3:%window-id)))
         (cond
           ((= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo*))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-motion
             *combo*
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y))))
           
           ((= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-1*))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-motion
             *combo-1*
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y))))
           
           ((= win-id (sdl3:get-window-id *window*))
              (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
             *widgets*
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y)))))
         :continue))
      (sdl3:mouse-wheel-event
       (let ((win-id (slot-value ev 'sdl3:%window-id)))
         (cond
           ((= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo*))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-wheel
             *combo*
             (round (slot-value ev 'sdl3:%y))))
           ((= win-id (sdl3:get-window-id *window*))
            (mnas-sdl3-gui/widgets:dispatch-widget-mouse-wheel
             *widgets*
             (round (slot-value ev 'sdl3:%mouse-x))
             (round (slot-value ev 'sdl3:%mouse-y))
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y)))))
         :continue))
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
          *widgets*
          (slot-value ev 'sdl3:%key)
          :mods (slot-value ev 'sdl3:%mod)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit combo-box-04-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *combo*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (sdl3:destroy-window *window*))
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

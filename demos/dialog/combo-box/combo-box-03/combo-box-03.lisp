;;;; ./demos/dialog/combo-box/combo-box-03/combo-box-03.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-03)

;;; Minimal editable combo-box demo

(defparameter *combo-box-03-window* nil)
(defparameter *combo-box-03-renderer* nil)
(defparameter *combo-box-03-widgets* nil)
(defparameter *combo-box-03-editable* nil)
(defparameter *combo-box-03-open* t)

(defun create-combo-box-03-widgets ()
  (let ((editable (make-instance 'mnas-sdl3-gui/widgets:editable-combo-box
                                 :x 20 :y 40 :width 320 :height 34
                                 :main-height 34
                                 :items '("Item 01" "Item 02" "Item 03" "Item 04" "Item 05"
                                          "Item 06" "Item 07" "Item 08" "Item 09" "Item 10"
                                          "Item 11" "Item 12" "Item 13" "Item 14" "Item 15")
                                 :selected-index 0
                                 :text "" :cursor 0
                                 :max-visible-items 5
                                 :placeholder "Choose...")))
    (setf *combo-box-03-editable* editable
          *combo-box-03-widgets* (list editable))
    *combo-box-03-widgets*))

(sdl3:def-app-init combo-box-03-demo-init (argc argv)
  (declare (ignore argc argv))
  (unless (sdl3:init :video)
    (format t "SDL init failed: ~A~%" (sdl3:get-error))
    (return-from combo-box-03-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Combo Box 03" 380 120 0)
    (unless ok (format t "create-window failed: ~A~%" (sdl3:get-error)) (return-from combo-box-03-demo-init :failure))
    (setf *combo-box-03-window* window
          *combo-box-03-renderer* renderer
          *combo-box-03-open* t)
    (mnas-sdl3-gui/widgets:set-widget-style :flat)
    (mnas-sdl3-gui/widgets:init-ttf-font)
    (create-combo-box-03-widgets)
    (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
     *combo-box-03-editable*
     *combo-box-03-window*)
    (mnas-sdl3-gui/widgets:set-widget-focus *combo-box-03-widgets* *combo-box-03-editable*)
    (mnas-sdl3-gui/widgets:start-widget-text-input *combo-box-03-window*)
    :continue))

(sdl3:def-app-iterate combo-box-03-demo-iterate ()
  (unless *combo-box-03-open* (return-from combo-box-03-demo-iterate :success))
    (sdl3:set-render-draw-color *combo-box-03-renderer* 240 240 240 255)
    (sdl3:render-clear *combo-box-03-renderer*)
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *combo-box-03-widgets*)
        do (mnas-sdl3-gui/widgets:render *combo-box-03-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
    (mnas-sdl3-gui/widgets:render-text
     *combo-box-03-renderer*
     (format nil "expanded=~A popup=~A enabled=~A popup-id=~S"
       (mnas-sdl3-gui/widgets:combo-box-expanded-p *combo-box-03-editable*)
       (mnas-sdl3-gui/widgets:combo-box-popup-visible-p *combo-box-03-editable*)
       (mnas-sdl3-gui/widgets:combo-box-popup-window-enabled-p *combo-box-03-editable*)
       (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-box-03-editable*))
     20.0 84.0 '(120 120 120 255))
  ;; popup windows are rendered via transient popup proxies appended by
  ;; `widgets-in-render-order', so no explicit popup calls are needed here.
  (sdl3:render-present *combo-box-03-renderer*)
  :continue)

(sdl3:def-app-event combo-box-03-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event (setf *combo-box-03-open* nil) :success)
      (sdl3:mouse-button-event
       (let ((win-id (slot-value ev 'sdl3:%window-id))
             (down (slot-value ev 'sdl3:%down))
             (x (round (slot-value ev 'sdl3:%x)))
             (y (round (slot-value ev 'sdl3:%y))))
         (cond
           ((and down (= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-box-03-editable*)))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down *combo-box-03-editable* x y))
           ((and (not down) (= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-box-03-editable*)))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up *combo-box-03-editable* x y))
           ((and down (= win-id (sdl3:get-window-id *combo-box-03-window*)))
            (mnas-sdl3-gui/widgets:handle-widget-mouse-down *combo-box-03-widgets* x y))))
       :continue)
      (sdl3:mouse-motion-event
       (let ((win-id (slot-value ev 'sdl3:%window-id)))
         (cond
           ((= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-box-03-editable*))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-motion
             *combo-box-03-editable*
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y))))
           ((= win-id (sdl3:get-window-id *combo-box-03-window*))
              (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
               (list *combo-box-03-widgets*)
               (round (slot-value ev 'sdl3:%x))
               (round (slot-value ev 'sdl3:%y))))))
       :continue)
      (sdl3:mouse-wheel-event
       (let ((win-id (slot-value ev 'sdl3:%window-id)))
         (cond
           ((= win-id (mnas-sdl3-gui/widgets:combo-box-popup-window-id *combo-box-03-editable*))
            (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-wheel
             *combo-box-03-editable*
             (round (slot-value ev 'sdl3:%y))))
            ((= win-id (sdl3:get-window-id *combo-box-03-window*))
            (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
             *combo-box-03-widgets*
             (round (slot-value ev 'sdl3:%mouse-x))
             (round (slot-value ev 'sdl3:%mouse-y))
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y))))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down) (not (slot-value ev 'sdl3:%repeat)))
        (mnas-sdl3-gui/widgets:handle-widget-key-event *combo-box-03-widgets* (slot-value ev 'sdl3:%key) nil :mods (slot-value ev 'sdl3:%mod)))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input *combo-box-03-widgets* (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit combo-box-03-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *combo-box-03-editable*)
  (mnas-sdl3-gui/widgets:stop-widget-text-input *combo-box-03-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *combo-box-03-renderer* (sdl3:destroy-renderer *combo-box-03-renderer*))
  (when *combo-box-03-window* (sdl3:destroy-window *combo-box-03-window*))
  (sdl3:pump-events)
  (sdl3:quit)
  :success)

(defun combo-box-03 ()
  "Run minimal combo-box demo."
  (sdl3:enter-app-main-callbacks
   'combo-box-03-demo-init
   'combo-box-03-demo-iterate
   'combo-box-03-demo-event
   'combo-box-03-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-03)
;;;; (combo-box-03)

;;;; (mnas-sdl3-gui/demos/dialog/combo-box-03:combo-box-03)

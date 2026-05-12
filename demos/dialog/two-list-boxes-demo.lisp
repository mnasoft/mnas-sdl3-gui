;;;; ./demos/dialog/two-list-boxes-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *two-list-boxes-window* nil)
(defparameter *two-list-boxes-renderer* nil)
(defparameter *two-list-boxes-open* t)
(defparameter *two-list-boxes-result* nil)
(defparameter *two-list-boxes-style* :windows)
(defparameter *two-list-boxes-widgets* nil)
(defparameter *two-list-boxes-left* nil)
(defparameter *two-list-boxes-right* nil)
(defparameter *two-list-boxes-ok* nil)
(defparameter *two-list-boxes-cancel* nil)

(defun two-list-boxes-items (count prefix)
  "Create COUNT demo strings prefixed by PREFIX."
  (loop for index from 1 to count
        collect (format nil "~A ~D" prefix index)))

(defun create-two-list-boxes-demo-widgets ()
  "Create widgets for the two-list-boxes demo."
  (let ((title (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 18 :width 600 :height 24
                              :text "Two List-Boxes Demo"))
        (subtitle (make-instance 'mnas-sdl3-gui/widgets:label
                                 :x 20 :y 42 :width 600 :height 22
                                 :text "Слева 50 элементов, справа 4 элемента")))
    (setf *two-list-boxes-left*
          (make-instance 'mnas-sdl3-gui/widgets:list-box
                         :x 20 :y 74 :width 290 :height 170
                         :items (two-list-boxes-items 50 "Элемент")
                         :selected-index 0
                         :item-height 24)
          *two-list-boxes-right*
          (make-instance 'mnas-sdl3-gui/widgets:list-box
                         :x 330 :y 74 :width 290 :height 170
                         :items (two-list-boxes-items 4 "Пункт")
                         :selected-index 0
                         :item-height 24)
          *two-list-boxes-ok*
          (make-instance 'mnas-sdl3-gui/widgets:button
                         :x 350 :y 264 :width 120 :height 34
                         :text "Ок"
                         :on-click (lambda (widget)
                                     (declare (ignore widget))
                                     (setf *two-list-boxes-result*
                                           (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *two-list-boxes-left*)
                                                            (mnas-sdl3-gui/widgets:list-box-items *two-list-boxes-left*))
                                                 :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *two-list-boxes-right*)
                                                             (mnas-sdl3-gui/widgets:list-box-items *two-list-boxes-right*)))
                                           *two-list-boxes-open* nil)))
          *two-list-boxes-cancel*
          (make-instance 'mnas-sdl3-gui/widgets:button
                         :x 490 :y 264 :width 130 :height 34
                         :text "Cancel"
                         :on-click (lambda (widget)
                                     (declare (ignore widget))
                                     (setf *two-list-boxes-result* nil
                                           *two-list-boxes-open* nil)))
          *two-list-boxes-widgets*
          (list title subtitle
                *two-list-boxes-left*
                *two-list-boxes-right*
                *two-list-boxes-ok*
                *two-list-boxes-cancel*))
    *two-list-boxes-widgets*))

(sdl3:def-app-init two-list-boxes-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Two List-Boxes Demo" "1.0"
                         "com.mna.sdl3.gui.two-list-boxes.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from two-list-boxes-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Two List-Boxes Demo" 640 320 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from two-list-boxes-demo-init :failure))
        (progn
          (setf *two-list-boxes-window* window
                *two-list-boxes-renderer* renderer
                *two-list-boxes-open* t
                *two-list-boxes-result* nil)
          (mnas-sdl3-gui/widgets:set-widget-style *two-list-boxes-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-two-list-boxes-demo-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus *two-list-boxes-widgets*
                                                  *two-list-boxes-left*))))
  :continue)

(sdl3:def-app-iterate two-list-boxes-demo-iterate ()
  (unless *two-list-boxes-open*
    (return-from two-list-boxes-demo-iterate :success))

  (sdl3:set-render-draw-color *two-list-boxes-renderer* 236 236 236 255)
  (sdl3:render-clear *two-list-boxes-renderer*)

  (mnas-sdl3-gui/widgets:render-widgets *two-list-boxes-renderer* *two-list-boxes-widgets*)

  (sdl3:render-present *two-list-boxes-renderer*)
  :continue)

(sdl3:def-app-event two-list-boxes-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *two-list-boxes-open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *two-list-boxes-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down *two-list-boxes-widgets* mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up *two-list-boxes-widgets* mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-wheel
        *two-list-boxes-widgets*
        (round (slot-value ev 'sdl3:%mouse-x))
        (round (slot-value ev 'sdl3:%mouse-y))
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
          *two-list-boxes-widgets*
          (slot-value ev 'sdl3:%key)
          :mods (slot-value ev 'sdl3:%mod)
          :on-escape (lambda ()
                       (setf *two-list-boxes-result* nil
                             *two-list-boxes-open* nil)
                       :success)
          :on-return (lambda ()
                       (setf *two-list-boxes-result*
                             (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *two-list-boxes-left*)
                                              (mnas-sdl3-gui/widgets:list-box-items *two-list-boxes-left*))
                                   :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *two-list-boxes-right*)
                                               (mnas-sdl3-gui/widgets:list-box-items *two-list-boxes-right*)))
                             *two-list-boxes-open* nil)
                       :success)))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *two-list-boxes-widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit two-list-boxes-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *two-list-boxes-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *two-list-boxes-renderer*
    (sdl3:destroy-renderer *two-list-boxes-renderer*))
  (when *two-list-boxes-window*
    (sdl3:destroy-window *two-list-boxes-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-two-list-boxes-demo (&optional (style :windows))
  "Run demo with two list-box widgets and OK/Cancel buttons."
  (setf *two-list-boxes-style* style)
  (sdl3:enter-app-main-callbacks
   'two-list-boxes-demo-init
   'two-list-boxes-demo-iterate
   'two-list-boxes-demo-event
   'two-list-boxes-demo-quit)
  *two-list-boxes-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (mnas-sdl3-gui/demos/dialog:do-two-list-boxes-demo)
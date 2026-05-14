;;;; ./demos/dialog/editable-combo-box-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *editable-combo-box-window* nil)
(defparameter *editable-combo-box-renderer* nil)
(defparameter *editable-combo-box-open* t)
(defparameter *editable-combo-box-style* :flat)
(defparameter *editable-combo-box-widgets* nil)
(defparameter *editable-combo-box-status*
  "Editable combo box demo. Type a value, select an item, or add a new one.")

(defun create-editable-combo-box-demo-widgets ()
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :x 20 :y 18 :width 560 :height 24
                               :text "Editable Combo-Box Demo"))
         (hint (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 42 :width 560 :height 24
                              :text "Type a value or choose from the list. Press buttons to report or add the current text."))
         (editable (make-instance 'mnas-sdl3-gui/widgets:editable-combo-box
                                  :x 20 :y 86 :width 380 :height 36
                                  :main-height 36
                                  :items '("Preset A" "Preset B" "Preset C")
                                  :selected-index 0
                                  :text ""
                                  :cursor 0
                                  :max-length 100
                                  :max-visible-items 6
                                  :placeholder "Type new item or select from list"))
         (report (make-instance 'mnas-sdl3-gui/widgets:button
                                 :x 20 :y 140 :width 180 :height 34
                                 :text "Show current value"
                                 :on-click (lambda (widget)
                                             (declare (ignore widget))
                                             (setf *editable-combo-box-status*
                                                   (format nil "Value: ~A  Text: ~A"
                                                           (mnas-sdl3-gui/widgets:widget-value editable)
                                                           (mnas-sdl3-gui/widgets:edit-box-text editable))))))
         (add-item (make-instance 'mnas-sdl3-gui/widgets:button
                                  :x 220 :y 140 :width 180 :height 34
                                  :text "Add current text"
                                  :on-click (lambda (widget)
                                              (declare (ignore widget))
                                              (let ((text (mnas-sdl3-gui/widgets:edit-box-text editable)))
                                                (if (and text (not (string= text "")))
                                                    (progn
                                                      (mnas-sdl3-gui/widgets:combo-box-add-item editable text)
                                                      (setf *editable-combo-box-status*
                                                            (format nil "Added and selected: ~A" text)))
                                                    (setf *editable-combo-box-status* "Type a non-empty value to add.")))))))
    (setf *editable-combo-box-widgets* (list title hint editable report add-item))
    *editable-combo-box-widgets*))

(sdl3:def-app-init editable-combo-box-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Editable Combo-Box Demo" "1.0"
                         "com.mna.sdl3.gui.editable-combo-box.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from editable-combo-box-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Editable Combo-Box Demo" 640 260 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from editable-combo-box-demo-init :failure))
        (progn
          (setf *editable-combo-box-window* window
                *editable-combo-box-renderer* renderer
                *editable-combo-box-open* t
                *editable-combo-box-status* "Editable combo box demo. Type a value, select an item, or add a new one.")
          (mnas-sdl3-gui/widgets:set-widget-style *editable-combo-box-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-editable-combo-box-demo-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus *editable-combo-box-widgets*
                                                  (third *editable-combo-box-widgets*))
          (mnas-sdl3-gui/widgets:start-widget-text-input *editable-combo-box-window*))))
  :continue)

(sdl3:def-app-iterate editable-combo-box-demo-iterate ()
  (unless *editable-combo-box-open*
    (return-from editable-combo-box-demo-iterate :success))
  (sdl3:set-render-draw-color *editable-combo-box-renderer* 240 240 240 255)
  (sdl3:render-clear *editable-combo-box-renderer*)
  (mnas-sdl3-gui/widgets:render-widgets *editable-combo-box-renderer* *editable-combo-box-widgets*)
  (mnas-sdl3-gui/widgets:render-text *editable-combo-box-renderer*
                                     *editable-combo-box-status*
                                     20.0 200.0 '(40 40 40 255))
  (sdl3:render-present *editable-combo-box-renderer*)
  :continue)

(sdl3:def-app-event editable-combo-box-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *editable-combo-box-open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *editable-combo-box-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down
                *editable-combo-box-widgets* mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up
                *editable-combo-box-widgets* mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-wheel
        *editable-combo-box-widgets*
        (round (slot-value ev 'sdl3:%mouse-x))
        (round (slot-value ev 'sdl3:%mouse-y))
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
          *editable-combo-box-widgets*
          (slot-value ev 'sdl3:%key)
          :mods (slot-value ev 'sdl3:%mod)
          :on-escape (lambda ()
                       (setf *editable-combo-box-open* nil)
                       :success)))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *editable-combo-box-widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit editable-combo-box-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *editable-combo-box-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *editable-combo-box-renderer*
    (sdl3:destroy-renderer *editable-combo-box-renderer*))
  (when *editable-combo-box-window*
    (sdl3:destroy-window *editable-combo-box-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-editable-combo-box-demo (&optional (style :flat))
  "Run the editable combo-box demo with STYLE (:flat, :windows, :motif)."
  (setf *editable-combo-box-style* style)
  (sdl3:enter-app-main-callbacks
   'editable-combo-box-demo-init
   'editable-combo-box-demo-iterate
   'editable-combo-box-demo-event
   'editable-combo-box-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (mnas-sdl3-gui/demos/dialog:do-editable-combo-box-demo)

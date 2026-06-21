;;;; ./demos/layout/split-pane-01/split-pane-01.lisp

(in-package :mnas-sdl3-gui/demos/layout/split-pane-01)

(defparameter *split-pane-demo-window* nil)
(defparameter *split-pane-demo-renderer* nil)
(defparameter *split-pane-demo-window-id* 0)
(defparameter *split-pane-demo-open* t)
(defparameter *split-pane-demo-layer-manager* nil)
(defparameter *split-pane-demo-widgets* nil)
(defparameter *split-pane-demo-style* :windows)
(defparameter *split-pane-demo-status* "Split pane layout demo")
(defparameter +split-pane-demo-margin+ 16)

(defun split-pane-demo-focus-widgets ()
  "Return widgets that participate in focus and text-input dispatch."
  (labels ((flatten (widgets)
             (loop for widget in widgets
                   append (if (and (typep widget 'mnas-sdl3-gui/widgets:<widget-container>)
                                   (mnas-sdl3-gui/widgets:children widget))
                              (flatten (mnas-sdl3-gui/widgets:children widget))
                              (list widget)))))
    (flatten *split-pane-demo-widgets*)))

(defun split-pane-demo-relayout (&optional (window *split-pane-demo-window*))
  "Re-layout the root split-pane to the current WINDOW client size."
  (when (and window *split-pane-demo-widgets*)
    (multiple-value-bind (ok win-w win-h) (sdl3:get-window-size window)
      (when ok
        (let* ((root (first *split-pane-demo-widgets*))
               (inner-w (max 1 (- win-w (* 2 +split-pane-demo-margin+))))
               (inner-h (max 1 (- win-h (* 2 +split-pane-demo-margin+)))))
          (when root
            (mnas-sdl3-gui/widgets:widget-arrange root
                                                  +split-pane-demo-margin+
                                                  +split-pane-demo-margin+
                                                  inner-w
                                                  inner-h)))))))

(defun create-split-pane-demo-widgets ()
  "Create a split-pane demo widget tree and return the root widget list."
  (let* ((left-pane (mnas-sdl3-gui/widgets:make-column-stack :spacing 8 :padding 8))
         (right-pane (mnas-sdl3-gui/widgets:make-column-stack :spacing 8 :padding 8))
         (split-pane (mnas-sdl3-gui/widgets:make-split-pane
                      :orientation :horizontal
                      :split-ratio 0.4
                      :divider-size 8
                      :padding 10
                      :children (list left-pane right-pane)))
         (title (make-instance 'mnas-sdl3-gui/widgets:<label> :text "Split Pane Demo"))
         (description (make-instance 'mnas-sdl3-gui/widgets:<label> :text "Each side is a separate pane.") )
         (left-entry (make-instance 'mnas-sdl3-gui/widgets:entry :text "Left pane" :cursor 0 :max-length 128))
         (right-entry (make-instance 'mnas-sdl3-gui/widgets:entry :text "Right pane" :cursor 0 :max-length 128))
         (left-button (make-instance 'mnas-sdl3-gui/widgets:<button> :text "Left Action"
                                     :on-click (lambda (w) (declare (ignore w))
                                                 (setf *split-pane-demo-status* "Left action activated"))))
         (right-button (make-instance 'mnas-sdl3-gui/widgets:<button> :text "Right Action"
                                      :on-click (lambda (w) (declare (ignore w))
                                                  (setf *split-pane-demo-status* "Right action activated")))))
    (setf (mnas-sdl3-gui/widgets:children left-pane)
          (list title left-entry left-button))
    (setf (mnas-sdl3-gui/widgets:children right-pane)
          (list description right-entry right-button))
    (setf *split-pane-demo-widgets* (list split-pane))
    (multiple-value-bind (w h) (mnas-sdl3-gui/widgets:widget-measure split-pane)
      (mnas-sdl3-gui/widgets:widget-arrange split-pane
                                            +split-pane-demo-margin+
                                            +split-pane-demo-margin+
                                            w
                                            h)
      (values *split-pane-demo-widgets*
              (+ w (* 2 +split-pane-demo-margin+))
              (+ h (* 2 +split-pane-demo-margin+))))))

(sdl3:def-app-init split-pane-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Split Pane Demo" "1.0" "com.mna.sdl3.gui.split-pane.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from split-pane-demo-init :failure))
  (setf *split-pane-demo-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (mnas-sdl3-gui/widgets:init-ttf-font)
  (multiple-value-bind (widgets window-width window-height)
      (create-split-pane-demo-widgets)
    (multiple-value-bind (ok window renderer)
        (sdl3:create-window-and-renderer "Split Pane Demo" window-width window-height '(:resizable))
      (if (not ok)
          (progn
            (format t "~a~%" (sdl3:get-error))
            (return-from split-pane-demo-init :failure))
          (progn
            (setf *split-pane-demo-window* window
                  *split-pane-demo-renderer* renderer
                  *split-pane-demo-window-id* (sdl3:get-window-id window)
                  *split-pane-demo-open* t)
            (mnas-sdl3-gui/window-manager:register-window
             *split-pane-demo-layer-manager*
             *split-pane-demo-window-id*
             :main
             :open-p t)
            (mnas-sdl3-gui/window-manager:set-focused-window
             *split-pane-demo-layer-manager*
             *split-pane-demo-window-id*)
            (mnas-sdl3-gui/widgets:set-widget-style *split-pane-demo-style*)
            (mnas-sdl3-gui/widgets:start-widget-text-input window)
            (setf *split-pane-demo-widgets* widgets)
            (split-pane-demo-relayout window)
            (let* ((focus-widgets (split-pane-demo-focus-widgets))
                   (first-entry (find-if (lambda (w)
                                           (typep w 'mnas-sdl3-gui/widgets:entry))
                                         focus-widgets)))
              (if first-entry
                  (mnas-sdl3-gui/widgets:set-widget-focus focus-widgets first-entry)
                  (mnas-sdl3-gui/widgets:move-widget-focus focus-widgets)))
            :continue)))))

(sdl3:def-app-iterate split-pane-demo-iterate ()
  (unless *split-pane-demo-open*
    (return-from split-pane-demo-iterate :success))

  (sdl3:set-render-draw-color *split-pane-demo-renderer* 242 242 242 255)
  (sdl3:render-clear *split-pane-demo-renderer*)

  (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *split-pane-demo-widgets*)
    do (mnas-sdl3-gui/widgets:render *split-pane-demo-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/widgets:render-text
   *split-pane-demo-renderer*
   *split-pane-demo-status* 16.0 8.0 '(45 45 45 255))

  (sdl3:render-present *split-pane-demo-renderer*)
  :continue)

(sdl3:def-app-event split-pane-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *split-pane-demo-open* nil)
       :success)
      (sdl3:window-event
       (when (and (= (slot-value ev 'sdl3:%window-id) *split-pane-demo-window-id*)
                  (member (slot-value ev 'sdl3:%type)
                          '(:window-resized :window-pixel-size-changed)
                          :test #'eq))
         (split-pane-demo-relayout *split-pane-demo-window*))
       :continue)
      (sdl3:mouse-motion-event
       :continue)
      (sdl3:mouse-button-event
       (mnas-sdl3-gui/widgets:handle-mouse-button-event *split-pane-demo-widgets* ev))
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:handle-widget-key-event
          (split-pane-demo-focus-widgets)
          (slot-value ev 'sdl3:%key) nil
          :mods (slot-value ev 'sdl3:%mod)
          :on-escape (lambda () (setf *split-pane-demo-open* nil))))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        (split-pane-demo-focus-widgets)
        (slot-value ev 'sdl3:%text))
       :continue)
      (otherwise :continue))))

(sdl3:def-app-quit split-pane-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *split-pane-demo-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *split-pane-demo-renderer*
    (sdl3:destroy-renderer *split-pane-demo-renderer*))
  (when *split-pane-demo-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *split-pane-demo-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit)
  :ok)

(defun split-pane-01 ()
  "Launch the split-pane demo application."
  (sdl3:enter-app-main-callbacks
   'split-pane-demo-init
   'split-pane-demo-iterate
   'split-pane-demo-event
   'split-pane-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos)  
;;;; (ql:quickload mnas-sdl3-gui/demos/layout/split-pane-01)
;;;; (mnas-sdl3-gui/demos/layout/split-pane-01:split-pane-01)
;;;; (split-pane-01)


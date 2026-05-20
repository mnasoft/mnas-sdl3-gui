;;;; ./demos/dialog/window/window-02/window-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(defparameter *window-02-main-window* nil)
(defparameter *window-02-main-renderer* nil)
(defparameter *window-02-main-id* 0)

(defparameter *window-02-layer-manager* nil)

(defparameter *window-02-popup-window* nil)
(defparameter *window-02-popup-renderer* nil)
(defparameter *window-02-popup-id* 0)
(defparameter *window-02-popup-visible* nil)

(defparameter *window-02-open* t)
(defparameter *window-02-hover-index* nil)
(defparameter *window-02-selected-item* "No item selected")
(defparameter *window-02-popup-items*
  '("Open"
    "Save"
    "Save As..."
    "Close"))

(defparameter +window-02-main-width+ 760)
(defparameter +window-02-main-height+ 460)
(defparameter +window-02-popup-width+ 230)
(defparameter +window-02-popup-item-height+ 36)
(defparameter +window-02-popup-padding+ 6)
(defparameter +window-02-mouse-left+ 1)
(defparameter +window-02-mouse-right+ 3)

(defun window-02-null-pointer-p (ptr)
  "Check whether PTR is a CFFI null pointer." 
  (or (null ptr)
      (cffi:null-pointer-p ptr)))

(defun window-02-popup-height ()
  (+ (* (length *window-02-popup-items*) +window-02-popup-item-height+)
     (* 2 +window-02-popup-padding+)))

(defun window-02-item-index-at (mouse-y)
  (let* ((local-y (- mouse-y +window-02-popup-padding+))
         (index (floor local-y +window-02-popup-item-height+)))
    (when (and (>= local-y 0)
               (< index (length *window-02-popup-items*)))
      index)))

(defun window-02-hide-popup ()
  (setf *window-02-popup-visible* nil
        *window-02-hover-index* nil)
  (when *window-02-popup-window*
    (sdl3:hide-window *window-02-popup-window*))
  (when *window-02-layer-manager*
    (mnas-sdl3-gui/window-manager:close-window
     *window-02-layer-manager*
     *window-02-popup-id*
     :close-children t)
    (mnas-sdl3-gui/window-manager:set-focused-window
     *window-02-layer-manager*
     *window-02-main-id)))

(defun window-02-show-popup-at (local-x local-y)
  (when *window-02-main-window*
    (multiple-value-bind (ok wx wy)
        (sdl3:get-window-position *window-02-main-window*)
      (when ok
        (let ((global-x (+ wx local-x))
              (global-y (+ wy local-y)))
          (sdl3:set-window-position *window-02-popup-window* global-x global-y)
          (sdl3:show-window *window-02-popup-window*)
          (sdl3:raise-window *window-02-popup-window*)
          (when *window-02-layer-manager*
            (mnas-sdl3-gui/window-manager:open-window
             *window-02-layer-manager*
             *window-02-popup-id*))
          (setf *window-02-popup-visible* t
                *window-02-hover-index* nil))))))

(defun window-02-render-main ()
  (sdl3:set-render-draw-color *window-02-main-renderer* 30 35 40 255)
  (sdl3:render-clear *window-02-main-renderer*)
  (mnas-sdl3-gui/widgets:render-text *window-02-main-renderer*
                                     "Popup Menu Window Demo"
                                     28.0 26.0 '(232 232 232 255))
  (mnas-sdl3-gui/widgets:render-text *window-02-main-renderer*
                                     "Right click anywhere to open an actual :popup-menu window."
                                     28.0 64.0 '(190 190 190 255))
  (mnas-sdl3-gui/widgets:render-text *window-02-main-renderer*
                                     "Left click a popup item to select it. Escape closes popup or exits demo."
                                     28.0 94.0 '(170 170 170 255))
  (mnas-sdl3-gui/widgets:render-text *window-02-main-renderer*
                                     (format nil "Selected item: ~A" *window-02-selected-item*)
                                     28.0 148.0 '(246 214 102 255))
  (mnas-sdl3-gui/widgets:render-text *window-02-main-renderer*
                                     (if *window-02-popup-visible*
                                         "Popup state: visible"
                                         "Popup state: hidden")
                                     28.0 178.0 '(150 205 230 255))
  (sdl3:render-present *window-02-main-renderer*))

(defun window-02-render-popup ()
  (when *window-02-popup-visible*
    (sdl3:set-render-draw-color *window-02-popup-renderer* 245 245 245 255)
    (sdl3:render-clear *window-02-popup-renderer*)

    (sdl3:set-render-draw-color *window-02-popup-renderer* 34 34 34 255)
    (sdl3:render-rect *window-02-popup-renderer*
                      (make-instance 'sdl3:frect
                                     :%x 0.5
                                     :%y 0.5
                                     :%w (float (- +window-02-popup-width+ 1) 1.0)
                                     :%h (float (- (window-02-popup-height) 1) 1.0)))

    (loop for item in *window-02-popup-items*
          for index from 0
          for row-y = (+ +window-02-popup-padding+
                         (* index +window-02-popup-item-height+))
          do (progn
               (when (and *window-02-hover-index*
                          (= index *window-02-hover-index*))
                 (sdl3:set-render-draw-color *window-02-popup-renderer* 69 132 227 255)
                 (sdl3:render-fill-rect *window-02-popup-renderer*
                                        (make-instance 'sdl3:frect
                                                       :%x 5.0
                                                       :%y (float row-y 1.0)
                                                       :%w (float (- +window-02-popup-width+ 10) 1.0)
                                                       :%h (float +window-02-popup-item-height+ 1.0))))
               (mnas-sdl3-gui/widgets:render-text *window-02-popup-renderer*
                                                  item
                                                  16.0
                                                  (float (+ row-y 10) 1.0)
                                                  (if (and *window-02-hover-index*
                                                           (= index *window-02-hover-index*))
                                                      '(255 255 255 255)
                                                      '(20 20 20 255)))))

    (sdl3:render-present *window-02-popup-renderer*)))

(sdl3:def-app-init window-02-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Popup Menu Window Demo" "1.0"
                         "com.mna.sdl3.gui.window-02-popup-menu.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from window-02-init :failure))

  (setf *window-02-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))

  (multiple-value-bind (ok-main main-window main-renderer)
      (sdl3:create-window-and-renderer "Popup Menu Host Window"
                                       +window-02-main-width+
                                       +window-02-main-height+
                                       0)
    (unless ok-main
      (format t "Failed to create main window: ~a~%" (sdl3:get-error))
      (return-from window-02-init :failure))
    (setf *window-02-main-window* main-window
          *window-02-main-renderer* main-renderer
          *window-02-main-id* (sdl3:get-window-id main-window))
    (mnas-sdl3-gui/window-manager:register-window
     *window-02-layer-manager*
     *window-02-main-id*
     :main
     :open-p t))

  (let ((popup-window (sdl3:create-popup-window
                       *window-02-main-window*
                       0
                       0
                       +window-02-popup-width+
                       (window-02-popup-height)
                       :popup-menu)))
    (when (window-02-null-pointer-p popup-window)
      (format t "Failed to create popup-menu window: ~a~%" (sdl3:get-error))
      (return-from window-02-init :failure))
    (let ((popup-renderer (sdl3:create-renderer popup-window "")))
      (when (window-02-null-pointer-p popup-renderer)
        (format t "Failed to create popup-menu renderer: ~a~%" (sdl3:get-error))
        (return-from window-02-init :failure))
      (setf *window-02-popup-window* popup-window
            *window-02-popup-renderer* popup-renderer
        *window-02-popup-id* (sdl3:get-window-id popup-window))
      (mnas-sdl3-gui/window-manager:register-window
       *window-02-layer-manager*
       *window-02-popup-id*
       :popup-menu
       :parent-id *window-02-main-id*
       :open-p nil)))

  (mnas-sdl3-gui/widgets:init-ttf-font)
  (window-02-register-commands)
  (window-02-register-shortcuts)
  (window-02-hide-popup)
  (setf *window-02-open* t
        *window-02-selected-item* "No item selected")
  :continue)

(sdl3:def-app-iterate window-02-iterate ()
  (unless *window-02-open*
    (return-from window-02-iterate :success))
  (window-02-render-main)
  (window-02-render-popup)
  :continue)

(sdl3:def-app-event window-02-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
        (window-02-command :window-02/quit)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *window-02-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *window-02-layer-manager*
                              window-id))))
           (case action
             (:close-root
              (window-02-command :window-02/quit)
              (return-from window-02-event :success))
             (:close-transient
              (when (= window-id *window-02-popup-id*)
                (window-02-hide-popup)))
             (otherwise
              (cond
                ((= window-id *window-02-main-id*)
                 (window-02-command :window-02/quit)
                 (return-from window-02-event :success))
                ((= window-id *window-02-popup-id*)
                 (window-02-hide-popup)))))))
       :continue)
      (sdl3:mouse-motion-event
       (let* ((window-id (slot-value ev 'sdl3:%window-id))
          (target-id (if *window-02-layer-manager*
                 (mnas-sdl3-gui/window-manager:event-target-window-id
              *window-02-layer-manager*
              window-id)
                 window-id)))
         (when (and *window-02-popup-visible*
            target-id
            (= target-id *window-02-popup-id*))
         (setf *window-02-hover-index*
               (window-02-item-index-at
            (round (slot-value ev 'sdl3:%y))))))
       :continue)
      (sdl3:mouse-button-event
       (let ((button (slot-value ev 'sdl3:%button))
             (down (slot-value ev 'sdl3:%down))
             (window-id (slot-value ev 'sdl3:%window-id))
             (x (round (slot-value ev 'sdl3:%x)))
             (y (round (slot-value ev 'sdl3:%y))))
         (when *window-02-layer-manager*
           (setf window-id
             (or (mnas-sdl3-gui/window-manager:event-target-window-id
              *window-02-layer-manager*
              window-id)
             window-id)))
         (cond
           ((and down
                 (= button +window-02-mouse-right+)
                 (= window-id *window-02-main-id*))
            (window-02-command :window-02/toggle-popup :x x :y y))
           ((and down
                 (= button +window-02-mouse-left+)
                 (= window-id *window-02-popup-id*)
                 *window-02-popup-visible*)
            (let ((index (window-02-item-index-at y)))
              (window-02-command :window-02/select-popup-item :index index)))
           ((and down
                 (= button +window-02-mouse-left+)
                 (= window-id *window-02-main-id*)
                 *window-02-popup-visible*)
            (window-02-command :window-02/toggle-popup))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (when (mnas-sdl3-gui/commands:dispatch-shortcut
                (slot-value ev 'sdl3:%key)
                :mods (slot-value ev 'sdl3:%mod)
                :context (list :window-id (slot-value ev 'sdl3:%window-id)))
           (unless *window-02-open*
             (return-from window-02-event :success))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit window-02-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *window-02-popup-renderer*
    (sdl3:destroy-renderer *window-02-popup-renderer*))
  (when *window-02-popup-window*
    (sdl3:destroy-window *window-02-popup-window*))
  (when *window-02-main-renderer*
    (sdl3:destroy-renderer *window-02-main-renderer*))
  (when *window-02-main-window*
    (sdl3:destroy-window *window-02-main-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun window-02 ()
  "Run popup-menu demo using a dedicated :popup-menu window."
  (setf *window-02-main-window* nil
        *window-02-main-renderer* nil
        *window-02-main-id* 0
  *window-02-layer-manager* nil
        *window-02-popup-window* nil
        *window-02-popup-renderer* nil
        *window-02-popup-id* 0
        *window-02-popup-visible* nil
        *window-02-open* t
        *window-02-hover-index* nil
        *window-02-selected-item* "No item selected")
  (sdl3:enter-app-main-callbacks
   'window-02-init
   'window-02-iterate
   'window-02-event
   'window-02-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-02)
;;;; (mnas-sdl3-gui/demos/dialog/window-02:window-02)

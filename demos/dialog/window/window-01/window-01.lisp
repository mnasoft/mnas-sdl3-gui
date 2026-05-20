;;;; ./demos/dialog/window/window-01/window-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

(defparameter *window-01-window* nil)
(defparameter *window-01-renderer* nil)
(defparameter *window-01-window-id* 0)
(defparameter *window-01-layer-manager* nil)
(defparameter *window-01-open* t)
(defparameter *window-01-width* 640)
(defparameter *window-01-height* 360)
(defparameter *window-01-demo-title* "Resizable Window Demo")
(defparameter *window-01-demo-flags* :resizable)

(defparameter +window-01-modal-1-id+ 10001)
(defparameter +window-01-modal-2-id+ 10002)
(defparameter *window-01-modal-1-open* nil)
(defparameter *window-01-modal-2-open* nil)

(defparameter *window-01-all-flags*
  '(:fullscreen
    :opengl
    :occluded
    :hidden
    :borderless
    :resizable
    :minimized
    :maximized
    :mouse-grabbed
    :input-focus
    :mouse-focus
    :external
    :modal
    :high-pixel-density
    :mouse-capture
    :mouse-relative-mode
    :always-on-top
    :utility
    :tooltip
    :popup-menu
    :keyboard-grabbed
    :vulkan
    :metal
    :transparent
    :not-focusable))

(defun window-01-flags-as-list ()
  "Return demo flags as a list for printing and passing to SDL." 
  (if (listp *window-01-demo-flags*)
      *window-01-demo-flags*
      (list *window-01-demo-flags*)))

(defun run-window-01-demo (title flags)
  "Run window demo with custom title and SDL window flags." 
  (setf *window-01-demo-title* title
        *window-01-demo-flags* flags
        *window-01-window* nil
        *window-01-renderer* nil
    *window-01-window-id* 0
    *window-01-layer-manager* nil
    *window-01-modal-1-open* nil
    *window-01-modal-2-open* nil
        *window-01-open* t
        *window-01-width* 640
        *window-01-height* 360)
  (sdl3:enter-app-main-callbacks
   'window-01-window-demo-init
   'window-01-window-demo-iterate
   'window-01-window-demo-event
   'window-01-window-demo-quit)
  :done)

(defmacro define-window-01-flag-demo (name flag)
  "Define a small wrapper demo for a single window flag." 
  `(defun ,name ()
     ,(format nil "Run a window demo using the ~S flag." flag)
     (run-window-01-demo
      ,(format nil "Window Flag Demo: ~S" flag)
      ,flag)))

(defun update-window-01-window-size ()
  "Query current window client size and update demo state."
  (when *window-01-window*
    (multiple-value-bind (ok width height)
        (sdl3:get-window-size *window-01-window*)
      (when ok
        (setf *window-01-width* width
              *window-01-height* height)))))

(defun window-01-open-modal-1 ()
  "Open first modal layer for runtime focus-trap demo." 
  (when (and *window-01-layer-manager*
             (not *window-01-modal-1-open*))
    (mnas-sdl3-gui/window-manager:register-window
     *window-01-layer-manager*
     +window-01-modal-1-id+
     :modal
     :parent-id *window-01-window-id*
     :open-p t)
    (setf *window-01-modal-1-open* t)
    (mnas-sdl3-gui/window-manager:set-focused-window
     *window-01-layer-manager*
     +window-01-modal-1-id+)
    t))

(defun window-01-open-modal-2 ()
  "Open second nested modal layer for runtime focus-trap demo." 
  (when (and *window-01-layer-manager*
             *window-01-modal-1-open*
             (not *window-01-modal-2-open*))
    (mnas-sdl3-gui/window-manager:register-window
     *window-01-layer-manager*
     +window-01-modal-2-id+
     :modal
     :parent-id +window-01-modal-1-id+
     :open-p t)
    (setf *window-01-modal-2-open* t)
    (mnas-sdl3-gui/window-manager:set-focused-window
     *window-01-layer-manager*
     +window-01-modal-2-id+)
    t))

(defun window-01-close-top-modal ()
  "Close top-most modal layer if any was opened in runtime demo." 
  (cond
    (*window-01-modal-2-open*
     (mnas-sdl3-gui/window-manager:close-window
      *window-01-layer-manager*
      +window-01-modal-2-id+)
     (setf *window-01-modal-2-open* nil)
     t)
    (*window-01-modal-1-open*
     (mnas-sdl3-gui/window-manager:close-window
      *window-01-layer-manager*
      +window-01-modal-1-id+)
     (setf *window-01-modal-1-open* nil
           *window-01-modal-2-open* nil)
     t)
    (t nil)))

(sdl3:def-app-init window-01-window-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata *window-01-demo-title* "1.0"
                         "com.mna.sdl3.gui.window-01-window.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from window-01-window-demo-init :failure))

  (setf *window-01-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))

  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer *window-01-demo-title*
                                       *window-01-width*
                                       *window-01-height*
                                       (window-01-flags-as-list))
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from window-01-window-demo-init :failure))
        (progn
          (setf *window-01-window* window
                *window-01-renderer* renderer
                *window-01-window-id* (sdl3:get-window-id window)
                *window-01-open* t)
          (mnas-sdl3-gui/window-manager:register-window
           *window-01-layer-manager*
           *window-01-window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *window-01-layer-manager*
           *window-01-window-id*)
          (mnas-sdl3-gui/widgets:init-ttf-font))))
  :continue)

(sdl3:def-app-iterate window-01-window-demo-iterate ()
  (unless *window-01-open*
    (return-from window-01-window-demo-iterate :success))
  (update-window-01-window-size)
  (sdl3:set-render-draw-color *window-01-renderer* 32 34 37 255)
  (sdl3:render-clear *window-01-renderer*)
  (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
               *window-01-demo-title*
                                     24.0 24.0 '(220 220 220 255))
  (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
                                     (format nil "Size: ~Dx~D"
                                             *window-01-width*
                                             *window-01-height*)
                                     24.0 56.0 '(180 180 180 255))
  (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
               (format nil "Flags: ~{~S~^ ~}"
                 (window-01-flags-as-list))
               24.0 96.0 '(160 160 160 255))
    (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
               "M: open modal-1  N: open modal-2  Backspace/Escape: close top modal"
               24.0 128.0 '(160 160 160 255))
    (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
               "Escape with empty stack exits demo."
               24.0 152.0 '(160 160 160 255))

    (when *window-01-layer-manager*
      (mnas-sdl3-gui/widgets:render-text
       *window-01-renderer*
       (format nil "Focused: ~A  Active modal: ~A  Trap: ~A"
         (or (mnas-sdl3-gui/window-manager:focused-window-id *window-01-layer-manager*) :none)
         (or (mnas-sdl3-gui/window-manager:active-modal-id *window-01-layer-manager*) :none)
         (if (mnas-sdl3-gui/window-manager:modal-trap-active-p *window-01-layer-manager*) :on :off))
       24.0 184.0 '(246 214 102 255)))

    (when *window-01-modal-1-open*
      (sdl3:set-render-draw-color *window-01-renderer* 48 62 96 255)
      (sdl3:render-fill-rect *window-01-renderer*
           (make-instance 'sdl3:frect :%x 120.0 :%y 210.0 :%w 380.0 :%h 100.0))
      (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
                 "Modal-1 active"
                 140.0 236.0 '(232 240 255 255)))

    (when *window-01-modal-2-open*
      (sdl3:set-render-draw-color *window-01-renderer* 86 52 98 255)
      (sdl3:render-fill-rect *window-01-renderer*
           (make-instance 'sdl3:frect :%x 190.0 :%y 236.0 :%w 260.0 :%h 86.0))
      (mnas-sdl3-gui/widgets:render-text *window-01-renderer*
                 "Modal-2 active (nested)"
                 208.0 262.0 '(255 238 255 255)))

  (sdl3:render-present *window-01-renderer*)
  :continue)

(sdl3:def-app-event window-01-window-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *window-01-open* nil)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *window-01-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *window-01-layer-manager*
                              window-id))))
           (declare (ignore action))
           (unless (window-01-close-top-modal)
             (setf *window-01-open* nil)
             (return-from window-01-window-demo-event :success))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (let* ((event-window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *window-01-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:keyboard-target-window-id
                                           *window-01-layer-manager*
                                           event-window-id)
                                          event-window-id)
                                      event-window-id)))
           (when *window-01-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *window-01-layer-manager*
              target-window-id))
           (case (slot-value ev 'sdl3:%key)
             (:m
              (window-01-open-modal-1))
             (:n
              (window-01-open-modal-2))
             (:backspace
              (window-01-close-top-modal))
             (:escape
              (unless (window-01-close-top-modal)
                (setf *window-01-open* nil)
                (return-from window-01-window-demo-event :success)))
             (otherwise nil))))
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
  (run-window-01-demo "Resizable Window Demo" :resizable))

(define-window-01-flag-demo window-01-fullscreen :fullscreen)
(define-window-01-flag-demo window-01-opengl :opengl)
(define-window-01-flag-demo window-01-occluded :occluded)
(define-window-01-flag-demo window-01-hidden :hidden)
(define-window-01-flag-demo window-01-borderless :borderless)
(define-window-01-flag-demo window-01-resizable :resizable)
(define-window-01-flag-demo window-01-minimized :minimized)
(define-window-01-flag-demo window-01-maximized :maximized)
(define-window-01-flag-demo window-01-mouse-grabbed :mouse-grabbed)
(define-window-01-flag-demo window-01-input-focus :input-focus)
(define-window-01-flag-demo window-01-mouse-focus :mouse-focus)
(define-window-01-flag-demo window-01-external :external)
(define-window-01-flag-demo window-01-modal :modal)
(define-window-01-flag-demo window-01-high-pixel-density :high-pixel-density)
(define-window-01-flag-demo window-01-mouse-capture :mouse-capture)
(define-window-01-flag-demo window-01-mouse-relative-mode :mouse-relative-mode)
(define-window-01-flag-demo window-01-always-on-top :always-on-top)
(define-window-01-flag-demo window-01-utility :utility)
(define-window-01-flag-demo window-01-tooltip :tooltip)
(define-window-01-flag-demo window-01-keyboard-grabbed :keyboard-grabbed)
(define-window-01-flag-demo window-01-vulkan :vulkan)
(define-window-01-flag-demo window-01-metal :metal)
(define-window-01-flag-demo window-01-not-focusable :not-focusable)

(defun window-01-transparent ()
  "Run dedicated transparent-window demo from window-03."
  (mnas-sdl3-gui/demos/dialog/window-03:window-03))

(defun window-01-popup-menu ()
  "Run dedicated popup-menu demo from window-02."
  (mnas-sdl3-gui/demos/dialog/window-02:window-02))

(defun window-01-all-flags ()
  "Run demo with all available window flags combined." 
  (run-window-01-demo "Window Flag Demo: ALL" *window-01-all-flags*))

(defun window-01-modal-stack-runtime ()
  "Run visual runtime demo for nested modal focus-trap policy." 
  (run-window-01-demo "Window Modal Stack Runtime Demo" :resizable))

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-01)
;;;; (window-01)

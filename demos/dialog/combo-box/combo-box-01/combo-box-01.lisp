;;;; ./demos/dialog/combo-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defparameter *combo-box-window* nil)
(defparameter *combo-box-window-id* 0)
(defparameter *combo-box-layer-manager* nil)
(defparameter *combo-box-toolbar* nil)
(defparameter *combo-box-open* t)
(defparameter *combo-box-style* :windows)
(defparameter *combo-box-widgets* nil)
(defparameter *combo-box-01-small* nil)
(defparameter *combo-box-01-large* nil)
(defparameter *combo-box-status* "Use mouse, arrows, PgUp/PgDown, Return and Escape.")
(defparameter +combo-box-01-window-height+ 332)
(defparameter +combo-box-01-toolbar-height+ 32)

(defun combo-box-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun combo-box-01-report-value ()
  "Update status line from current combo box selections."
  (setf *combo-box-status*
        (format nil "Selected: ~A / ~A"
                (mnas-sdl3-gui/widgets:widget-value *combo-box-01-small*)
                (mnas-sdl3-gui/widgets:widget-value *combo-box-01-large*))))

(defun combo-box-01-register-commands ()
  "Register commands for the combo-box-01 demo."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :combo-box-01/quit
    "Quit combo-box demo"
    :group :combo-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *combo-box-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :combo-box-01/report
    "Report combo-box values"
    :group :combo-box-01
    :shortcut :enter
    :execute (lambda (context)
               (declare (ignore context))
               (combo-box-01-report-value)
               t))
   :replace t))

(defun combo-box-01-register-shortcuts ()
  "Register keyboard shortcuts for the combo-box-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut :combo-box-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :combo-box-01/report :enter :replace t)
  t)

(defun combo-box-01-create-toolbar ()
  "Create toolbar for the combo-box-01 demo." 
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar
                  :layout :horizontal
                  :height +combo-box-01-toolbar-height+)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :combo-box-01/report
                                                   :label "Report"
                                                   :width 72)
           (mnas-sdl3-gui/toolbar:make-button-spec :combo-box-01/quit
                                                   :label "Quit"
                                                   :width 64)))
    toolbar))

(defun combo-box-01-sync-command-state ()
  "Sync command state for combo-box-01 toolbar." 
  (let ((report-cmd (mnas-sdl3-gui/commands:find-command :combo-box-01/report))
        (enabled (and *combo-box-01-small*
                      *combo-box-01-large*
                      (mnas-sdl3-gui/widgets:widget-value *combo-box-01-small*)
                      (mnas-sdl3-gui/widgets:widget-value *combo-box-01-large*))))
    (when report-cmd
      (mnas-sdl3-gui/commands:set-command-enabled report-cmd enabled))))

(defun combo-box-01-items (prefix count)
  (loop for index from 1 to count
        collect (format nil "~A ~D" prefix index)))

(defun create-combo-box-01-widgets ()
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :x 20 :y 18 :width 520 :height 24
                               :text "Combo-Box Demo"))
         (hint (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 42 :width 560 :height 24
                              :text "Return confirms, Escape closes popup, wheel scrolls expanded lists."))
         (small (make-instance 'mnas-sdl3-gui/widgets:combo-box
                               :x 20 :y 86 :width 240 :height 32
                               :items '("Flat" "Windows" "Motif" "Experimental")
                               :selected-index 1))
         (large (make-instance 'mnas-sdl3-gui/widgets:combo-box
                               :x 20 :y 136 :width 320 :height 32
                               :items (combo-box-01-items "Preset" 18)
                               :selected-index 4
                               :max-visible-items 7))
           (action (make-instance 'mnas-sdl3-gui/widgets:button
                  :x 20 :y 196 :width 140 :height 34
                  :text "Report Value"
                  :on-click (lambda (widget)
                      (declare (ignore widget))
                      (setf *combo-box-status*
                        (format nil "Selected: ~A / ~A"
                            (mnas-sdl3-gui/widgets:widget-value small)
                            (mnas-sdl3-gui/widgets:widget-value large))))))
          (setf *combo-box-widgets* (list title hint small large action))
          *combo-box-widgets*)

(sdl3:def-app-init combo-box-01-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Combo-Box Demo" "1.0"
                         "com.mna.sdl3.gui.combo-box.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from combo-box-01-init :failure))
  (setf *combo-box-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Combo-Box Demo" 620 +combo-box-01-window-height+ 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from combo-box-01-init :failure))
        (progn
          (setf *combo-box-window* window
                *combo-box-window-id* (sdl3:get-window-id window)
                *combo-box-renderer* renderer
                *combo-box-open* t
                *combo-box-status* "Use mouse, arrows, PgUp/PgDown, Return and Escape.")
              (mnas-sdl3-gui/window-manager:register-window
               *combo-box-layer-manager*
               *combo-box-window-id*
               :main
               :open-p t)
          (combo-box-01-register-commands)
          (combo-box-01-register-shortcuts)
          (setf *combo-box-toolbar* (combo-box-01-create-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *combo-box-toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *combo-box-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-combo-box-01-widgets)
          (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
           *combo-box-01-small*
           *combo-box-window*
           :layer-manager *combo-box-layer-manager*)
          (mnas-sdl3-gui/widgets:combo-box-enable-popup-window
           *combo-box-01-large*
           *combo-box-window*
           :layer-manager *combo-box-layer-manager*)
          (mnas-sdl3-gui/widgets:set-widget-focus *combo-box-widgets*
                                                  (second (cdr *combo-box-widgets*))))))
  :continue)

(sdl3:def-app-iterate combo-box-01-iterate ()
  (unless *combo-box-open*
    (return-from combo-box-01-iterate :success))
  (sdl3:set-render-draw-color *combo-box-renderer* 240 240 240 255)
  (sdl3:render-clear *combo-box-renderer*)
  (combo-box-01-sync-command-state)
  (when *combo-box-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *combo-box-toolbar*
     *combo-box-renderer*
     0.0
     (- +combo-box-01-window-height+ +combo-box-01-toolbar-height+)))
  (mnas-sdl3-gui/widgets:render-text *combo-box-renderer*
                                     *combo-box-status*
                                     20.0 252.0 '(40 40 40 255))
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *combo-box-widgets*)
        do (mnas-sdl3-gui/widgets:render *combo-box-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
  ;; popup windows are rendered via transient popup proxies appended by
  ;; `widgets-in-render-order', so no explicit popup calls are needed here.
  (sdl3:render-present *combo-box-renderer*)
  :continue)

(sdl3:def-app-event combo-box-01-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (flet ((popup-widget-for-window (window-id)
             (let ((lst (mnas-sdl3-gui/widgets:widgets-for-window-id window-id)))
               (and lst (first lst)))))
      (typecase ev
        (sdl3:quit-event
         (setf *combo-box-open* nil)
         :success)
        (sdl3:window-event
         (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
           (let* ((window-id (slot-value ev 'sdl3:%window-id))
                  (popup-widget (popup-widget-for-window window-id)))
             (when popup-widget
               (mnas-sdl3-gui/widgets:sync-combo-box-expanded-state popup-widget nil)))))
        (sdl3:mouse-motion-event
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (popup-widget (popup-widget-for-window window-id)))
           (cond
            (popup-widget
              (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
               popup-widget
               (round (slot-value ev 'sdl3:%x))
               (round (slot-value ev 'sdl3:%y))))
             ((= window-id *combo-box-window-id*)
              (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
               *combo-box-widgets*
               (round (slot-value ev 'sdl3:%x))
               (round (slot-value ev 'sdl3:%y))))))
         :continue)
        (sdl3:mouse-button-event
         (when (= (slot-value ev 'sdl3:%button) 1)
           (let* ((window-id (slot-value ev 'sdl3:%window-id))
                  (popup-widget (popup-widget-for-window window-id))
                  (mx (round (slot-value ev 'sdl3:%x)))
                  (my (round (slot-value ev 'sdl3:%y)))
                  (toolbar-y-offset (- +combo-box-01-window-height+ +combo-box-01-toolbar-height+)))
             (cond
               (popup-widget
                (if (slot-value ev 'sdl3:%down)
                    (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down popup-widget mx my)
                    (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-up popup-widget mx my)))
               ((and (slot-value ev 'sdl3:%down) (= window-id *combo-box-window-id*))
                (let ((button (and *combo-box-toolbar*
                                   (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                    *combo-box-toolbar*
                                    mx
                                    (- my toolbar-y-offset)))))
                  (if button
                      (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                       *combo-box-toolbar*
                       button
                       (list :window-id *combo-box-window-id*))
                      (mnas-sdl3-gui/widgets:handle-widget-mouse-down *combo-box-widgets* mx my))))
               ((and (not (slot-value ev 'sdl3:%down)) (= window-id *combo-box-window-id*))
                (mnas-sdl3-gui/widgets:handle-widget-mouse-up *combo-box-widgets* mx my)))))
         :continue)
        (sdl3:mouse-wheel-event
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (popup-widget (popup-widget-for-window window-id)))
           (cond
             (popup-widget
              (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
               popup-widget
               0 0 0
               (round (slot-value ev 'sdl3:%y))))
             ((= window-id *combo-box-window-id*)
              (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
               *combo-box-widgets*
               (round (slot-value ev 'sdl3:%mouse-x))
               (round (slot-value ev 'sdl3:%mouse-y))
               (round (slot-value ev 'sdl3:%x))
               (round (slot-value ev 'sdl3:%y))))))
         :continue)
        (sdl3:keyboard-event
         (when (and (slot-value ev 'sdl3:%down)
                    (not (slot-value ev 'sdl3:%repeat)))
           (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                    (slot-value ev 'sdl3:%key)
                    :mods (slot-value ev 'sdl3:%mod)
                    :context (list :window-id *combo-box-window-id*))
             (mnas-sdl3-gui/widgets:handle-widget-key-event
              *combo-box-widgets*
              (slot-value ev 'sdl3:%key)
              nil
              :mods (slot-value ev 'sdl3:%mod)
              :on-escape (lambda ()
                           (setf *combo-box-open* nil)
                           :success))))
         :continue)
        (t :continue)))))

(sdl3:def-app-quit combo-box-01-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *combo-box-01-small*)
  (mnas-sdl3-gui/widgets:combo-box-disable-popup-window *combo-box-01-large*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *combo-box-renderer*
    (sdl3:destroy-renderer *combo-box-renderer*))
  (when *combo-box-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *combo-box-window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun combo-box-01 (&optional (style :windows))
  "Run combo-box demo with STYLE (:flat, :windows, :motif)."
  (setf *combo-box-style* style)
  (sdl3:enter-app-main-callbacks
   'combo-box-01-init
   'combo-box-01-iterate
   'combo-box-01-event
   'combo-box-01-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-01)
;;;; (combo-box-01)


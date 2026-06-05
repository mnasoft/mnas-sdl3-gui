;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/check-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)

(defparameter *window* nil)
(defparameter *renderer* nil)
(defparameter *window-id* 0)
(defparameter *toolbar* nil)
(defparameter *open* t)
(defparameter *style* :windows)
(defparameter *status* "Отмечайте и снимайте check-box элементы.")
(defparameter +check-box-window-height+ 322)
(defparameter +check-box-toolbar-height+ 32)

(defun check-box-window-widgets ()
  "Return current widgets registered for check-box demo window." 
  (if *window*
      (mnas-sdl3-gui/widgets:widgets-for-window *window*)
      nil))

(defun check-box-content-widgets ()
  "Return non-toolbar widgets of the demo window for generic widget flows." 
  (remove-if (lambda (widget)
               (or (typep widget 'mnas-sdl3-gui/widgets:toolbar)
                   (typep widget 'mnas-sdl3-gui/widgets:toolbar-button)))
             (check-box-window-widgets)))

(defun check-box-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun check-box-register-commands ()
  "Register commands for the check-box demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :check-box-01/quit
    "Quit check-box demo"
    :group :check-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *open* nil)
               t))
   :replace t))

(defun check-box-register-shortcuts ()
  "Register keyboard shortcuts for the check-box demo." 
  (mnas-sdl3-gui/commands:register-shortcut :check-box-01/quit :escape :replace t)
  t)

(defun check-box-create-toolbar (window)
  "Create toolbar for the check-box demo." 
  (let ((toolbar     (make-instance 'mnas-sdl3-gui/widgets:toolbar
                                    :layout :horizontal
                                    :height +check-box-toolbar-height+
                                    :window window))
        (tb-btn-quit (make-instance 'mnas-sdl3-gui/widgets:toolbar-button
                                    :command-id :check-box-01/quit
                                    :label "Quit"
                                    :width 64
                                    :window window
                                    )))
    (setf (mnas-sdl3-gui/widgets:widget-children toolbar) (list tb-btn-quit))
    toolbar))

(defun check-box-01-sync-command-state ()
  "Sync command state for check-box demo toolbar." 
  (let ((quit-cmd (mnas-sdl3-gui/commands:find-command :check-box-01/quit)))
    (when quit-cmd
      (mnas-sdl3-gui/commands:set-command-enabled quit-cmd t))))

(defun check-box-labels-in-column (prefix)
  "Return labels of checked check-box widgets whose label starts with PREFIX."
  (loop for widget in (check-box-window-widgets)
        when (and (typep widget 'mnas-sdl3-gui/widgets:check-box)
                  (mnas-sdl3-gui/widgets:check-box-checked widget)
                  (search prefix (mnas-sdl3-gui/widgets:check-box-label widget)
                          :start1 0 :end1 (length prefix)))
        collect (mnas-sdl3-gui/widgets:check-box-label widget)))

(defun join-labels (labels)
  "Join LABELS with comma, or return dash when empty."
  (if labels
      (format nil "~{~a~^, ~}" labels)
      "—"))

(defun refresh-check-box-status ()
  "Update status line from selected check-box values in both columns."
  (let ((left (join-labels (check-box-labels-in-column "Л")))
        (right (join-labels (check-box-labels-in-column "П"))))
    (setf *status*
          (format nil "Левая колонка: ~a   Правая колонка: ~a" left right))))

(defun make-demo-check-box (x y label checked-p window)
  "Create one check-box for demo and attach status update callback."
  (let ((check-box (make-instance
                    'mnas-sdl3-gui/widgets:check-box
                    :x       x
                    :y       y
                    :width   190
                    :height  28
                    :label   label
                    :checked checked-p
                    :focused nil
                    :window  window)))
    (setf (mnas-sdl3-gui/widgets:widget-value check-box) checked-p)
    (setf (mnas-sdl3-gui/widgets:widget-on-change check-box)
          (lambda (widget value)
            (declare (ignore widget value))
            (refresh-check-box-status)))
    check-box))

(defun create-check-box-widgets (window)
  "Create demo widgets for two columns of check-box controls."
  (list
   (make-instance 'mnas-sdl3-gui/widgets:label
                  :x 20
                  :y 16
                  :width 420
                  :height 28
                  :text "Check-box demo"
                  :window window)
   (make-instance 'mnas-sdl3-gui/widgets:label
                  :x 40 :y 56
                  :width 190
                  :height 22
                  :text "Левая колонка"
                  :window window)
   (make-instance 'mnas-sdl3-gui/widgets:label
                  :x 250
                  :y 56
                  :width 190
                  :height 22
                  :text "Правая колонка"
                  :window window)
   (make-demo-check-box 40   90 "Л1 Уведомления"    t   window)
   (make-demo-check-box 40  124 "Л2 Звук"           nil window)
   (make-demo-check-box 40  158 "Л3 Подсказки"      t   window)
   (make-demo-check-box 40  192 "Л4 Автосохранение" nil window)
   (make-demo-check-box 250  90 "П1 Сеть"           nil window)
   (make-demo-check-box 250 124 "П2 Логи"           t   window)
   (make-demo-check-box 250 158 "П3 Кэш"            nil window)
   (make-demo-check-box 250 192 "П4 Резерв"         t   window))
  (refresh-check-box-status))

(sdl3:def-app-init check-box-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Check-Box Demo" "1.0"
                         "com.mna.sdl3.gui.check-box.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from check-box-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Check-Box Demo" 500 +check-box-window-height+ 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from check-box-demo-init :failure))
        (progn
          (setf *window* window
                *renderer* renderer
                *window-id* (sdl3:get-window-id window)
                *open* t)
          (check-box-register-commands)
          (check-box-register-shortcuts)
          (setf *toolbar* (check-box-create-toolbar window))
          #+nil (mnas-sdl3-gui/widgets:register-toolbar-for-command-updates *toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-check-box-widgets window)
          (mnas-sdl3-gui/widgets:move-widget-focus (check-box-content-widgets)))))
  :continue)

(sdl3:def-app-iterate check-box-demo-iterate ()
  (unless *open*
    (return-from check-box-demo-iterate :success))
  (sdl3:set-render-draw-color *renderer* 240 240 240 255)
  (sdl3:render-clear *renderer*)
  (check-box-01-sync-command-state)
  (when *toolbar*
    (mnas-sdl3-gui/widgets:render
     *renderer*
     *toolbar*
     mnas-sdl3-gui/widgets:*widget-style*))
  (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order (check-box-content-widgets))
        do (mnas-sdl3-gui/widgets:render *renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     *status*
                                     20.0 238.0 '(40 40 40 255))
  (mnas-sdl3-gui/widgets:render-text *renderer*
                                     "Tab/Shift+Tab: focus, Space: toggle check-box"
                                     20.0 260.0 '(90 90 90 255))

  (sdl3:render-present *renderer*)
  :continue)

(sdl3:def-app-event check-box-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:handle-mouse-motion-event
        (check-box-window-widgets)
        ev)
       :continue)
      (sdl3:mouse-button-event
       (mnas-sdl3-gui/widgets:handle-mouse-button-event
        (check-box-window-widgets)
        ev)
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *window-id*))
           (mnas-sdl3-gui/widgets:handle-widget-key-event
            (check-box-content-widgets)
            (slot-value ev 'sdl3:%key)
            nil
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (setf *open* nil)
                         :success))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit check-box-demo-quit (result)
  (declare (ignore result))
  (when *window*
    (sdl3:destroy-renderer *renderer*))
  (when *window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window*))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun check-box-01 (&optional (style :windows))
  "Run check-box demo with keyboard focus support."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'check-box-demo-init
   'check-box-demo-iterate
   'check-box-demo-event
   'check-box-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/app)
;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/check-box-01)
;;;; (mnas-sdl3-gui/demos/dialog/check-box-01:check-box-01)
;;;; (check-box-01)

;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/check-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)

(defparameter *check-box-window* nil)
(defparameter *check-box-renderer* nil)
(defparameter *check-box-window-id* 0)
(defparameter *check-box-toolbar* nil)
(defparameter *check-box-open* t)
(defparameter *check-box-style* :windows)
(defparameter *check-box-widgets* nil)
(defparameter *check-box-status* "Отмечайте и снимайте check-box элементы.")
(defparameter +check-box-window-height+ 322)
(defparameter +check-box-toolbar-height+ 32)

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
               (setf *check-box-open* nil)
               t))
   :replace t))

(defun check-box-register-shortcuts ()
  "Register keyboard shortcuts for the check-box demo." 
  (mnas-sdl3-gui/commands:register-shortcut :check-box-01/quit :escape :replace t)
  t)

(defun check-box-create-toolbar ()
  "Create toolbar for the check-box demo." 
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar :layout :horizontal
                                                    :height +check-box-toolbar-height+)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :check-box-01/quit
                                                   :label "Quit"
                                                   :width 64)))
    toolbar))

(defun check-box-01-sync-command-state ()
  "Sync command state for check-box demo toolbar." 
  (let ((quit-cmd (mnas-sdl3-gui/commands:find-command :check-box-01/quit)))
    (when quit-cmd
      (mnas-sdl3-gui/commands:set-command-enabled quit-cmd t))))

(defun check-box-labels-in-column (prefix)
  "Return labels of checked check-box widgets whose label starts with PREFIX."
  (loop for widget in *check-box-widgets*
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
    (setf *check-box-status*
          (format nil "Левая колонка: ~a   Правая колонка: ~a" left right))))

(defun make-demo-check-box (x y label checked-p)
  "Create one check-box for demo and attach status update callback."
  (let ((check-box (make-instance 'mnas-sdl3-gui/widgets:check-box
                                  :x x :y y :width 190 :height 28
                                  :label label
                                  :checked checked-p
                                  :focused nil)))
    (setf (mnas-sdl3-gui/widgets:widget-value check-box) checked-p)
    (setf (mnas-sdl3-gui/widgets:widget-on-change check-box)
          (lambda (widget value)
            (declare (ignore widget value))
            (refresh-check-box-status)))
    check-box))

(defun create-check-box-widgets ()
  "Create demo widgets for two columns of check-box controls."
  (setf *check-box-widgets*
        (list
         (make-instance 'mnas-sdl3-gui/widgets:label
                        :x 20 :y 16 :width 420 :height 28
                        :text "Check-box demo")
         (make-instance 'mnas-sdl3-gui/widgets:label
                        :x 40 :y 56 :width 190 :height 22
                        :text "Левая колонка")
         (make-instance 'mnas-sdl3-gui/widgets:label
                        :x 250 :y 56 :width 190 :height 22
                        :text "Правая колонка")
         (make-demo-check-box 40 90 "Л1 Уведомления" t)
         (make-demo-check-box 40 124 "Л2 Звук" nil)
         (make-demo-check-box 40 158 "Л3 Подсказки" t)
         (make-demo-check-box 40 192 "Л4 Автосохранение" nil)
         (make-demo-check-box 250 90 "П1 Сеть" nil)
         (make-demo-check-box 250 124 "П2 Логи" t)
         (make-demo-check-box 250 158 "П3 Кэш" nil)
         (make-demo-check-box 250 192 "П4 Резерв" t)))
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
          (setf *check-box-window* window
                *check-box-renderer* renderer
                *check-box-window-id* (sdl3:get-window-id window)
                *check-box-open* t)
          (check-box-register-commands)
          (check-box-register-shortcuts)
          (setf *check-box-toolbar* (check-box-create-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *check-box-toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *check-box-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-check-box-widgets)
          (mnas-sdl3-gui/widgets:move-widget-focus *check-box-widgets*))))
  :continue)

(sdl3:def-app-iterate check-box-demo-iterate ()
  (unless *check-box-open*
    (return-from check-box-demo-iterate :success))

  (sdl3:set-render-draw-color *check-box-renderer* 240 240 240 255)
  (sdl3:render-clear *check-box-renderer*)

  (check-box-01-sync-command-state)
  (when *check-box-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *check-box-toolbar*
     *check-box-renderer*
     0.0
     (- +check-box-window-height+ +check-box-toolbar-height+)))

  (mnas-sdl3-gui/widgets:render-widgets *check-box-renderer* *check-box-widgets*)

  (mnas-sdl3-gui/widgets:render-text *check-box-renderer*
                                     *check-box-status*
                                     20.0 238.0 '(40 40 40 255))
  (mnas-sdl3-gui/widgets:render-text *check-box-renderer*
                                     "Tab/Shift+Tab: focus, Space: toggle check-box"
                                     20.0 260.0 '(90 90 90 255))

  (sdl3:render-present *check-box-renderer*)
  :continue)

(sdl3:def-app-event check-box-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *check-box-open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *check-box-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y)))
               (toolbar-y-offset (- +check-box-window-height+ +check-box-toolbar-height+)))
           (if (slot-value ev 'sdl3:%down)
               (let ((button (and *check-box-toolbar*
                                  (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                   *check-box-toolbar*
                                   mx
                                   (- my toolbar-y-offset)))))
                 (if button
                     (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                      *check-box-toolbar*
                      button
                      (list :window-id *check-box-window-id*))
                     (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down *check-box-widgets* mx my)))
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up *check-box-widgets* mx my))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *check-box-window-id*))
           (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
            *check-box-widgets*
            (slot-value ev 'sdl3:%key)
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (setf *check-box-open* nil)
                         :success))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit check-box-demo-quit (result)
  (declare (ignore result))
  (when *check-box-window*
    (sdl3:destroy-renderer *check-box-renderer*))
  (when *check-box-window*
    (sdl3:destroy-window *check-box-window*))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun check-box-01 (&optional (style :windows))
  "Run check-box demo with keyboard focus support."
  (setf *check-box-style* style)
  (sdl3:enter-app-main-callbacks
   'check-box-demo-init
   'check-box-demo-iterate
   'check-box-demo-event
   'check-box-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/check-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/check-box-01)
;;;; (check-box-01)

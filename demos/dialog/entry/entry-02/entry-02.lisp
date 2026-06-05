;;;; ./demos/dialog/entry/entry-02/entry-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-02)

(defparameter *entry-02-window* nil)
(defparameter *entry-02-renderer* nil)
(defparameter *entry-02-open* t)
(defparameter *entry-02-result* nil)
(defparameter *entry-02-active-modifiers* nil)
(defparameter *entry-02-style* :flat)
(defparameter *entry-02-status* "Entry demo: name, password, integer, real, path, command.")
(defparameter *entry-02-widgets* nil)
(defparameter *entry-02-name* nil)
(defparameter *entry-02-password* nil)
(defparameter *entry-02-integer* nil)
(defparameter *entry-02-real* nil)
(defparameter *entry-02-path* nil)
(defparameter *entry-02-command* nil)
(defparameter *entry-02-window-id* 0)
(defparameter *entry-02-toolbar* nil)
(defparameter +entry-02-toolbar-height+ 32)

(defun entry-02-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun entry-02-register-commands ()
  "Register commands for entry-02 demo."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-02/quit
    "Quit entry-02 demo"
    :group :entry-02
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *entry-02-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :entry-02/run
    "Run command from entry"
    :group :entry-02
    :shortcut :return
    :execute (lambda (context)
               (declare (ignore context))
               (setf *entry-02-status*
                     (format nil "Command executed: ~A"
                             (mnas-sdl3-gui/widgets:entry-text *entry-02-command*)))
               t))
   :replace t))

(defun entry-02-register-shortcuts ()
  "Register keyboard shortcuts for entry-02 demo."
  (mnas-sdl3-gui/commands:register-shortcut :entry-02/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :entry-02/run :return :replace t)
  t)

(defun entry-02-create-toolbar ()
  "Create toolbar for entry-02 demo."
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:toolbar
                  :layout :horizontal
                  :height +entry-02-toolbar-height+)))
    (setf (mnas-sdl3-gui/widgets:widget-children toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Run"
                                                   :width 72)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Quit"
                                                   :width 64)))
    toolbar))

(defun entry-02-sync-command-state ()
  "Sync command state for entry-02 toolbar." 
  (let* ((run-cmd (mnas-sdl3-gui/commands:find-command :entry-02/run))
         (text (and *entry-02-command*
                    (mnas-sdl3-gui/widgets:entry-text *entry-02-command*))))
    (when run-cmd
      (mnas-sdl3-gui/commands:set-command-enabled run-cmd
                                                  (> (length (string-trim '(#\Space #\Tab #\Newline #\Return) (or text ""))) 0)))))

(defun entry-02-key->modifier (key)
  "Return modifier keyword for KEY, or NIL when KEY is not a modifier key."
  (case key
    ((:lctrl :rctrl) :ctrl)
    ((:lshift :rshift) :shift)
    ((:lalt :ralt) :alt)
    (t nil)))

(defun entry-02-update-modifier-state (ev)
  "Update tracked modifier state from keyboard event EV."
  (let ((modifier (entry-02-key->modifier (slot-value ev 'sdl3:%key))))
    (when modifier
      (if (slot-value ev 'sdl3:%down)
          (pushnew modifier *entry-02-active-modifiers*)
          (setf *entry-02-active-modifiers*
                (remove modifier *entry-02-active-modifiers*)))))
  *entry-02-active-modifiers*)

(defun entry-02-key-modifiers (ev)
  "Return a list of active keyboard modifiers for EV."
  (declare (ignore ev))
  (copy-list *entry-02-active-modifiers*))

(defun entry-02-widgets ()
  "Return focus-traversable widgets in entry dialog."
  (list *entry-02-name*
        *entry-02-password*
      *entry-02-integer*
      *entry-02-real*
        *entry-02-path*
        *entry-02-command*))

(defun entry-02-on-change (widget new-text)
  "Update status when ENTRY text changes."
  (declare (ignore new-text))
  (setf *entry-02-status*
        (format nil "Updated ~a: ~a"
                (if (typep widget 'mnas-sdl3-gui/widgets:entry)
                    (cond ((eq widget *entry-02-name*) "Name")
                          ((eq widget *entry-02-password*) "Password")
                        ((eq widget *entry-02-integer*) "Integer")
                        ((eq widget *entry-02-real*) "Real")
                          ((eq widget *entry-02-path*) "Path")
                          ((eq widget *entry-02-command*) "Command")
                          (t "Entry"))
                    "Widget")
                (mnas-sdl3-gui/widgets:entry-text widget))))

(defun create-entry-02-widgets ()
  "Create several entry widgets demonstrating common input scenarios."
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :x 40 :y 20 :width 420 :height 28
                               :text "Entry Widget Scenarios"))
         (hint (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 40 :y 48 :width 420 :height 22
                              :text "Name, password, integer, real, path, command, and filters."))
         (name (make-instance 'mnas-sdl3-gui/widgets:entry
                               :x 40 :y 90 :width 320 :height 32
                               :text "Alice"
                               :max-length 64
                               :on-change #'entry-02-on-change))
         (password (make-instance 'mnas-sdl3-gui/widgets:password-entry
                                   :x 40 :y 140 :width 320 :height 32
                                   :text ""
                                   :cursor 0
                                   :max-length 32
                                   :on-change #'entry-02-on-change))
         (integer (make-instance 'mnas-sdl3-gui/widgets:integer-entry
                :x 40 :y 190 :width 320 :height 32
                :text "123"
                :max-length 12
                :on-change #'entry-02-on-change))
         (real (make-instance 'mnas-sdl3-gui/widgets:real-entry
                  :x 40 :y 240 :width 320 :height 32
                  :text "3.14"
                  :max-length 20
                  :on-change #'entry-02-on-change))
         (path (make-instance 'mnas-sdl3-gui/widgets:entry
                   :x 40 :y 290 :width 280 :height 32
                               :text "/tmp/output"
                               :max-length 120
                               :on-change #'entry-02-on-change))
         (browse (make-instance 'mnas-sdl3-gui/widgets:button
               :x 330 :y 290 :width 100 :height 32
                                 :text "Browse..."
                                 :on-click (lambda (widget)
                                             (declare (ignore widget))
                                             (setf *entry-02-status*
                                                   (format nil "Browse: ~A"
                                                           (mnas-sdl3-gui/widgets:entry-text *entry-02-path*))))))
         (command (make-instance 'mnas-sdl3-gui/widgets:entry
                :x 40 :y 340 :width 320 :height 32
                                  :text "ls -la"
                                  :max-length 128
                                  :on-change #'entry-02-on-change))
         (show-values (make-instance 'mnas-sdl3-gui/widgets:button
                    :x 40 :y 390 :width 150 :height 32
                                      :text "Show values"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                    (format t "[entry-02] Name=~A Password=~A Integer=~A Real=~A Path=~A Cmd=~A~%"
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-name*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-password*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-integer*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-real*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-path*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-command*))
                                                  (setf *entry-02-status*
                    (format nil "Name=~A Password=~A Integer=~A Real=~A Path=~A Cmd=~A"
                                                                (mnas-sdl3-gui/widgets:entry-text *entry-02-name*)
                                                                (mnas-sdl3-gui/widgets:entry-text *entry-02-password*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-integer*)
                      (mnas-sdl3-gui/widgets:entry-text *entry-02-real*)
                                                                (mnas-sdl3-gui/widgets:entry-text *entry-02-path*)
                                                                (mnas-sdl3-gui/widgets:entry-text *entry-02-command*))))))
         (status-label (make-instance 'mnas-sdl3-gui/widgets:label
                    :x 40 :y 440 :width 420 :height 22
                                      :text *entry-02-status*)))
    (setf *entry-02-name* name
          *entry-02-password* password
          *entry-02-integer* integer
          *entry-02-real* real
          *entry-02-path* path
          *entry-02-command* command
          *entry-02-widgets*
          (list title hint name password integer real path browse command show-values status-label))))

(sdl3:def-app-init entry-02-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Entry Demo" "1.0"
                         "com.mna.sdl3.gui.entry-02.demo")
  (when (not (sdl3:init :video))
    (format t "~A~%" (sdl3:get-error))
    (return-from entry-02-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Entry Widget Demo" 500 520 0)
    (if (not ok)
        (progn
          (format t "~A~%" (sdl3:get-error))
          (return-from entry-02-init :failure))
        (progn
          (setf *entry-02-window* window
                *entry-02-window-id* (sdl3:get-window-id window)
                *entry-02-renderer* renderer
                *entry-02-open* t
                *entry-02-result* nil
                *entry-02-active-modifiers* nil)
          (entry-02-register-commands)
          (entry-02-register-shortcuts)
          (setf *entry-02-toolbar* (entry-02-create-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *entry-02-toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *entry-02-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-entry-02-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus (entry-02-widgets)
                                                  *entry-02-name*))))
  :continue)

(sdl3:def-app-iterate entry-02-iterate ()
  (unless *entry-02-open*
    (return-from entry-02-iterate :success))
  (sdl3:set-render-draw-color *entry-02-renderer* 245 245 245 255)
  (sdl3:render-clear *entry-02-renderer*)
  (entry-02-sync-command-state)
  (when *entry-02-toolbar*
      (mnas-sdl3-gui/widgets:render-toolbar
       *entry-02-toolbar*
       *entry-02-renderer*
       0.0
       0.0))
    (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *entry-02-widgets*)
      do (mnas-sdl3-gui/widgets:render *entry-02-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
  (sdl3:render-present *entry-02-renderer*)
  :continue)

(sdl3:def-app-event entry-02-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *entry-02-open* nil)
       :success)
      (sdl3:mouse-motion-event
        (mnas-sdl3-gui/widgets:handle-mouse-motion-event
        *entry-02-widgets*
        ev)
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (when (and (slot-value ev 'sdl3:%down)
                    (and *entry-02-toolbar*
                         (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                          *entry-02-toolbar*
                          (round (slot-value ev 'sdl3:%x))
                          (round (slot-value ev 'sdl3:%y)))))
           (mnas-sdl3-gui/toolbar:toolbar-button-clicked
            *entry-02-toolbar*
            (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
             *entry-02-toolbar*
             (round (slot-value ev 'sdl3:%x))
             (round (slot-value ev 'sdl3:%y)))
            (list :window-id *entry-02-window-id*)))
         (mnas-sdl3-gui/widgets:handle-mouse-button-event *entry-02-widgets* ev)
       :continue)
      (sdl3:keyboard-event
       (entry-02-update-modifier-state ev)
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (entry-02-key-modifiers ev)
                  :context (list :window-id *entry-02-window-id*))
               (mnas-sdl3-gui/widgets:handle-widget-key-event
            *entry-02-widgets*
            (slot-value ev 'sdl3:%key)
            nil
            :mods (entry-02-key-modifiers ev)
            :on-escape (lambda ()
                 (setf *entry-02-open* nil)
                 :success)
            :on-return (lambda ()
                 (setf *entry-02-status*
                   (format nil "Command executed: ~A"
                       (mnas-sdl3-gui/widgets:entry-text *entry-02-command*)))
                 :success))))
      :continue)
    (sdl3:text-input-event
     (mnas-sdl3-gui/widgets:dispatch-focused-text-input
      *entry-02-widgets*
      (slot-value ev 'sdl3:%text))
     :continue)
    (t :continue))))

(sdl3:def-app-quit entry-02-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *entry-02-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *entry-02-renderer*
    (sdl3:destroy-renderer *entry-02-renderer*))
  (when *entry-02-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *entry-02-window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun entry-02 (&optional (style :flat))
  "Run the entry demo and return selected values when done."
  (setf *entry-02-style* style)
  (sdl3:enter-app-main-callbacks
   'entry-02-init
   'entry-02-iterate
   'entry-02-event
   'entry-02-quit)
  *entry-02-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry-02)
;;;; (entry-02)

;;;;(setf (mnas-sdl3-gui/widgets:entry-text *entry-02-name*) "name")

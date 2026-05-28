;;;; ./demos/dialog/entry/entry-01/entry-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)

(defparameter *entry-01-window* nil)
(defparameter *entry-01-renderer* nil)
(defparameter *entry-01-window-id* 0)
(defparameter *entry-01-layer-manager* nil)
(defparameter *entry-01-toolbar* nil)
(defparameter *entry-01-open* t)
(defparameter *entry-01-result* nil)
(defparameter *entry-01-input* nil)
(defparameter *entry-01-ok-button* nil)
(defparameter *entry-01-style* :flat)
(defparameter *entry-01-active-modifiers* nil)

(defun entry-01-key->modifier (key)
  "Return modifier keyword for KEY, or NIL when KEY is not a modifier key."
  (case key
    ((:lctrl :rctrl) :ctrl)
    ((:lshift :rshift) :shift)
    ((:lalt :ralt) :alt)
    (t nil)))

(defun entry-01-update-modifier-state (ev)
  "Update tracked modifier state from keyboard event EV and return active modifiers."
  (let ((modifier (entry-01-key->modifier (slot-value ev 'sdl3:%key))))
    (when modifier
      (if (slot-value ev 'sdl3:%down)
          (pushnew modifier *entry-01-active-modifiers*)
          (setf *entry-01-active-modifiers*
                (remove modifier *entry-01-active-modifiers*)))))
  *entry-01-active-modifiers*)

(defun entry-01-create-toolbar ()
  "Create toolbar for entry-01 command presenter."
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar :layout :horizontal :height 32)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :entry-01/ok
                                                   :label "OK"
                                                   :width 64)
           (mnas-sdl3-gui/toolbar:make-button-spec :entry-01/cancel
                                                   :label "Cancel"
                                                   :width 90)))
    toolbar))

(defun entry-01-sync-command-state ()
  "Sync dynamic toolbar state for entry-01 demo."
  (declare (ignore t))
  nil)

(defun entry-01-key-modifiers (ev)
  "Return a list of active keyboard modifiers for EV."
  (declare (ignore ev))
  (copy-list *entry-01-active-modifiers*))

(defun entry-01-log-key-event (ev &key char action)
  "Print debug information for keyboard event EV and current entry state."
  (let ((key (slot-value ev 'sdl3:%key))
        (mods (entry-01-key-modifiers ev))
        (selected (and *entry-01-input*
                       (mnas-sdl3-gui/widgets:get-entry-selected-text *entry-01-input*))))
    (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
            action key mods char *entry-01-input* (or selected ""))))

(defun entry-01-widgets ()
  "Return focus-traversable widgets in entry dialog."
  (list *entry-01-input* *entry-01-ok-button*))

(defparameter *entry-01-title* "Введите текст и нажмите ОК")
(defparameter *entry-01-hint* "Проверьте кириллицу: Съешь ещё этих мягких булок")

(defun create-entry-01-widgets ()
  "Create entry widget and OK button widgets for dialog demo."
  (let* ((text "Привет, мир!")
         (first-space (or (position #\Space text) (length text))))
    (setf *entry-01-input*
          (make-instance 'mnas-sdl3-gui/widgets:entry
                         :x 40 :y 90 :width 320 :height 36
                         :text text
                         :cursor first-space
                         :selection-start 0
                         :selection-end first-space
                         :max-length 128
                         :focused t)))
  (setf *entry-01-ok-button*
        (make-instance 'mnas-sdl3-gui/widgets:button
                       :x 150 :y 150 :width 100 :height 34
                       :text "ОК"
                       :on-click (lambda (widget)
                                   (declare (ignore widget))
                                   (entry-01-command :entry-01/ok))))
  (values))

(sdl3:def-app-init entry-01-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Edit Box Dialog Demo" "1.0"
                         "com.mna.sdl3.gui.entry-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from entry-01-init :failure))
  (setf *entry-01-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Entry Dialog + OK" 400 240 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from entry-01-init :failure))
        (progn
          (setf *entry-01-window* window
                *entry-01-renderer* renderer
                *entry-01-window-id* (sdl3:get-window-id window)
                *entry-01-open* t
                *entry-01-result* nil
                *entry-01-active-modifiers* nil)
          (mnas-sdl3-gui/window-manager:register-window
           *entry-01-layer-manager*
           *entry-01-window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *entry-01-layer-manager*
           *entry-01-window-id*)
          (entry-01-register-commands)
          (entry-01-register-shortcuts)
          (setf *entry-01-toolbar* (entry-01-create-toolbar))
          (mnas-sdl3-gui/widgets:set-widget-style *entry-01-style*)
          ;; TTF must be initialized after SDL video subsystem is ready.
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-entry-01-widgets)
          (entry-01-sync-command-state)
          (mnas-sdl3-gui/widgets:set-widget-focus (entry-01-widgets)
                                                  *entry-01-input*))))
  :continue)

(sdl3:def-app-iterate entry-01-iterate ()
  (unless *entry-01-open*
    (return-from entry-01-iterate :success))

  (sdl3:set-render-draw-color *entry-01-renderer* 230 230 230 255)
  (sdl3:render-clear *entry-01-renderer*)

  (mnas-sdl3-gui/widgets:render-text *entry-01-renderer*
                                     *entry-01-title* 40.0 40.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text *entry-01-renderer*
                                     *entry-01-hint* 40.0 62.0 '(70 70 70 255))

  (entry-01-sync-command-state)
  (when *entry-01-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *entry-01-toolbar*
     *entry-01-renderer*
     0.0
     0.0))

      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order (entry-01-widgets))
        do (mnas-sdl3-gui/widgets:render *entry-01-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (sdl3:render-present *entry-01-renderer*)
  :continue)

(sdl3:def-app-event entry-01-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *entry-01-open* nil)
       :success)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *entry-01-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                           *entry-01-layer-manager*
                                           window-id)
                                          window-id)
                                      window-id))
                (mx (round (slot-value ev 'sdl3:%x)))
                (my (round (slot-value ev 'sdl3:%y))))
           (when *entry-01-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *entry-01-layer-manager*
              target-window-id))
           (when (= target-window-id *entry-01-window-id*)
             (if (slot-value ev 'sdl3:%down)
                 (let ((button (and *entry-01-toolbar*
                                    (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                     *entry-01-toolbar*
                                     mx
                                     my))))
                     (if button
                       (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                        *entry-01-toolbar*
                        button
                        (list :window-id target-window-id))
                       (mnas-sdl3-gui/widgets:handle-widget-mouse-down
                        (entry-01-widgets) mx my)))
                   (mnas-sdl3-gui/widgets:handle-widget-mouse-up
                    (entry-01-widgets) mx my)))))
       :continue)
      (sdl3:keyboard-event
       (entry-01-update-modifier-state ev)
       (if (slot-value ev 'sdl3:%down)
           (if (slot-value ev 'sdl3:%repeat)
               :continue
               (let ((key (slot-value ev 'sdl3:%key)))
                 (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                          key
                          :mods (entry-01-key-modifiers ev)
                          :context (list :window-id *entry-01-window-id*))
                   (let ((result
                      (mnas-sdl3-gui/widgets:handle-widget-key-event
                       (entry-01-widgets)
                       key
                       nil
                       :mods (entry-01-key-modifiers ev)
                       :on-escape (lambda ()
                            (setf *entry-01-result* nil
                              *entry-01-open* nil)
                            :success)
                       :on-return (lambda ()
                            (setf *entry-01-result*
                              (mnas-sdl3-gui/widgets:entry-text *entry-01-input*)
                              *entry-01-open* nil)
                            :success))))
                     (entry-01-log-key-event ev :action :down)
                     result))))
           (progn
             (when (entry-01-key->modifier (slot-value ev 'sdl3:%key))
               (entry-01-log-key-event ev :action :up))
             :continue)))
      (sdl3:text-input-event
       ;; SDL text input already respects the current keyboard layout/IME.
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        (entry-01-widgets)
        (slot-value ev 'sdl3:%text))
       (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
               :text-input nil (copy-list *entry-01-active-modifiers*)
               (slot-value ev 'sdl3:%text)
               *entry-01-input*
               (mnas-sdl3-gui/widgets:get-entry-selected-text *entry-01-input*))
       :continue)
      (t :continue))))

(sdl3:def-app-quit entry-01-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *entry-01-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *entry-01-renderer*
    (sdl3:destroy-renderer *entry-01-renderer*))
  (when *entry-01-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *entry-01-window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun entry-01 (&optional (style :flat))
  "Run entry dialog and return entered text when OK is pressed.
Returns NIL when dialog is cancelled/closed."
  (setf *entry-01-style* style)
  (sdl3:enter-app-main-callbacks
   'entry-01-init
   'entry-01-iterate
   'entry-01-event
   'entry-01-quit)
  *entry-01-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/entry-01)
;;;; (entry-01)

;;;; (mnas-sdl3-gui/demos/dialog/entry-01:entry-01)

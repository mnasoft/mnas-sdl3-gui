;;;; ./demos/dialog/edit-box-ok-dialog-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *window-edit-dialog* nil)
(defparameter *renderer-edit-dialog* nil)
(defparameter *edit-dialog-open* t)
(defparameter *edit-dialog-result* nil)
(defparameter *edit-dialog-input* nil)
(defparameter *edit-dialog-ok-button* nil)
(defparameter *edit-dialog-style* :flat)
(defparameter *edit-dialog-active-modifiers* nil)

(defun edit-dialog-key->modifier (key)
  "Return modifier keyword for KEY, or NIL when KEY is not a modifier key."
  (case key
    ((:lctrl :rctrl) :ctrl)
    ((:lshift :rshift) :shift)
    ((:lalt :ralt) :alt)
    (t nil)))

(defun edit-dialog-update-modifier-state (ev)
  "Update tracked modifier state from keyboard event EV and return active modifiers."
  (let ((modifier (edit-dialog-key->modifier (slot-value ev 'sdl3:%key))))
    (when modifier
      (if (slot-value ev 'sdl3:%down)
          (pushnew modifier *edit-dialog-active-modifiers*)
          (setf *edit-dialog-active-modifiers*
                (remove modifier *edit-dialog-active-modifiers*)))))
  *edit-dialog-active-modifiers*)

(defun edit-dialog-key-modifiers (ev)
  "Return a list of active keyboard modifiers for EV."
  (declare (ignore ev))
  (copy-list *edit-dialog-active-modifiers*))

(defun edit-dialog-log-key-event (ev &key char action)
  "Print debug information for keyboard event EV and current edit-box state."
  (let ((key (slot-value ev 'sdl3:%key))
        (mods (edit-dialog-key-modifiers ev))
        (selected (and *edit-dialog-input*
                       (mnas-sdl3-gui/widgets:get-edit-box-selected-text *edit-dialog-input*))))
    (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
            action key mods char *edit-dialog-input* (or selected ""))))

(defun edit-dialog-widgets ()
  "Return focus-traversable widgets in edit dialog."
  (list *edit-dialog-input* *edit-dialog-ok-button*))

(defparameter *edit-dialog-title* "Введите текст и нажмите ОК")
(defparameter *edit-dialog-hint* "Проверьте кириллицу: Съешь ещё этих мягких булок")

(defun create-edit-dialog-widgets ()
  "Create edit-box and OK button widgets for dialog demo."
  (let* ((text "Привет, мир!")
         (first-space (or (position #\Space text) (length text))))
    (setf *edit-dialog-input*
          (make-instance 'mnas-sdl3-gui/widgets:edit-box
                         :x 40 :y 90 :width 320 :height 36
                         :text text
                         :cursor first-space
                         :selection-start 0
                         :selection-end first-space
                         :max-length 128
                         :focused t)))
  (setf *edit-dialog-ok-button*
        (make-instance 'mnas-sdl3-gui/widgets:button
                       :x 150 :y 150 :width 100 :height 34
             :text "ОК"
                       :on-click (lambda (widget)
                                   (declare (ignore widget))
                                   (setf *edit-dialog-result*
                                         (mnas-sdl3-gui/widgets:edit-box-text *edit-dialog-input*)
                                         *edit-dialog-open* nil))))
  (values))

(sdl3:def-app-init edit-dialog-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Edit Box Dialog Demo" "1.0"
                         "com.mna.sdl3.gui.edit-dialog.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from edit-dialog-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Edit Box + OK Dialog" 400 240 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from edit-dialog-init :failure))
        (progn
          (setf *window-edit-dialog* window
                *renderer-edit-dialog* renderer
                *edit-dialog-open* t
                *edit-dialog-result* nil
                *edit-dialog-active-modifiers* nil)
          (mnas-sdl3-gui/widgets:set-widget-style *edit-dialog-style*)
          ;; TTF must be initialized after SDL video subsystem is ready.
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-edit-dialog-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus (edit-dialog-widgets)
                                                  *edit-dialog-input*))))
  :continue)

(sdl3:def-app-iterate edit-dialog-iterate ()
  (unless *edit-dialog-open*
    (return-from edit-dialog-iterate :success))

  (sdl3:set-render-draw-color *renderer-edit-dialog* 230 230 230 255)
  (sdl3:render-clear *renderer-edit-dialog*)

  (mnas-sdl3-gui/widgets:render-text *renderer-edit-dialog*
                                     *edit-dialog-title* 40.0 40.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text *renderer-edit-dialog*
                                     *edit-dialog-hint* 40.0 62.0 '(70 70 70 255))

  (mnas-sdl3-gui/widgets:render-widget *renderer-edit-dialog* *edit-dialog-input*)
  (mnas-sdl3-gui/widgets:render-widget *renderer-edit-dialog* *edit-dialog-ok-button*)

  (sdl3:render-present *renderer-edit-dialog*)
  :continue)

(sdl3:def-app-event edit-dialog-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *edit-dialog-open* nil)
       :success)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down
                (edit-dialog-widgets) mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up
                (edit-dialog-widgets) mx my))))
       :continue)
      (sdl3:keyboard-event
       (edit-dialog-update-modifier-state ev)
       (if (slot-value ev 'sdl3:%down)
           (if (slot-value ev 'sdl3:%repeat)
               :continue
               (let* ((key (slot-value ev 'sdl3:%key))
              (result
               (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
            (edit-dialog-widgets)
            key
            :mods (edit-dialog-key-modifiers ev)
            :on-escape (lambda ()
                 (setf *edit-dialog-result* nil
                   *edit-dialog-open* nil)
                 :success)
            :on-return (lambda ()
                 (setf *edit-dialog-result*
                   (mnas-sdl3-gui/widgets:edit-box-text *edit-dialog-input*)
                   *edit-dialog-open* nil)
                 :success))))
                 (edit-dialog-log-key-event ev :action :down)
                 result))
           (progn
             (when (edit-dialog-key->modifier (slot-value ev 'sdl3:%key))
               (edit-dialog-log-key-event ev :action :up))
             :continue)))
      (sdl3:text-input-event
       ;; SDL text input already respects the current keyboard layout/IME.
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        (edit-dialog-widgets)
        (slot-value ev 'sdl3:%text))
       (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
               :text-input nil (copy-list *edit-dialog-active-modifiers*)
               (slot-value ev 'sdl3:%text)
               *edit-dialog-input*
               (mnas-sdl3-gui/widgets:get-edit-box-selected-text *edit-dialog-input*))
       :continue)
      (t :continue))))

(sdl3:def-app-quit edit-dialog-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *window-edit-dialog*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *renderer-edit-dialog*
    (sdl3:destroy-renderer *renderer-edit-dialog*))
  (when *window-edit-dialog*
    (sdl3:destroy-window *window-edit-dialog*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-edit-box-dialog-demo (&optional (style :flat))
  "Run edit-box dialog and return entered text when OK is pressed.
Returns NIL when dialog is cancelled/closed."
  (setf *edit-dialog-style* style)
  (sdl3:enter-app-main-callbacks
   'edit-dialog-init
   'edit-dialog-iterate
   'edit-dialog-event
   'edit-dialog-quit)
  *edit-dialog-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (mnas-sdl3-gui/demos/dialog:do-edit-box-dialog-demo)

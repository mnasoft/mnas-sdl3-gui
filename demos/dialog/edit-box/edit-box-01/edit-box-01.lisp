;;;; ./demos/dialog/edit-box-ok-dialog-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/edit-box-01)

(defparameter *edit-box-01-window* nil)
(defparameter *edit-box-01-renderer* nil)
(defparameter *edit-box-01-open* t)
(defparameter *edit-box-01-result* nil)
(defparameter *edit-box-01-input* nil)
(defparameter *edit-box-01-ok-button* nil)
(defparameter *edit-box-01-style* :flat)
(defparameter *edit-box-01-active-modifiers* nil)

(defun edit-box-01-key->modifier (key)
  "Return modifier keyword for KEY, or NIL when KEY is not a modifier key."
  (case key
    ((:lctrl :rctrl) :ctrl)
    ((:lshift :rshift) :shift)
    ((:lalt :ralt) :alt)
    (t nil)))

(defun edit-box-01-update-modifier-state (ev)
  "Update tracked modifier state from keyboard event EV and return active modifiers."
  (let ((modifier (edit-box-01-key->modifier (slot-value ev 'sdl3:%key))))
    (when modifier
      (if (slot-value ev 'sdl3:%down)
          (pushnew modifier *edit-box-01-active-modifiers*)
          (setf *edit-box-01-active-modifiers*
                (remove modifier *edit-box-01-active-modifiers*)))))
  *edit-box-01-active-modifiers*)

(defun edit-box-01-key-modifiers (ev)
  "Return a list of active keyboard modifiers for EV."
  (declare (ignore ev))
  (copy-list *edit-box-01-active-modifiers*))

(defun edit-box-01-log-key-event (ev &key char action)
  "Print debug information for keyboard event EV and current edit-box state."
  (let ((key (slot-value ev 'sdl3:%key))
        (mods (edit-box-01-key-modifiers ev))
        (selected (and *edit-box-01-input*
                       (mnas-sdl3-gui/widgets:get-edit-box-selected-text *edit-box-01-input*))))
    (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
            action key mods char *edit-box-01-input* (or selected ""))))

(defun edit-box-01-widgets ()
  "Return focus-traversable widgets in edit dialog."
  (list *edit-box-01-input* *edit-box-01-ok-button*))

(defparameter *edit-box-01-title* "Введите текст и нажмите ОК")
(defparameter *edit-box-01-hint* "Проверьте кириллицу: Съешь ещё этих мягких булок")

(defun create-edit-box-01-widgets ()
  "Create edit-box and OK button widgets for dialog demo."
  (let* ((text "Привет, мир!")
         (first-space (or (position #\Space text) (length text))))
    (setf *edit-box-01-input*
          (make-instance 'mnas-sdl3-gui/widgets:edit-box
                         :x 40 :y 90 :width 320 :height 36
                         :text text
                         :cursor first-space
                         :selection-start 0
                         :selection-end first-space
                         :max-length 128
                         :focused t)))
  (setf *edit-box-01-ok-button*
        (make-instance 'mnas-sdl3-gui/widgets:button
                       :x 150 :y 150 :width 100 :height 34
             :text "ОК"
                       :on-click (lambda (widget)
                                   (declare (ignore widget))
                                   (setf *edit-box-01-result*
                                         (mnas-sdl3-gui/widgets:edit-box-text *edit-box-01-input*)
                                         *edit-box-01-open* nil))))
  (values))

(sdl3:def-app-init edit-box-01-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Edit Box Dialog Demo" "1.0"
                         "com.mna.sdl3.gui.edit-box-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from edit-box-01-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Edit Box + OK Dialog" 400 240 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from edit-box-01-init :failure))
        (progn
          (setf *edit-box-01-window* window
                *edit-box-01-renderer* renderer
                *edit-box-01-open* t
                *edit-box-01-result* nil
                *edit-box-01-active-modifiers* nil)
          (mnas-sdl3-gui/widgets:set-widget-style *edit-box-01-style*)
          ;; TTF must be initialized after SDL video subsystem is ready.
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-edit-box-01-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus (edit-box-01-widgets)
                                                  *edit-box-01-input*))))
  :continue)

(sdl3:def-app-iterate edit-box-01-iterate ()
  (unless *edit-box-01-open*
    (return-from edit-box-01-iterate :success))

  (sdl3:set-render-draw-color *edit-box-01-renderer* 230 230 230 255)
  (sdl3:render-clear *edit-box-01-renderer*)

  (mnas-sdl3-gui/widgets:render-text *edit-box-01-renderer*
                                     *edit-box-01-title* 40.0 40.0 '(0 0 0 255))
  (mnas-sdl3-gui/widgets:render-text *edit-box-01-renderer*
                                     *edit-box-01-hint* 40.0 62.0 '(70 70 70 255))

  (mnas-sdl3-gui/widgets:render-widgets *edit-box-01-renderer* (edit-box-01-widgets))

  (sdl3:render-present *edit-box-01-renderer*)
  :continue)

(sdl3:def-app-event edit-box-01-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *edit-box-01-open* nil)
       :success)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down
                (edit-box-01-widgets) mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up
                (edit-box-01-widgets) mx my))))
       :continue)
      (sdl3:keyboard-event
       (edit-box-01-update-modifier-state ev)
       (if (slot-value ev 'sdl3:%down)
           (if (slot-value ev 'sdl3:%repeat)
               :continue
               (let* ((key (slot-value ev 'sdl3:%key))
              (result
               (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
            (edit-box-01-widgets)
            key
            :mods (edit-box-01-key-modifiers ev)
            :on-escape (lambda ()
                 (setf *edit-box-01-result* nil
                   *edit-box-01-open* nil)
                 :success)
            :on-return (lambda ()
                 (setf *edit-box-01-result*
                   (mnas-sdl3-gui/widgets:edit-box-text *edit-box-01-input*)
                   *edit-box-01-open* nil)
                 :success))))
                 (edit-box-01-log-key-event ev :action :down)
                 result))
           (progn
             (when (edit-box-01-key->modifier (slot-value ev 'sdl3:%key))
               (edit-box-01-log-key-event ev :action :up))
             :continue)))
      (sdl3:text-input-event
       ;; SDL text input already respects the current keyboard layout/IME.
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        (edit-box-01-widgets)
        (slot-value ev 'sdl3:%text))
       (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
               :text-input nil (copy-list *edit-box-01-active-modifiers*)
               (slot-value ev 'sdl3:%text)
               *edit-box-01-input*
               (mnas-sdl3-gui/widgets:get-edit-box-selected-text *edit-box-01-input*))
       :continue)
      (t :continue))))

(sdl3:def-app-quit edit-box-01-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *edit-box-01-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *edit-box-01-renderer*
    (sdl3:destroy-renderer *edit-box-01-renderer*))
  (when *edit-box-01-window*
    (sdl3:destroy-window *edit-box-01-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun edit-box-01 (&optional (style :flat))
  "Run edit-box dialog and return entered text when OK is pressed.
Returns NIL when dialog is cancelled/closed."
  (setf *edit-box-01-style* style)
  (sdl3:enter-app-main-callbacks
   'edit-box-01-init
   'edit-box-01-iterate
   'edit-box-01-event
   'edit-box-01-quit)
  *edit-box-01-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (edit-box-01)

;;;; ./demos/dialog/edit-box-ok-dialog-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *window-edit-dialog* nil)
(defparameter *renderer-edit-dialog* nil)
(defparameter *edit-dialog-open* t)
(defparameter *edit-dialog-result* nil)
(defparameter *edit-dialog-input* nil)
(defparameter *edit-dialog-ok-button* nil)
(defparameter *edit-dialog-style* :flat)

(defun edit-dialog-tab-backward-p (ev)
  "Return true when Tab navigation should move backward."
  (let ((mods (slot-value ev 'sdl3:%mod)))
    (typecase mods
      (list (or (member :alt mods) (member :lalt mods) (member :ralt mods)
                (member :shift mods) (member :lshift mods) (member :rshift mods)))
      (symbol (member mods '(:alt :lalt :ralt :shift :lshift :rshift)))
      (integer (not (zerop (logand mods #x0303))))
      (t nil))))

(defun edit-dialog-widgets ()
  "Return focus-traversable widgets in edit dialog."
  (list *edit-dialog-input* *edit-dialog-ok-button*))

(defparameter *edit-dialog-title* "Введите текст и нажмите ОК")
(defparameter *edit-dialog-hint* "Проверьте кириллицу: Съешь ещё этих мягких булок")

(defun insert-text-into-edit-box (widget text)
  "Insert TEXT into edit-box WIDGET at cursor position."
  (loop for ch across text
        do (mnas-sdl3-gui/widgets:handle-widget-key-press widget nil ch)))

(defun create-edit-dialog-widgets ()
  "Create edit-box and OK button widgets for dialog demo."
  (setf *edit-dialog-input*
        (make-instance 'mnas-sdl3-gui/widgets:edit-box
                       :x 40 :y 90 :width 320 :height 36
           :text "Привет, мир!"
           :cursor 12
                       :max-length 128
                       :focused t))
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
                *edit-dialog-result* nil)
          (mnas-sdl3-gui/widgets:set-widget-style *edit-dialog-style*)
          ;; TTF must be initialized after SDL video subsystem is ready.
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (sdl3:start-text-input window)
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
               (progn
                 (when (mnas-sdl3-gui/widgets:handle-widget-mouse-down *edit-dialog-input* mx my)
                   (mnas-sdl3-gui/widgets:set-widget-focus (edit-dialog-widgets)
                                                           *edit-dialog-input*))
                 (when (mnas-sdl3-gui/widgets:handle-widget-mouse-down *edit-dialog-ok-button* mx my)
                   (mnas-sdl3-gui/widgets:set-widget-focus (edit-dialog-widgets)
                                                           *edit-dialog-ok-button*)))
               (mnas-sdl3-gui/widgets:handle-widget-mouse-up *edit-dialog-ok-button* mx my))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
          (let ((key (slot-value ev 'sdl3:%key)))
           (cond
             ((eq key :escape)
              (setf *edit-dialog-result* nil
                    *edit-dialog-open* nil)
              :success)
             ((eq key :tab)
              (mnas-sdl3-gui/widgets:move-widget-focus (edit-dialog-widgets)
                                                       :backward (edit-dialog-tab-backward-p ev))
              :continue)
             ((eq key :return)
              (setf *edit-dialog-result*
                    (mnas-sdl3-gui/widgets:edit-box-text *edit-dialog-input*)
                    *edit-dialog-open* nil)
              :success)
             ((eq key :space)
              (let ((focused (mnas-sdl3-gui/widgets:focused-widget (edit-dialog-widgets))))
                (when focused
                  (mnas-sdl3-gui/widgets:handle-widget-key-press focused :space nil)))
              :continue)
             ((member key '(:backspace :delete :left :right :home :end :pageup :pagedown))
              (mnas-sdl3-gui/widgets:handle-widget-key-press
               *edit-dialog-input* key nil)
              :continue)
             (t
              :continue))))
       :continue)
      (sdl3:text-input-event
       ;; SDL text input already respects the current keyboard layout/IME.
       (insert-text-into-edit-box *edit-dialog-input* (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit edit-dialog-quit (result)
  (declare (ignore result))
  (when *window-edit-dialog*
    (sdl3:stop-text-input *window-edit-dialog*))
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

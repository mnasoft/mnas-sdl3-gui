;;;; ./demos/dialog/edit-box-ok-dialog-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *window-edit-dialog* nil)
(defparameter *renderer-edit-dialog* nil)
(defparameter *edit-dialog-open* t)
(defparameter *edit-dialog-result* nil)
(defparameter *edit-dialog-input* nil)
(defparameter *edit-dialog-ok-button* nil)

(defun keymod-active-p (mods mod-key)
  "Return T when MOD-KEY is active in SDL3 keyboard modifiers value MODS."
  (cond
    ((listp mods)
     (member mod-key mods))
    ((keywordp mods)
     (eq mods mod-key))
    (t
     nil)))

(defun key-to-char (key shift-active-p caps-active-p)
  "Convert SDL3 key keyword to character with proper case handling."
  (cond
    ((and (keywordp key)
          (= (length (symbol-name key)) 1))
     (let* ((ch (char (symbol-name key) 0))
            (alpha (alpha-char-p ch))
            ;; For letters, Shift and CapsLock both affect case.
            (upper-p (if alpha
                         (if caps-active-p
                             (not shift-active-p)
                             shift-active-p)
                         nil)))
       (cond
         ((not alpha)
          ch)
         (upper-p
          (char-upcase ch))
         (t
          (char-downcase ch)))))
    ((eq key :space)
     #\Space)
    ((eq key :period)
     #\.)
    ((eq key :comma)
     #\,)
    ((eq key :minus)
     #\-)
    ((eq key :slash)
     #\/)
    (t
     nil)))

(defun create-edit-dialog-widgets ()
  "Create edit-box and OK button widgets for dialog demo."
  (setf *edit-dialog-input*
        (make-instance 'mnas-sdl3-gui/widgets:edit-box
                       :x 40 :y 90 :width 320 :height 36
                       :text ""
                       :cursor 0
                       :max-length 128
                       :focused t))
  (setf *edit-dialog-ok-button*
        (make-instance 'mnas-sdl3-gui/widgets:button
                       :x 150 :y 150 :width 100 :height 34
                       :text "OK"
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
          (create-edit-dialog-widgets))))
  :continue)

(sdl3:def-app-iterate edit-dialog-iterate ()
  (unless *edit-dialog-open*
    (return-from edit-dialog-iterate :success))

  (sdl3:set-render-draw-color *renderer-edit-dialog* 230 230 230 255)
  (sdl3:render-clear *renderer-edit-dialog*)

  (sdl3:set-render-draw-color *renderer-edit-dialog* 0 0 0 255)
  (sdl3:render-debug-text *renderer-edit-dialog* 40.0 40.0 "Enter text and press OK")

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
       (when (and (slot-value ev 'sdl3:%down)
                  (= (slot-value ev 'sdl3:%button) 1))
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (mnas-sdl3-gui/widgets:handle-widget-click *edit-dialog-input* mx my)
           (mnas-sdl3-gui/widgets:handle-widget-click *edit-dialog-ok-button* mx my)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
          (let* ((key (slot-value ev 'sdl3:%key))
            (mods (slot-value ev 'sdl3:%mod))
            (shift-active-p (or (keymod-active-p mods :lshift)
                 (keymod-active-p mods :rshift)))
            (caps-active-p (keymod-active-p mods :caps))
            (char (key-to-char key shift-active-p caps-active-p)))
           (cond
             ((eq key :escape)
              (setf *edit-dialog-result* nil
                    *edit-dialog-open* nil)
              :success)
             ((eq key :return)
              (setf *edit-dialog-result*
                    (mnas-sdl3-gui/widgets:edit-box-text *edit-dialog-input*)
                    *edit-dialog-open* nil)
              :success)
             (t
              (mnas-sdl3-gui/widgets:handle-widget-key-press
               *edit-dialog-input* key char)
              :continue))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit edit-dialog-quit (result)
  (declare (ignore result))
  (when *renderer-edit-dialog*
    (sdl3:destroy-renderer *renderer-edit-dialog*))
  (when *window-edit-dialog*
    (sdl3:destroy-window *window-edit-dialog*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-edit-box-dialog-demo ()
  "Run edit-box dialog and return entered text when OK is pressed.
Returns NIL when dialog is cancelled/closed."
  (sdl3:enter-app-main-callbacks
   'edit-dialog-init
   'edit-dialog-iterate
   'edit-dialog-event
   'edit-dialog-quit)
  *edit-dialog-result*)

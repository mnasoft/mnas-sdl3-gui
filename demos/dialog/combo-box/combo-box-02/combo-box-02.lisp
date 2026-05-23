;;;; ./demos/dialog/editable-combo-box-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-02)

(defparameter *combo-box-02-window* nil)
(defparameter *combo-box-02-window-id* 0)
(defparameter *combo-box-02-toolbar* nil)
(defparameter *combo-box-02-open* t)
(defparameter *combo-box-02-style* :flat)
(defparameter *combo-box-02-widgets* nil)
(defparameter *combo-box-02-editable* nil)
(defparameter *combo-box-02-status*
  "Editable combo box demo. Type a value, select an item, or add a new one.")
(defparameter +combo-box-02-window-height+ 292)
(defparameter +combo-box-02-toolbar-height+ 32)

(defun combo-box-02-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun combo-box-02-register-commands ()
  "Register commands for combo-box-02 demo."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :combo-box-02/quit
    "Quit combo-box demo"
    :group :combo-box-02
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *combo-box-02-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :combo-box-02/add-current
    "Add current text to combo-box"
    :group :combo-box-02
    :shortcut :enter
    :execute (lambda (context)
               (declare (ignore context))
               (let ((text (mnas-sdl3-gui/widgets:entry-text *combo-box-02-editable*)))
                 (when (and text (not (string= text "")))
                   (mnas-sdl3-gui/widgets:combo-box-add-item *combo-box-02-editable* text)
                   (setf *combo-box-02-status*
                         (format nil "Added and selected: ~A" text))))
               t))
   :replace t))

(defun combo-box-02-register-shortcuts ()
  "Register keyboard shortcuts for combo-box-02 demo."
  (mnas-sdl3-gui/commands:register-shortcut :combo-box-02/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :combo-box-02/add-current :enter :replace t)
  t)

(defun combo-box-02-create-toolbar ()
  "Create toolbar for the combo-box-02 demo."
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar
                  :layout :horizontal
                  :height +combo-box-02-toolbar-height+)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :combo-box-02/add-current
                                                   :label "Add"
                                                   :width 56)
           (mnas-sdl3-gui/toolbar:make-button-spec :combo-box-02/quit
                                                   :label "Quit"
                                                   :width 64)))
    toolbar))

(defun combo-box-02-sync-command-state ()
  "Sync command state for combo-box-02 toolbar." 
  (let ((add-cmd (mnas-sdl3-gui/commands:find-command :combo-box-02/add-current))
        (text (and *combo-box-02-editable*
                   (mnas-sdl3-gui/widgets:entry-text *combo-box-02-editable*))))
    (when add-cmd
      (mnas-sdl3-gui/commands:set-command-enabled
       add-cmd
       (> (length (string-trim '(#\Space #\Tab #\Newline #\Return) (or text ""))) 0)))))

(defun create-combo-box-02-demo-widgets ()
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :x 20 :y 18 :width 560 :height 24
                               :text "Editable Combo-Box Demo"))
         (hint (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 42 :width 560 :height 24
                              :text "Type a value or choose from the list. Press buttons to report or add the current text."))
         (editable (make-instance 'mnas-sdl3-gui/widgets:editable-combo-box
                                  :x 20 :y 86 :width 380 :height 36
                                  :main-height 36
                                  :items '("Preset A" "Preset B" "Preset C")
                                  :selected-index 0
                                  :text ""
                                  :cursor 0
                                  :max-length 100
                                  :max-visible-items 6
                                  :placeholder "Type new item or select from list"))
         (report (make-instance 'mnas-sdl3-gui/widgets:button
                                 :x 20 :y 140 :width 180 :height 34
                                 :text "Show current value"
                                 :on-click (lambda (widget)
                                             (declare (ignore widget))
                                             (setf *combo-box-02-status*
                                                   (format nil "Value: ~A  Text: ~A"
                                                           (mnas-sdl3-gui/widgets:widget-value editable)
                                                           (mnas-sdl3-gui/widgets:entry-text editable))))))
         (add-item (make-instance 'mnas-sdl3-gui/widgets:button
                                  :x 220 :y 140 :width 180 :height 34
                                  :text "Add current text"
                                  :on-click (lambda (widget)
                                              (declare (ignore widget))
                                              (let ((text (mnas-sdl3-gui/widgets:entry-text editable)))
                                                (if (and text (not (string= text "")))
                                                    (progn
                                                      (mnas-sdl3-gui/widgets:combo-box-add-item editable text)
                                                      (setf *combo-box-02-status*
                                                            (format nil "Added and selected: ~A" text)))
                                                    (setf *combo-box-02-status* "Type a non-empty value to add.")))))))
    (setf *combo-box-02-editable* editable
          *combo-box-02-widgets* (list title hint editable report add-item))
    *combo-box-02-widgets*))

(sdl3:def-app-init combo-box-02-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Editable Combo-Box Demo" "1.0"
                         "com.mna.sdl3.gui.combo-box-02.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from combo-box-02-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Editable Combo-Box Demo" 640 +combo-box-02-window-height+ 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from combo-box-02-demo-init :failure))
        (progn
          (setf *combo-box-02-window* window
                *combo-box-02-window-id* (sdl3:get-window-id window)
                *combo-box-02-renderer* renderer
                *combo-box-02-open* t
                *combo-box-02-status* "Editable combo box demo. Type a value, select an item, or add a new one.")
          (combo-box-02-register-commands)
          (combo-box-02-register-shortcuts)
          (setf *combo-box-02-toolbar* (combo-box-02-create-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *combo-box-02-toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *combo-box-02-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-combo-box-02-demo-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus *combo-box-02-widgets*
                                                  (third *combo-box-02-widgets*))
          (mnas-sdl3-gui/widgets:start-widget-text-input *combo-box-02-window*))))
  :continue)

(sdl3:def-app-iterate combo-box-02-demo-iterate ()
  (unless *combo-box-02-open*
    (return-from combo-box-02-demo-iterate :success))
  (sdl3:set-render-draw-color *combo-box-02-renderer* 240 240 240 255)
  (sdl3:render-clear *combo-box-02-renderer*)
  (combo-box-02-sync-command-state)
  (when *combo-box-02-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *combo-box-02-toolbar*
     *combo-box-02-renderer*
     0.0
     (- +combo-box-02-window-height+ +combo-box-02-toolbar-height+)))
  (mnas-sdl3-gui/widgets:render-widgets *combo-box-02-renderer* *combo-box-02-widgets*)
  (mnas-sdl3-gui/widgets:render-text *combo-box-02-renderer*
                                     *combo-box-02-status*
                                     20.0 200.0 '(40 40 40 255))
  (sdl3:render-present *combo-box-02-renderer*)
  :continue)

(sdl3:def-app-event combo-box-02-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *combo-box-02-open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *combo-box-02-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y)))
               (toolbar-y-offset (- +combo-box-02-window-height+ +combo-box-02-toolbar-height+)))
           (if (slot-value ev 'sdl3:%down)
               (let ((button (and *combo-box-02-toolbar*
                                  (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                   *combo-box-02-toolbar*
                                   mx
                                   (- my toolbar-y-offset)))))
                 (if button
                     (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                      *combo-box-02-toolbar*
                      button
                      (list :window-id *combo-box-02-window-id*))
                     (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down
                      *combo-box-02-widgets* mx my)))
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up
                *combo-box-02-widgets* mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-wheel
        *combo-box-02-widgets*
        (round (slot-value ev 'sdl3:%mouse-x))
        (round (slot-value ev 'sdl3:%mouse-y))
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
                  (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *combo-box-02-window-id*))
           (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
            *combo-box-02-widgets*
            (slot-value ev 'sdl3:%key)
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (setf *combo-box-02-open* nil)
                         :success))))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *combo-box-02-widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit combo-box-02-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *combo-box-02-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *combo-box-02-renderer*
    (sdl3:destroy-renderer *combo-box-02-renderer*))
  (when *combo-box-02-window*
    (sdl3:destroy-window *combo-box-02-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun combo-box-02 (&optional (style :flat))
  "Run the editable combo-box demo with STYLE (:flat, :windows, :motif)."
  (setf *combo-box-02-style* style)
  (sdl3:enter-app-main-callbacks
   'combo-box-02-demo-init
   'combo-box-02-demo-iterate
   'combo-box-02-demo-event
   'combo-box-02-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-02)
;;;; (combo-box-02)

;;;; (mnas-sdl3-gui/demos/dialog/combo-box-02:combo-box-02)

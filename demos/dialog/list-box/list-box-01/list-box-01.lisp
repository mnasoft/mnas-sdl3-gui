;;;; ./demos/dialog/list-box/list-box-01/list-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(defparameter *list-box-01-window* nil)
(defparameter *list-box-01-window-id* 0)
(defparameter *list-box-01-toolbar* nil)
(defparameter *list-box-01-open* t)
(defparameter *list-box-01-result* nil)
(defparameter *list-box-01-style* :windows)
(defparameter *list-box-01-widgets* nil)
(defparameter *list-box-01-left* nil)
(defparameter *list-box-01-right* nil)
(defparameter *list-box-01-ok* nil)
(defparameter *list-box-01-cancel* nil)
(defparameter +list-box-01-window-height+ 352)
(defparameter +list-box-01-toolbar-height+ 32)

(defun list-box-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun list-box-01-register-commands ()
  "Register commands for list-box-01 demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/quit
    "Quit list-box demo"
    :group :list-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *list-box-01-result* nil
                     *list-box-01-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/ok
    "Confirm list selection"
    :group :list-box-01
    :shortcut :enter
    :execute (lambda (context)
               (declare (ignore context))
               (setf *list-box-01-result*
                     (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-left*)
                                      (mnas-sdl3-gui/widgets:list-box-items *list-box-01-left*))
                           :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-right*)
                                       (mnas-sdl3-gui/widgets:list-box-items *list-box-01-right*)))
                     *list-box-01-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/cancel
    "Cancel list selection"
    :group :list-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *list-box-01-result* nil
                     *list-box-01-open* nil)
               t))
   :replace t))

(defun list-box-01-register-shortcuts ()
  "Register keyboard shortcuts for list-box-01 demo." 
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/ok :enter :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/cancel :escape :replace t)
  t)

(defun list-box-01-create-toolbar ()
  "Create toolbar for list-box-01 demo." 
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar
                  :layout :horizontal
                  :height +list-box-01-toolbar-height+)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :list-box-01/ok
                                                   :label "OK"
                                                   :width 56)
           (mnas-sdl3-gui/toolbar:make-button-spec :list-box-01/cancel
                                                   :label "Cancel"
                                                   :width 72)
           (mnas-sdl3-gui/toolbar:make-button-spec :list-box-01/quit
                                                   :label "Quit"
                                                   :width 64)))
    toolbar))

(defun list-box-01-sync-command-state ()
  "Sync command state for list-box-01 toolbar." 
  (let* ((ok-cmd (mnas-sdl3-gui/commands:find-command :list-box-01/ok))
         (left-index (and *list-box-01-left*
                          (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-left*)))
         (right-index (and *list-box-01-right*
                           (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-right*))))
    (when ok-cmd
      (mnas-sdl3-gui/commands:set-command-enabled ok-cmd
                                                  (and (integerp left-index)
                                                       (<= 0 left-index (1- (length (mnas-sdl3-gui/widgets:list-box-items *list-box-01-left*))))
                                                       (integerp right-index)
                                                       (<= 0 right-index (1- (length (mnas-sdl3-gui/widgets:list-box-items *list-box-01-right*)))))))))

(defun list-box-01-items (count prefix)
  "Create COUNT demo strings prefixed by PREFIX."
  (loop for index from 1 to count
        collect (format nil "~A ~D" prefix index)))

(defun create-list-box-01-demo-widgets ()
  "Create widgets for the list-box-01 demo."
  (let ((title (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 18 :width 600 :height 24
                              :text "Two List-Boxes Demo"))
        (subtitle (make-instance 'mnas-sdl3-gui/widgets:label
                                 :x 20 :y 42 :width 600 :height 22
                                 :text "Слева 50 элементов, справа 4 элемента")))
    (setf *list-box-01-left*
          (make-instance 'mnas-sdl3-gui/widgets:list-box
                         :x 20 :y 74 :width 290 :height 170
                         :items (list-box-01-items 50 "Элемент")
                         :selected-index 0
                         :item-height 24)
          *list-box-01-right*
          (make-instance 'mnas-sdl3-gui/widgets:list-box
                         :x 330 :y 74 :width 290 :height 170
                         :items (list-box-01-items 4 "Пункт")
                         :selected-index 0
                         :item-height 24)
          *list-box-01-ok*
          (make-instance 'mnas-sdl3-gui/widgets:button
                         :x 350 :y 264 :width 120 :height 34
                         :text "Ок"
                         :on-click (lambda (widget)
                                     (declare (ignore widget))
                                     (setf *list-box-01-result*
                                           (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-left*)
                                                            (mnas-sdl3-gui/widgets:list-box-items *list-box-01-left*))
                                                 :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-right*)
                                                             (mnas-sdl3-gui/widgets:list-box-items *list-box-01-right*)))
                                           *list-box-01-open* nil)))
          *list-box-01-cancel*
          (make-instance 'mnas-sdl3-gui/widgets:button
                         :x 490 :y 264 :width 130 :height 34
                         :text "Cancel"
                         :on-click (lambda (widget)
                                     (declare (ignore widget))
                                     (setf *list-box-01-result* nil
                                           *list-box-01-open* nil)))
          *list-box-01-widgets*
          (list title subtitle
                *list-box-01-left*
                *list-box-01-right*
                *list-box-01-ok*
                *list-box-01-cancel*))
    *list-box-01-widgets*))

(sdl3:def-app-init list-box-01-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Two List-Boxes Demo" "1.0"
                         "com.mna.sdl3.gui.list-box-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from list-box-01-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Two List-Boxes Demo" 640 +list-box-01-window-height+ 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from list-box-01-demo-init :failure))
        (progn
          (setf *list-box-01-window* window
                *list-box-01-window-id* (sdl3:get-window-id window)
                *list-box-01-renderer* renderer
                *list-box-01-open* t
                *list-box-01-result* nil)
          (list-box-01-register-commands)
          (list-box-01-register-shortcuts)
          (setf *list-box-01-toolbar* (list-box-01-create-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *list-box-01-toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *list-box-01-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-list-box-01-demo-widgets)
          (mnas-sdl3-gui/widgets:set-widget-focus *list-box-01-widgets*
                                                  *list-box-01-left*))))
  :continue)

(sdl3:def-app-iterate list-box-01-demo-iterate ()
  (unless *list-box-01-open*
    (return-from list-box-01-demo-iterate :success))

  (sdl3:set-render-draw-color *list-box-01-renderer* 236 236 236 255)
  (sdl3:render-clear *list-box-01-renderer*)
  (list-box-01-sync-command-state)
  (when *list-box-01-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *list-box-01-toolbar*
     *list-box-01-renderer*
     0.0
     (- +list-box-01-window-height+ +list-box-01-toolbar-height+)))

  (mnas-sdl3-gui/widgets:render-widgets *list-box-01-renderer* *list-box-01-widgets*)

  (sdl3:render-present *list-box-01-renderer*)
  :continue)

(sdl3:def-app-event list-box-01-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *list-box-01-open* nil)
       :success)
      (sdl3:mouse-motion-event
         (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
        *list-box-01-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y)))
               (toolbar-y-offset (- +list-box-01-window-height+ +list-box-01-toolbar-height+)))
           (if (slot-value ev 'sdl3:%down)
               (let ((button (and *list-box-01-toolbar*
                                  (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                   *list-box-01-toolbar*
                                   mx
                                   (- my toolbar-y-offset)))))
                 (if button
                       (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                        *list-box-01-toolbar*
                        button
                        (list :window-id *list-box-01-window-id*))
                       (mnas-sdl3-gui/widgets:handle-widget-mouse-down *list-box-01-widgets* mx my)))
                     (mnas-sdl3-gui/widgets:handle-widget-mouse-up *list-box-01-widgets* mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
        *list-box-01-widgets*
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
                  :context (list :window-id *list-box-01-window-id*))
           (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
            *list-box-01-widgets*
            (slot-value ev 'sdl3:%key)
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (setf *list-box-01-result* nil
                               *list-box-01-open* nil)
                         :success)
            :on-return (lambda ()
                         (setf *list-box-01-result*
                               (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-left*)
                                                (mnas-sdl3-gui/widgets:list-box-items *list-box-01-left*))
                                     :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *list-box-01-right*)
                                                 (mnas-sdl3-gui/widgets:list-box-items *list-box-01-right*)))
                               *list-box-01-open* nil)
                         :success))))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *list-box-01-widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit list-box-01-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *list-box-01-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *list-box-01-renderer*
    (sdl3:destroy-renderer *list-box-01-renderer*))
  (when *list-box-01-window*
    (sdl3:destroy-window *list-box-01-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun list-box-01 (&optional (style :windows))
  "Run demo with two list-box widgets and OK/Cancel buttons."
  (setf *list-box-01-style* style)
  (sdl3:enter-app-main-callbacks
   'list-box-01-demo-init
   'list-box-01-demo-iterate
   'list-box-01-demo-event
   'list-box-01-demo-quit)
  *list-box-01-result*)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/list-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/list-box-01)
;;;; (list-box-01)

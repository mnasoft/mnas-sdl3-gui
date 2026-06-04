;;;; ./demos/menu/screen-menu-classes.lisp

;;; /demos/menu/screen-menu-classes.lisp

(in-package :mnas-sdl3-gui/demos/menu)

(defparameter *window-screen-menu* nil)
(defparameter *renderer-screen-menu* nil)
(defparameter *screen-menu-window-id* 0)
(defparameter *screen-menu-layer-manager* nil)
(defparameter *menu-bar-demo* nil)
(defparameter *toolbar-demo* nil)
(defparameter *status-message*
  "Class-based menu demo. Click File/Edit/Help or toolbar buttons.")
(defparameter *menu-demo-request-quit* nil)

(defconstant +mouse-button-left+ 1)

(defun register-menu-demo-commands ()
  "Register command handlers used by the menu demo." 
  (flet ((register (id title)
           (mnas-sdl3-gui/commands:register-command
            (mnas-sdl3-gui/commands:make-command
             id
             title
             :group :menu-demo
             :execute (lambda (context)
                        (setf *status-message*
                              (format nil "Action: ~a (~a)"
                                      (getf context :label title)
                                      id))
                        (unless (eq id :quit)
                          :continue)
                        t))
            :replace t)))
    (register :new "New")
    (register :open "Open")
    (register :recent-alpha "alpha.txt")
    (register :recent-beta "beta.txt")
    (register :clear-recent "Clear Recent")
    (register :undo "Undo")
    (register :redo "Redo")
    (register :preferences "Preferences")
    (register :docs "Documentation")
    (register :about "About")
    (register :quit "Quit")
    (mnas-sdl3-gui/commands:register-command
     (mnas-sdl3-gui/commands:make-command
      :menu-demo/escape
      "Escape in menu demo"
      :group :menu-demo
      :shortcut :escape
      :execute (lambda (context)
           (let ((bar (getf context :menu-bar)))
             (if (and bar (mnas-sdl3-gui/menu/model:bar-open-menu-index bar))
               (mnas-sdl3-gui/menu/model:close-menu bar)
               (setf *menu-demo-request-quit* t))
             t)))
     :replace t)
    (mnas-sdl3-gui/commands:register-shortcut
     :menu-demo/escape
     :escape
     :replace t)))

(defun make-demo-menu-bar ()
  (let* ((recent-submenu
           (make-instance 'mnas-sdl3-gui/menu/model:dropdown-menu
                          :title "Recent"
                          :entries (list
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "alpha.txt" :hotkey ""
                                                   :command-id :recent-alpha)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "beta.txt" :hotkey ""
                                                   :command-id :recent-beta)
                                    (make-instance 'mnas-sdl3-gui/menu/model:separator-entry)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Clear Recent" :hotkey ""
                                                   :command-id :clear-recent))))
         (file-menu
           (make-instance 'mnas-sdl3-gui/menu/model:dropdown-menu
                          :title "File"
                          :entries (list
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "New" :hotkey "Ctrl+N"
                                                   :command-id :new)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Open" :hotkey "Ctrl+O"
                                                   :command-id :open)
                                    (make-instance 'mnas-sdl3-gui/menu/model:separator-entry)
                                    (make-instance 'mnas-sdl3-gui/menu/model:submenu-entry
                                                   :label "Recent"
                                                   :submenu recent-submenu)
                                    (make-instance 'mnas-sdl3-gui/menu/model:separator-entry)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Quit" :hotkey "Ctrl+Q"
                                                   :command-id :quit))))
         (edit-menu
           (make-instance 'mnas-sdl3-gui/menu/model:dropdown-menu
                          :title "Edit"
                          :entries (list
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Undo" :hotkey "Ctrl+Z"
                                                   :command-id :undo)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Redo" :hotkey "Ctrl+Y"
                                                   :command-id :redo)
                                    (make-instance 'mnas-sdl3-gui/menu/model:separator-entry)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Preferences" :hotkey ""
                                                   :command-id :preferences))))
         (help-menu
           (make-instance 'mnas-sdl3-gui/menu/model:dropdown-menu
                          :title "Help"
                          :entries (list
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "Documentation" :hotkey "F1"
                                                   :command-id :docs)
                                    (make-instance 'mnas-sdl3-gui/menu/model:separator-entry)
                                    (make-instance 'mnas-sdl3-gui/menu/model:command-entry
                                                   :label "About" :hotkey ""
                                                   :command-id :about))))
         (bar (make-instance 'mnas-sdl3-gui/menu/model:menu-bar
                             :menus (list file-menu edit-menu help-menu)
                             :left 0 :top 0 :width 760
                             :height mnas-sdl3-gui/menu/model:+menu-bar-height+)))
    (mnas-sdl3-gui/menu/model:layout-menu-bar bar)
    bar))

(defun make-demo-toolbar ()
  "Create toolbar with common command buttons."
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:toolbar
                  :layout :horizontal
                  :height 40)))
    ;; Mixed push/toggle/radio buttons bound to the same Command Model.
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "New" :width 50)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Open" :width 50)
      (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Prefs" :width 56 :type :toggle)
      (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Undo" :width 50 :type :radio :group :edit-history)
      (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Redo" :width 50 :type :radio :group :edit-history)))
    toolbar))

(defun screen-menu-sync-command-state ()
  "Synchronize toolbar state from the current menu demo commands."
  (when *toolbar-demo*
    (mnas-sdl3-gui/toolbar:update-toolbar-command-state *toolbar-demo*)))

(defun execute-command-action (command-id label)
  (let ((ok (mnas-sdl3-gui/commands:execute-command
             command-id
             :context (list :label label :menu-bar *menu-bar-demo*))))
    (if (and ok (eq command-id :quit))
        :success
        :continue)))

(sdl3:def-app-init screen-menu-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "mnas-sdl3-gui menu demo" "1.0"
                         "com.mna.sdl3.gui.menu.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from screen-menu-init :failure))
  (setf *screen-menu-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Screen Menu Demo" 760 520 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from screen-menu-init :failure))
        (progn
          (setf *window-screen-menu* window
                *renderer-screen-menu* renderer
                *screen-menu-window-id* (sdl3:get-window-id window)
                *menu-bar-demo* (make-demo-menu-bar)
                *toolbar-demo* (make-demo-toolbar)
                *menu-demo-request-quit* nil
                *status-message* "Class-based menu demo. Click File/Edit/Help or toolbar buttons.")
          (mnas-sdl3-gui/window-manager:register-window
           *screen-menu-layer-manager*
           *screen-menu-window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *screen-menu-layer-manager*
           *screen-menu-window-id*)
          (register-menu-demo-commands))))
  :continue)

(sdl3:def-app-iterate screen-menu-iterate ()
  (sdl3:set-render-draw-color *renderer-screen-menu* 244 239 228 255)
  (sdl3:render-clear *renderer-screen-menu*)

  (sdl3:set-render-draw-color *renderer-screen-menu* 52 52 52 255)
  (mnas-sdl3-gui/menu/renderer:render-debug-text
   *renderer-screen-menu*
   24.0 82.0
   "Menu demo adapted for mnas-sdl3-gui packages.")
  (mnas-sdl3-gui/menu/renderer:render-debug-text
   *renderer-screen-menu*
   24.0 106.0
   "Dropdown widths are computed from visible text + paddings.")
  (mnas-sdl3-gui/menu/renderer:render-debug-text
   *renderer-screen-menu*
   24.0 150.0
   *status-message*)

  (mnas-sdl3-gui/menu/renderer:draw-menu-bar
   *renderer-screen-menu*
   *menu-bar-demo*)

  (screen-menu-sync-command-state)

  ;; Render toolbar below menu bar
  (mnas-sdl3-gui/toolbar:render-toolbar
   *toolbar-demo*
   *renderer-screen-menu*
   0.0
   (float mnas-sdl3-gui/menu/model:+menu-bar-height+ 1.0))

  (sdl3:render-present *renderer-screen-menu*)
  :continue)

(sdl3:def-app-event screen-menu-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *screen-menu-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *screen-menu-layer-manager*
                              window-id))))
           (declare (ignore action))
           (return-from screen-menu-event :success)))
       :continue)
      (sdl3:mouse-motion-event
       (let* ((window-id (slot-value ev 'sdl3:%window-id))
              (target-id (if *screen-menu-layer-manager*
                             (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                  *screen-menu-layer-manager*
                                  window-id)
                                 window-id)
                             window-id)))
         (when (= target-id *screen-menu-window-id*)
           (mnas-sdl3-gui/menu/controller:handle-mouse-motion
            *menu-bar-demo*
            (round (slot-value ev 'sdl3:%x))
            (round (slot-value ev 'sdl3:%y)))))
       :continue)
      (sdl3:mouse-button-event
       (if (and (slot-value ev 'sdl3:%down)
                (= (slot-value ev 'sdl3:%button) +mouse-button-left+))
           (let* ((window-id (slot-value ev 'sdl3:%window-id))
                  (target-window-id (if *screen-menu-layer-manager*
                                        (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                             *screen-menu-layer-manager*
                                             window-id)
                                            window-id)
                                        window-id))
                  (x (round (slot-value ev 'sdl3:%x)))
                  (y (round (slot-value ev 'sdl3:%y))))
             (when *screen-menu-layer-manager*
               (mnas-sdl3-gui/window-manager:set-focused-window
                *screen-menu-layer-manager*
                target-window-id))
             ;; Check toolbar first (below menu bar)
             (if (and *toolbar-demo*
                      (= target-window-id *screen-menu-window-id*)
                      (>= y mnas-sdl3-gui/menu/model:+menu-bar-height+)
                      (< y (+ mnas-sdl3-gui/menu/model:+menu-bar-height+
                               (mnas-sdl3-gui/widgets:widget-height *toolbar-demo*))))
                 (let ((button (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                               *toolbar-demo*
                               x
                               (- y mnas-sdl3-gui/menu/model:+menu-bar-height+))))
                   (if button
                       (progn
                         (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                          *toolbar-demo*
                          button
                          (list :label (mnas-sdl3-gui/widgets::button-label button)))
                         :continue)
                       :continue))
                 ;; Otherwise check menu bar
                 (multiple-value-bind (kind action label)
                     (mnas-sdl3-gui/menu/controller:handle-left-click
                      *menu-bar-demo*
                      x
                      y)
                   (if (eq kind :command)
                       (execute-command-action action label)
                       :continue))))
           :continue))
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (let* ((event-window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *screen-menu-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:keyboard-target-window-id
                                           *screen-menu-layer-manager*
                                           event-window-id)
                                          event-window-id)
                                      event-window-id)))
           (when *screen-menu-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *screen-menu-layer-manager*
              target-window-id))
           (mnas-sdl3-gui/commands:dispatch-shortcut
            (slot-value ev 'sdl3:%key)
            :mods (slot-value ev 'sdl3:%mod)
            :context (list :menu-bar *menu-bar-demo*
                           :window-id target-window-id)))
         (when *menu-demo-request-quit*
           (return-from screen-menu-event :success)))
       :continue)
      (t
       :continue))))

(sdl3:def-app-quit screen-menu-quit (result)
  (declare (ignore result))
  (sdl3:destroy-renderer *renderer-screen-menu*)
  (mnas-sdl3-gui/widgets:destroy-window-and-unregister *window-screen-menu*)
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-screen-menu-demo ()
  (sdl3:enter-app-main-callbacks
   'screen-menu-init
   'screen-menu-iterate
   'screen-menu-event
   'screen-menu-quit))

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (do-screen-menu-demo)

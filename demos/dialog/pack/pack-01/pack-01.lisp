;;;; ./demos/dialog/pack-layout-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/pack-01)

(defparameter *pack-demo-window* nil)
(defparameter *pack-demo-renderer* nil)
(defparameter *pack-demo-window-id* 0)
(defparameter *pack-demo-layer-manager* nil)
(defparameter *pack-demo-toolbar* nil)
(defparameter *pack-demo-open* t)
(defparameter *pack-demo-style* :windows)
(defparameter *pack-demo-widgets* nil)
(defparameter *pack-demo-status*
  "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")
(defparameter *pack-demo-status-y* 590.0)

(defparameter +pack-demo-margin+ 16)
(defparameter +pack-demo-section-gap+ 6)
(defparameter +pack-demo-status-band+ 26)
(defparameter +pack-demo-toolbar-height+ 36)
(defparameter +pack-demo-toolbar-x+ 16.0)
(defparameter +pack-demo-toolbar-y+ 16.0)

(defparameter *pack-demo-toggle-light* nil)
(defparameter *pack-demo-toggle-dark* nil)
(defparameter *pack-demo-check-logs* nil)
(defparameter *pack-demo-check-backup* nil)
(defparameter *pack-demo-edit-user* nil)
(defparameter *pack-demo-edit-path* nil)

(defun pack-01-apply-style (style)
  "Apply STYLE to pack demo widgets." 
  (setf *pack-demo-style* style
        *pack-demo-status* (format nil "Стиль: ~A" style))
  (when *pack-demo-widgets*
    (mnas-sdl3-gui/widgets:set-widget-style style))
  (pack-01-sync-command-state))

(defun pack-01-toggle-logs ()
  "Toggle logs checkbox state from command execution." 
  (when *pack-demo-check-logs*
    (setf (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-logs*)
          (not (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-logs*)))
    (setf *pack-demo-status*
          (format nil "Логи: ~A"
                  (if (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-logs*)
                      "вкл" "выкл")))
    (pack-01-sync-command-state)))

(defun pack-01-toggle-backup ()
  "Toggle backup checkbox state from command execution." 
  (when *pack-demo-check-backup*
    (setf (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-backup*)
          (not (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-backup*)))
    (setf *pack-demo-status*
          (format nil "Бэкап: ~A"
                  (if (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-backup*)
                      "вкл" "выкл")))
    (pack-01-sync-command-state)))

(defun pack-01-reset-settings ()
  "Reset pack demo settings to defaults." 
  (when *pack-demo-toggle-light*
    (setf (mnas-sdl3-gui/widgets:toggle-state *pack-demo-toggle-light*) t
          (mnas-sdl3-gui/widgets:toggle-state *pack-demo-toggle-dark*) nil))
  (when *pack-demo-check-logs*
    (setf (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-logs*) t))
  (when *pack-demo-check-backup*
    (setf (mnas-sdl3-gui/widgets:check-box-checked *pack-demo-check-backup*) nil))
  (when *pack-demo-edit-user*
    (setf (mnas-sdl3-gui/widgets:entry-text *pack-demo-edit-user*) "Имя пользователя"
          (mnas-sdl3-gui/widgets:entry-cursor *pack-demo-edit-user*) 0))
  (when *pack-demo-edit-path*
    (setf (mnas-sdl3-gui/widgets:entry-text *pack-demo-edit-path*) "/tmp/output"
          (mnas-sdl3-gui/widgets:entry-cursor *pack-demo-edit-path*) 0))
  (pack-01-apply-style :windows)
  (setf *pack-demo-status* "Настройки сброшены")
  (pack-01-sync-command-state))

(defun pack-01-create-toolbar ()
  "Create toolbar for pack-01 command presenter." 
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:toolbar :layout :horizontal :height +pack-demo-toolbar-height+)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Apply" :width 62)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Reset" :width 62)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Flat" :width 62 :type :radio :group :theme)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Windows" :width 78 :type :radio :group :theme)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Logs" :width 58 :type :toggle)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Backup" :width 72 :type :toggle)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Quit" :width 52)))
    toolbar))

(defun pack-01-sync-command-state ()
  "Sync toolbar command checked/visible state with current widget settings." 
  (let ((flat-cmd (mnas-sdl3-gui/commands:find-command :pack-01/theme-flat))
        (windows-cmd (mnas-sdl3-gui/commands:find-command :pack-01/theme-windows))
        (logs-cmd (mnas-sdl3-gui/commands:find-command :pack-01/toggle-logs))
        (backup-cmd (mnas-sdl3-gui/commands:find-command :pack-01/toggle-backup)))
    (when flat-cmd
      (mnas-sdl3-gui/commands:set-command-checked flat-cmd (eq *pack-demo-style* :flat)))
    (when windows-cmd
      (mnas-sdl3-gui/commands:set-command-checked windows-cmd (eq *pack-demo-style* :windows)))
    (when logs-cmd
      (mnas-sdl3-gui/commands:set-command-checked logs-cmd *pack-demo-check-logs*))
    (when backup-cmd
      (mnas-sdl3-gui/commands:set-command-checked backup-cmd *pack-demo-check-backup*))))

(defun create-pack-demo-widgets ()
  "Create pack-managed widgets and return (values widgets window-width window-height)."
  (mnas-sdl3-gui/widgets:clear-pack-layout)
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:<label>
                               :text "Pack Layout Demo"))
         (subtitle (make-instance 'mnas-sdl3-gui/widgets:<label>
                                  :text "Несколько виджетов каждого типа"))
         (button-apply (make-instance 'mnas-sdl3-gui/widgets:<button>
                                      :text "Применить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (pack-01-command :pack-01/apply))))
         (button-reset (make-instance 'mnas-sdl3-gui/widgets:<button>
                                      :text "Сбросить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (pack-01-command :pack-01/reset))))
         (toggle-light (make-instance 'mnas-sdl3-gui/widgets:toggle
                                      :label "Тема: Светлая"
                                      :group :theme
                                      :state t
                                      :on-change (lambda (widget new-value)
                                                   (declare (ignore widget new-value))
                                                   (pack-01-apply-style :flat))))
         (toggle-dark (make-instance 'mnas-sdl3-gui/widgets:toggle
                                     :label "Тема: Тёмная"
                                     :group :theme
                                     :state nil
                                     :on-change (lambda (widget new-value)
                                                  (declare (ignore widget new-value))
                                                  (pack-01-apply-style :windows))))
         (check-logs (make-instance 'mnas-sdl3-gui/widgets:check-box
                                    :label "Включить логи"
                                    :checked t
                                    :on-change (lambda (widget new-value)
                                                 (declare (ignore widget new-value))
                                                 (pack-01-sync-command-state))))
         (check-backup (make-instance 'mnas-sdl3-gui/widgets:check-box
                                      :label "Создавать бэкап"
                                      :checked nil
                                      :on-change (lambda (widget new-value)
                                                   (declare (ignore widget new-value))
                                                   (pack-01-sync-command-state))))
         (edit-user (make-instance 'mnas-sdl3-gui/widgets:entry
                                   :text "Имя пользователя"
                                   :cursor 0
                                   :max-length 120))
         (edit-path (make-instance 'mnas-sdl3-gui/widgets:entry
                                   :text "/tmp/output"
                                   :cursor 0
                                   :max-length 120))
         (list-presets (make-instance 'mnas-sdl3-gui/widgets:list-box
                                      :items '("Preset A" "Preset B" "Preset C" "Preset D")
                                      :selected-index 0
                                      :item-height 24))
         (list-targets (make-instance 'mnas-sdl3-gui/widgets:list-box
                                      :items '("Target 1" "Target 2" "Target 3" "Target 4")
                                      :selected-index 1
                                      :item-height 24))
         (header-widgets (list title subtitle))
         (button-row (list button-apply button-reset))
         (check-row (list check-logs check-backup))
         (toggle-row (list toggle-light toggle-dark))
         (edit-row (list edit-user edit-path))
         (list-row (list list-presets list-targets)))

    (setf *pack-demo-widgets*
          (list title subtitle
                button-apply button-reset
                toggle-light toggle-dark
                check-logs check-backup
                edit-user edit-path
                list-presets list-targets)
          *pack-demo-toggle-light* toggle-light
          *pack-demo-toggle-dark* toggle-dark
          *pack-demo-check-logs* check-logs
          *pack-demo-check-backup* check-backup
          *pack-demo-edit-user* edit-user
          *pack-demo-edit-path* edit-path)

    ;; Register pack options.
    (mnas-sdl3-gui/widgets:pack-widget title :side :top :fill :x :padx 8 :pady 2 :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget subtitle :side :top :fill :x :padx 8 :pady 2 :use-content-size t)

    (mnas-sdl3-gui/widgets:pack-widget button-apply :side :left :fill :x :expand t :padx 8 :pady 3 :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget button-reset :side :left :fill :x :expand t :padx 8 :pady 3 :use-content-size t)

    (mnas-sdl3-gui/widgets:pack-widget check-logs :side :left :fill :x :expand t :padx 8 :pady 2 :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget check-backup :side :left :fill :x :expand t :padx 8 :pady 2 :use-content-size t)

    (mnas-sdl3-gui/widgets:pack-widget toggle-light :side :left :fill :x :expand t :padx 8 :pady 2 :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget toggle-dark :side :left :fill :x :expand t :padx 8 :pady 2 :use-content-size t)

    (mnas-sdl3-gui/widgets:pack-widget edit-user :side :top :fill :x :padx 8 :pady 2 :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget edit-path :side :top :fill :x :padx 8 :pady 2 :use-content-size t)

    (mnas-sdl3-gui/widgets:pack-widget list-presets :side :left :fill :both :expand t :padx 8 :pady 4 :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget list-targets :side :left :fill :both :expand t :padx 8 :pady 4 :use-content-size t)

    ;; Calculate required size and apply layout by sections.
    (let ((section-info nil)
          (content-width 0)
          (content-height 0))
      (dolist (section (list header-widgets button-row check-row toggle-row edit-row list-row))
        (multiple-value-bind (req-w req-h)
            (mnas-sdl3-gui/widgets:pack-layout-required-size section)
          (push (list :widgets section :w req-w :h req-h) section-info)
          (setf content-width (max content-width req-w))
          (incf content-height req-h)))
      (setf section-info (nreverse section-info))
      (incf content-height (* +pack-demo-section-gap+ (1- (length section-info))))

      (let* ((window-width (+ (* 2 +pack-demo-margin+) content-width))
             (window-height (+ (* 2 +pack-demo-margin+)
                               +pack-demo-toolbar-height+
                               content-height
                               +pack-demo-status-band+))
             (usable-width (- window-width (* 2 +pack-demo-margin+)))
             (current-y (+ +pack-demo-margin+ +pack-demo-toolbar-height+ +pack-demo-section-gap+)))
        (dolist (entry section-info)
          (mnas-sdl3-gui/widgets:pack-layout-widgets
           (getf entry :widgets)
           +pack-demo-margin+
           current-y
           usable-width
           (getf entry :h))
          (incf current-y (+ (getf entry :h) +pack-demo-section-gap+)))

        (setf *pack-demo-status-y*
              (float (+ +pack-demo-margin+ +pack-demo-toolbar-height+ content-height 6) 1.0))
        (values *pack-demo-widgets* window-width window-height)))))

(sdl3:def-app-init pack-layout-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Pack Layout Demo" "1.0"
                         "com.mna.sdl3.gui.pack-layout.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from pack-layout-demo-init :failure))
  (setf *pack-demo-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  ;; Init TTF before size calculation to get accurate glyph metrics.
  (mnas-sdl3-gui/widgets:init-ttf-font)
  (multiple-value-bind (widgets window-width window-height)
      (create-pack-demo-widgets)
    (multiple-value-bind (ok window renderer)
        (sdl3:create-window-and-renderer "Pack Layout Demo" window-width window-height 0)
      (if (not ok)
          (progn
            (format t "~a~%" (sdl3:get-error))
            (return-from pack-layout-demo-init :failure))
          (progn
            (setf *pack-demo-window* window
                  *pack-demo-renderer* renderer
                  *pack-demo-window-id* (sdl3:get-window-id window)
                  *pack-demo-open* t
                  *pack-demo-status* "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")
            (mnas-sdl3-gui/window-manager:register-window
             *pack-demo-layer-manager*
             *pack-demo-window-id*
             :main
             :open-p t)
            (mnas-sdl3-gui/window-manager:set-focused-window
             *pack-demo-layer-manager*
             *pack-demo-window-id*)
            (pack-01-register-commands)
            (pack-01-register-shortcuts)
            (setf *pack-demo-toolbar* (pack-01-create-toolbar))
            #+nil(mnas-sdl3-gui/widgets:register-toolbar-for-command-updates *pack-demo-toolbar*)
            (mnas-sdl3-gui/widgets:set-widget-style *pack-demo-style*)
            (mnas-sdl3-gui/widgets:start-widget-text-input window)
            (setf *pack-demo-widgets* widgets)
            (mnas-sdl3-gui/widgets:move-widget-focus *pack-demo-widgets*)))))
  :continue)

(sdl3:def-app-iterate pack-layout-demo-iterate ()
  (unless *pack-demo-open*
    (return-from pack-layout-demo-iterate :success))

  (sdl3:set-render-draw-color *pack-demo-renderer* 242 242 242 255)
  (sdl3:render-clear *pack-demo-renderer*)

    (pack-01-sync-command-state)
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *pack-demo-widgets*)
        do (mnas-sdl3-gui/widgets:render *pack-demo-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
  (when *pack-demo-toolbar*
    (mnas-sdl3-gui/widgets:render-toolbar
     *pack-demo-toolbar*
     *pack-demo-renderer*
     +pack-demo-toolbar-x+
     +pack-demo-toolbar-y+))

  (mnas-sdl3-gui/widgets:render-text
   *pack-demo-renderer* *pack-demo-status* 16.0 *pack-demo-status-y* '(45 45 45 255))

  (sdl3:render-present *pack-demo-renderer*)
  :continue)

(sdl3:def-app-event pack-layout-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *pack-demo-open* nil)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *pack-demo-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *pack-demo-layer-manager*
                              window-id))))
           (case action
             (:close-root
              (setf *pack-demo-open* nil)
              (return-from pack-layout-demo-event :success))
             (otherwise
              (setf *pack-demo-open* nil)
              (return-from pack-layout-demo-event :success)))))
       :continue)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:handle-mouse-motion-event
        *pack-demo-widgets*
        ev)
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *pack-demo-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                           *pack-demo-layer-manager*
                                           window-id)
                                          window-id)
                                      window-id))
                (mx (round (slot-value ev 'sdl3:%x)))
                (my (round (slot-value ev 'sdl3:%y))))
           (when *pack-demo-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *pack-demo-layer-manager*
              target-window-id))
           (when (= target-window-id *pack-demo-window-id*)
             (if (slot-value ev 'sdl3:%down)
                 (let ((button (and *pack-demo-toolbar*
                                    (mnas-sdl3-gui/widgets:toolbar-buttons-at-position
                                     *pack-demo-toolbar*
                                     (- mx (round +pack-demo-toolbar-x+))
                                     (- my (round +pack-demo-toolbar-y+))))))
                   (if button
                       (mnas-sdl3-gui/widgets:toolbar-button-clicked
                        *pack-demo-toolbar*
                        button
                        (list :window-id target-window-id))
                       (mnas-sdl3-gui/widgets:handle-mouse-button-event *pack-demo-widgets* ev)))
                 (mnas-sdl3-gui/widgets:handle-mouse-button-event *pack-demo-widgets* ev))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:handle-mouse-wheel-event
        *pack-demo-widgets* ev)
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (let* ((event-window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *pack-demo-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:keyboard-target-window-id
                                           *pack-demo-layer-manager*
                                           event-window-id)
                                          event-window-id)
                                      event-window-id)))
           (when *pack-demo-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *pack-demo-layer-manager*
              target-window-id))
           (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                    (slot-value ev 'sdl3:%key)
                    :mods (slot-value ev 'sdl3:%mod)
                    :context (list :window-id target-window-id))
             (mnas-sdl3-gui/widgets:handle-widget-key-event
              *pack-demo-widgets*
              (slot-value ev 'sdl3:%key)
              nil
              :mods (slot-value ev 'sdl3:%mod)
              :on-escape (lambda ()
                           (setf *pack-demo-open* nil)
                           :success)))
           :continue)))
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *pack-demo-widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue)
      )))

(sdl3:def-app-quit pack-layout-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *pack-demo-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *pack-demo-renderer*
    (sdl3:destroy-renderer *pack-demo-renderer*))
  (when *pack-demo-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *pack-demo-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun pack-01 (&optional (style :windows))
  "Run pack layout demo with multiple widgets of each type."
  (setf *pack-demo-style* style)
  (sdl3:enter-app-main-callbacks
   'pack-layout-demo-init
   'pack-layout-demo-iterate
   'pack-layout-demo-event
   'pack-layout-demo-quit)
  :done)


;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/pack)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/pack-01)
;;;; (pack-01)

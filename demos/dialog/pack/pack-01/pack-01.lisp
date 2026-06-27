;;;; ./demos/dialog/pack-layout-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog/pack-01)

(defun apply-style (style)
  "Apply STYLE to pack demo widgets." 
  (setf *style* style
        *status* (format nil "Стиль: ~A" style))
  (when (mnas-sdl3-gui/widgets:widgets-for-window *window*)
    (mnas-sdl3-gui/widgets:set-widget-style style))
  (sync-command-state))

(defun toggle-logs ()
  "Toggle logs checkbox state from command execution." 
  (when *check-logs*
    (setf (mnas-sdl3-gui/widgets:<check-box>-checked *check-logs*)
          (not (mnas-sdl3-gui/widgets:<check-box>-checked *check-logs*)))
    (setf *status*
          (format nil "Логи: ~A"
                  (if (mnas-sdl3-gui/widgets:<check-box>-checked *check-logs*)
                      "вкл" "выкл")))
    (sync-command-state)))

(defun toggle-backup ()
  "Toggle backup checkbox state from command execution." 
  (when *check-backup*
    (setf (mnas-sdl3-gui/widgets:<check-box>-checked *check-backup*)
          (not (mnas-sdl3-gui/widgets:<check-box>-checked *check-backup*)))
    (setf *status*
          (format nil "Бэкап: ~A"
                  (if (mnas-sdl3-gui/widgets:<check-box>-checked *check-backup*)
                      "вкл" "выкл")))
    (sync-command-state)))

(defun reset-settings ()
  "Reset pack demo settings to defaults." 
  (when *toggle-light*
    (setf (mnas-sdl3-gui/widgets:<toggle>-state *toggle-light*) t
          (mnas-sdl3-gui/widgets:<toggle>-state *toggle-dark*) nil))
  (when *check-logs*
    (setf (mnas-sdl3-gui/widgets:<check-box>-checked *check-logs*) t))
  (when *check-backup*
    (setf (mnas-sdl3-gui/widgets:<check-box>-checked *check-backup*) nil))
  (when *edit-user*
    (setf (mnas-sdl3-gui/widgets:<entry>-text *edit-user*) "Имя пользователя"
          (mnas-sdl3-gui/widgets:<entry>-cursor *edit-user*) 0))
  (when *edit-path*
    (setf (mnas-sdl3-gui/widgets:<entry>-text *edit-path*) "/tmp/output"
          (mnas-sdl3-gui/widgets:<entry>-cursor *edit-path*) 0))
  (apply-style :windows)
  (setf *status* "Настройки сброшены")
  (sync-command-state))

(defun create-toolbar (window)
  "Create toolbar for pack-01 command presenter." 
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :layout :horizontal
           :height +toolbar-height+
           :window window
           )))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/apply
            :label "Apply"
            :width 62
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/reset
            :label "Reset"
            :width 62
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/theme-flat
            :label "Flat"
            :width 62
            :type :radio
            :group :theme
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/theme-windows
            :label "Windows"
            :width 78
            :type :radio
            :group :theme
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/toggle-logs
            :label "Logs"
            :width 58
            :type :toggle
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/toggle-backup
            :label "Backup"
            :width 72
            :type :toggle
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :pack-01/quit
            :label "Quit"
            :width 52)))
    toolbar))

(defun sync-command-state ()
  "Sync toolbar command checked/visible state with current widget settings." 
  (let ((flat-cmd (mnas-sdl3-gui/commands:find-command :pack-01/theme-flat))
        (windows-cmd (mnas-sdl3-gui/commands:find-command :pack-01/theme-windows))
        (logs-cmd (mnas-sdl3-gui/commands:find-command :pack-01/toggle-logs))
        (backup-cmd (mnas-sdl3-gui/commands:find-command :pack-01/toggle-backup)))
    (when flat-cmd
      (mnas-sdl3-gui/commands:set-command-checked flat-cmd (eq *style* :flat)))
    (when windows-cmd
      (mnas-sdl3-gui/commands:set-command-checked windows-cmd (eq *style* :windows)))
    (when logs-cmd
      (mnas-sdl3-gui/commands:set-command-checked logs-cmd *check-logs*))
    (when backup-cmd
      (mnas-sdl3-gui/commands:set-command-checked backup-cmd *check-backup*))))

(defun create-widgets (window)
  "Create pack-managed widgets and return (values widgets window-width window-height)."
  (mnas-sdl3-gui/widgets:clear-pack-layout)
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:<label>
                               :text "Pack Layout Demo"))
         (subtitle
           (make-instance
            'mnas-sdl3-gui/widgets:<label>
            :window window
            :text "Несколько виджетов каждого типа"))
         (button-apply
           (make-instance
            'mnas-sdl3-gui/widgets:<button>
                        :window window
                                      :text "Применить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (command :pack-01/apply))))
         (button-reset
           (make-instance
            'mnas-sdl3-gui/widgets:<button>
            :window window
            :text "Сбросить"
            :on-click (lambda (widget)
                        (declare (ignore widget))
                        (command :pack-01/reset))))
         (toggle-light
           (make-instance
            'mnas-sdl3-gui/widgets:<toggle>
            :window window
            :label "Тема: Светлая"
            :group :theme
            :state t
            :on-change (lambda (widget new-value)
                         (declare (ignore widget new-value))
                         (apply-style :flat))))
         (toggle-dark
           (make-instance
            'mnas-sdl3-gui/widgets:<toggle>
            :window window
            :label "Тема: Тёмная"
            :group :theme
            :state nil
            :on-change (lambda (widget new-value)
                         (declare (ignore widget new-value))
                         (apply-style :windows))))
         (check-logs
           (make-instance
            'mnas-sdl3-gui/widgets:<check-box>
            :window window
            :label "Включить логи"
            :checked t
            :on-change (lambda (widget new-value)
                         (declare (ignore widget new-value))
                         (sync-command-state))))
         (check-backup
           (make-instance
            'mnas-sdl3-gui/widgets:<check-box>
            :window window
            :label "Создавать бэкап"
            :checked nil
            :on-change (lambda (widget new-value)
                         (declare (ignore widget new-value))
                         (sync-command-state))))
         (edit-user
           (make-instance
            'mnas-sdl3-gui/widgets:<entry>
            :window window
            :text "Имя пользователя"
            :cursor 0
            :max-length 120))
         (edit-path
           (make-instance
            'mnas-sdl3-gui/widgets:<entry>
            :window window
            :text "/tmp/output"
            :cursor 0
            :max-length 120))
         (list-presets
           (make-instance
            'mnas-sdl3-gui/widgets:<list-box>
            :window window
            :items '("Preset A" "Preset B" "Preset C" "Preset D")
            :selected-index 0
            :item-height 24))
         (list-targets
           (make-instance
            'mnas-sdl3-gui/widgets:<list-box>
            :window window
            :items '("Target 1" "Target 2" "Target 3" "Target 4")
            :selected-index 1
            :item-height 24))
         (header-widgets (list title subtitle))
         (button-row (list button-apply button-reset))
         (check-row (list check-logs check-backup))
         (toggle-row (list toggle-light toggle-dark))
         (edit-row (list edit-user edit-path))
         (list-row (list list-presets list-targets)))
   
    (setf *toggle-light* toggle-light
          *toggle-dark* toggle-dark
          *check-logs* check-logs
          *check-backup* check-backup
          *edit-user* edit-user
          *edit-path* edit-path)

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
      (incf content-height (* +section-gap+ (1- (length section-info))))

      (let* ((window-width (+ (* 2 +margin+) content-width))
             (window-height (+ (* 2 +margin+)
                               +toolbar-height+
                               content-height
                               +status-band+))
             (usable-width (- window-width (* 2 +margin+)))
             (current-y (+ +margin+ +toolbar-height+ +section-gap+)))
        (dolist (entry section-info)
          (mnas-sdl3-gui/widgets:pack-layout-widgets
           (getf entry :widgets)
           +margin+
           current-y
           usable-width
           (getf entry :h))
          (incf current-y (+ (getf entry :h) +section-gap+)))

        (setf *status-y*
              (float (+ +margin+ +toolbar-height+ content-height 6) 1.0))
        #+nil (values *widgets* window-width window-height)
        ))))

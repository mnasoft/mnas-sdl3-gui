;;;; ./demos/dialog/pack-layout-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *pack-demo-window* nil)
(defparameter *pack-demo-renderer* nil)
(defparameter *pack-demo-open* t)
(defparameter *pack-demo-style* :windows)
(defparameter *pack-demo-widgets* nil)
(defparameter *pack-demo-status*
  "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")
(defparameter *pack-demo-status-y* 590.0)

(defparameter +pack-demo-margin+ 16)
(defparameter +pack-demo-section-gap+ 6)
(defparameter +pack-demo-status-band+ 26)

(defun create-pack-demo-widgets ()
  "Create pack-managed widgets and return (values widgets window-width window-height)."
  (mnas-sdl3-gui/widgets:clear-pack-layout)
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :text "Pack Layout Demo"))
         (subtitle (make-instance 'mnas-sdl3-gui/widgets:label
                                  :text "Несколько виджетов каждого типа"))
         (button-apply (make-instance 'mnas-sdl3-gui/widgets:button
                                      :text "Применить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (setf *pack-demo-status* "Нажата кнопка: Применить"))))
         (button-reset (make-instance 'mnas-sdl3-gui/widgets:button
                                      :text "Сбросить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (setf *pack-demo-status* "Нажата кнопка: Сбросить"))))
         (toggle-light (make-instance 'mnas-sdl3-gui/widgets:toggle
                                      :label "Тема: Светлая"
                                      :group :theme
                                      :state t))
         (toggle-dark (make-instance 'mnas-sdl3-gui/widgets:toggle
                                     :label "Тема: Тёмная"
                                     :group :theme
                                     :state nil))
         (check-logs (make-instance 'mnas-sdl3-gui/widgets:check-box
                                    :label "Включить логи"
                                    :checked t))
         (check-backup (make-instance 'mnas-sdl3-gui/widgets:check-box
                                      :label "Создавать бэкап"
                                      :checked nil))
         (edit-user (make-instance 'mnas-sdl3-gui/widgets:edit-box
                                   :text "Имя пользователя"
                                   :cursor 0
                                   :max-length 120))
         (edit-path (make-instance 'mnas-sdl3-gui/widgets:edit-box
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
                list-presets list-targets))

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
             (window-height (+ (* 2 +pack-demo-margin+) +pack-demo-status-band+ content-height))
             (usable-width (- window-width (* 2 +pack-demo-margin+)))
             (current-y +pack-demo-margin+))
        (dolist (entry section-info)
          (mnas-sdl3-gui/widgets:pack-layout-widgets
           (getf entry :widgets)
           +pack-demo-margin+
           current-y
           usable-width
           (getf entry :h))
          (incf current-y (+ (getf entry :h) +pack-demo-section-gap+)))

        (setf *pack-demo-status-y* (float (+ +pack-demo-margin+ content-height 6) 1.0))
        (values *pack-demo-widgets* window-width window-height)))))

(sdl3:def-app-init pack-layout-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Pack Layout Demo" "1.0"
                         "com.mna.sdl3.gui.pack-layout.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from pack-layout-demo-init :failure))
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
                  *pack-demo-open* t
                  *pack-demo-status* "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")
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

  (mnas-sdl3-gui/widgets:render-widgets *pack-demo-renderer* *pack-demo-widgets*)

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
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *pack-demo-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down *pack-demo-widgets* mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up *pack-demo-widgets* mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-wheel
        *pack-demo-widgets*
        (round (slot-value ev 'sdl3:%mouse-x))
        (round (slot-value ev 'sdl3:%mouse-y))
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
        (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
         *pack-demo-widgets*
         (slot-value ev 'sdl3:%key)
         :mods (slot-value ev 'sdl3:%mod)
         :on-escape (lambda ()
                  (setf *pack-demo-open* nil)
                  :success)))
       :continue)
      (sdl3:text-input-event
         (mnas-sdl3-gui/widgets:dispatch-focused-text-input *pack-demo-widgets*
                                                            (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit pack-layout-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *pack-demo-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *pack-demo-renderer*
    (sdl3:destroy-renderer *pack-demo-renderer*))
  (when *pack-demo-window*
    (sdl3:destroy-window *pack-demo-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun do-pack-layout-demo (&optional (style :windows))
  "Run pack layout demo with multiple widgets of each type."
  (setf *pack-demo-style* style)
  (sdl3:enter-app-main-callbacks
   'pack-layout-demo-init
   'pack-layout-demo-iterate
   'pack-layout-demo-event
   'pack-layout-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (do-pack-layout-demo)

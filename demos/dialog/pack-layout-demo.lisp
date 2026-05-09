;;;; ./demos/dialog/pack-layout-demo.lisp

(in-package :mnas-sdl3-gui/demos/dialog)

(defparameter *pack-demo-window* nil)
(defparameter *pack-demo-renderer* nil)
(defparameter *pack-demo-open* t)
(defparameter *pack-demo-style* :windows)
(defparameter *pack-demo-widgets* nil)
(defparameter *pack-demo-status*
  "Pack layout demo: кнопки/checkbox/toggle идут отдельными строками.")

(defun pack-demo-tab-backward-p (ev)
  "Return true when Tab navigation should move backward."
  (let ((mods (slot-value ev 'sdl3:%mod)))
    (typecase mods
      (list (or (member :alt mods) (member :lalt mods) (member :ralt mods)
                (member :shift mods) (member :lshift mods) (member :rshift mods)))
      (symbol (member mods '(:alt :lalt :ralt :shift :lshift :rshift)))
      (integer (not (zerop (logand mods #x0303))))
      (t nil))))

(defun pack-demo-focused-edit-box ()
  "Return currently focused edit-box widget, or NIL."
  (find-if (lambda (widget)
             (and (typep widget 'mnas-sdl3-gui/widgets:edit-box)
                  (mnas-sdl3-gui/widgets:widget-focused widget)))
           *pack-demo-widgets*))

(defun pack-demo-insert-text (text)
  "Insert TEXT into focused edit-box, one character at a time."
  (let ((edit-box (pack-demo-focused-edit-box)))
    (when edit-box
      (loop for ch across text
            do (mnas-sdl3-gui/widgets:handle-widget-key-press edit-box nil ch)))))

(defun create-pack-demo-widgets ()
  "Create pack-managed widgets with multiple elements for each widget type."
  (mnas-sdl3-gui/widgets:clear-pack-layout)
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :x 0 :y 0 :width 200 :height 28
                               :text "Pack Layout Demo"))
         (subtitle (make-instance 'mnas-sdl3-gui/widgets:label
                                  :x 0 :y 0 :width 200 :height 24
                                  :text "Несколько виджетов каждого типа"))
         (button-apply (make-instance 'mnas-sdl3-gui/widgets:button
                                      :x 0 :y 0 :width 240 :height 32
                                      :text "Применить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (setf *pack-demo-status* "Нажата кнопка: Применить"))))
         (button-reset (make-instance 'mnas-sdl3-gui/widgets:button
                                      :x 0 :y 0 :width 240 :height 32
                                      :text "Сбросить"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (setf *pack-demo-status* "Нажата кнопка: Сбросить"))))
         (toggle-light (make-instance 'mnas-sdl3-gui/widgets:toggle
                                      :x 0 :y 0 :width 260 :height 28
                                      :label "Тема: Светлая"
                                      :group :theme
                                      :state t))
         (toggle-dark (make-instance 'mnas-sdl3-gui/widgets:toggle
                                     :x 0 :y 0 :width 260 :height 28
                                     :label "Тема: Тёмная"
                                     :group :theme
                                     :state nil))
         (check-logs (make-instance 'mnas-sdl3-gui/widgets:check-box
                                    :x 0 :y 0 :width 260 :height 28
                                    :label "Включить логи"
                                    :checked t))
         (check-backup (make-instance 'mnas-sdl3-gui/widgets:check-box
                                      :x 0 :y 0 :width 260 :height 28
                                      :label "Создавать бэкап"
                                      :checked nil))
         (edit-user (make-instance 'mnas-sdl3-gui/widgets:edit-box
                                   :x 0 :y 0 :width 420 :height 34
                                   :text "Имя пользователя"
                                   :cursor 0
                                   :max-length 120))
         (edit-path (make-instance 'mnas-sdl3-gui/widgets:edit-box
                                   :x 0 :y 0 :width 420 :height 34
                                   :text "/tmp/output"
                                   :cursor 0
                                   :max-length 120))
         (list-presets (make-instance 'mnas-sdl3-gui/widgets:list-box
                                      :x 0 :y 0 :width 520 :height 90
                                      :items '("Preset A" "Preset B" "Preset C" "Preset D")
                                      :selected-index 0
                                      :item-height 24))
         (list-targets (make-instance 'mnas-sdl3-gui/widgets:list-box
                                      :x 0 :y 0 :width 520 :height 90
                                      :items '("Target 1" "Target 2" "Target 3" "Target 4")
                                      :selected-index 1
                                      :item-height 24)))
    (setf *pack-demo-widgets*
          (list title subtitle
                button-apply button-reset
                toggle-light toggle-dark
                check-logs check-backup
                edit-user edit-path
                list-presets list-targets))

        ;; Header section.
    (mnas-sdl3-gui/widgets:pack-widget title :side :top :fill :x :padx 8 :pady 6)
    (mnas-sdl3-gui/widgets:pack-widget subtitle :side :top :fill :x :padx 8 :pady 2)

        ;; Row 1: buttons in one horizontal line.
        (mnas-sdl3-gui/widgets:pack-widget button-apply :side :left :fill :x :expand t :padx 8 :pady 3)
        (mnas-sdl3-gui/widgets:pack-widget button-reset :side :left :fill :x :expand t :padx 8 :pady 3)

        ;; Row 2: check-box widgets in one horizontal line.
        (mnas-sdl3-gui/widgets:pack-widget check-logs :side :left :fill :x :expand t :padx 8 :pady 2)
        (mnas-sdl3-gui/widgets:pack-widget check-backup :side :left :fill :x :expand t :padx 8 :pady 2)

        ;; Row 3: toggle widgets in one horizontal line.
        (mnas-sdl3-gui/widgets:pack-widget toggle-light :side :left :fill :x :expand t :padx 8 :pady 2)
        (mnas-sdl3-gui/widgets:pack-widget toggle-dark :side :left :fill :x :expand t :padx 8 :pady 2)

        ;; Remaining controls keep vertical flow.
    (mnas-sdl3-gui/widgets:pack-widget edit-user :side :top :fill :x :padx 8 :pady 2)
    (mnas-sdl3-gui/widgets:pack-widget edit-path :side :top :fill :x :padx 8 :pady 2)
        (mnas-sdl3-gui/widgets:pack-widget list-presets :side :left :fill :both :expand t :padx 8 :pady 4)
        (mnas-sdl3-gui/widgets:pack-widget list-targets :side :left :fill :both :expand t :padx 8 :pady 4)

        ;; Apply pack layout per logical section to emulate row groups.
        (mnas-sdl3-gui/widgets:pack-layout-widgets (list title subtitle)
                       16 16 768 56)
        (mnas-sdl3-gui/widgets:pack-layout-widgets (list button-apply button-reset)
                       16 78 768 44)
        (mnas-sdl3-gui/widgets:pack-layout-widgets (list check-logs check-backup)
                       16 126 768 38)
        (mnas-sdl3-gui/widgets:pack-layout-widgets (list toggle-light toggle-dark)
                       16 166 768 38)
        (mnas-sdl3-gui/widgets:pack-layout-widgets (list edit-user edit-path)
                       16 210 768 84)
        (mnas-sdl3-gui/widgets:pack-layout-widgets (list list-presets list-targets)
                       16 300 768 278)
    *pack-demo-widgets*))

(sdl3:def-app-init pack-layout-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Pack Layout Demo" "1.0"
                         "com.mna.sdl3.gui.pack-layout.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from pack-layout-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Pack Layout Demo" 800 620 0)
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
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (sdl3:start-text-input window)
          (create-pack-demo-widgets)
          (mnas-sdl3-gui/widgets:move-widget-focus *pack-demo-widgets*))))
  :continue)

(sdl3:def-app-iterate pack-layout-demo-iterate ()
  (unless *pack-demo-open*
    (return-from pack-layout-demo-iterate :success))

  (sdl3:set-render-draw-color *pack-demo-renderer* 242 242 242 255)
  (sdl3:render-clear *pack-demo-renderer*)

  (loop for widget in *pack-demo-widgets*
        do (mnas-sdl3-gui/widgets:render-widget *pack-demo-renderer* widget))

  (mnas-sdl3-gui/widgets:render-text
   *pack-demo-renderer* *pack-demo-status* 16.0 590.0 '(45 45 45 255))

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
       (loop for widget in *pack-demo-widgets*
             do (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
                 widget
                 (round (slot-value ev 'sdl3:%x))
                 (round (slot-value ev 'sdl3:%y))))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (loop for widget in *pack-demo-widgets*
                     when (mnas-sdl3-gui/widgets:handle-widget-mouse-down widget mx my)
                     do (mnas-sdl3-gui/widgets:set-widget-focus *pack-demo-widgets* widget)
                        (return))
               (loop for widget in *pack-demo-widgets*
                     when (mnas-sdl3-gui/widgets:handle-widget-mouse-up widget mx my)
                     do (return)))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (cond
           ((eq (slot-value ev 'sdl3:%key) :escape)
            (setf *pack-demo-open* nil)
            :success)
           ((eq (slot-value ev 'sdl3:%key) :tab)
            (mnas-sdl3-gui/widgets:move-widget-focus
             *pack-demo-widgets*
             :backward (pack-demo-tab-backward-p ev))
            :continue)
           ((eq (slot-value ev 'sdl3:%key) :space)
            (let ((focused (mnas-sdl3-gui/widgets:focused-widget *pack-demo-widgets*)))
              (when focused
                (mnas-sdl3-gui/widgets:handle-widget-key-press focused :space nil)))
            :continue)
           (t
            (let ((focused (mnas-sdl3-gui/widgets:focused-widget *pack-demo-widgets*)))
              (when focused
                (mnas-sdl3-gui/widgets:handle-widget-key-press
                 focused
                 (slot-value ev 'sdl3:%key)
                 nil)))
            :continue)))
       :continue)
      (sdl3:text-input-event
       (pack-demo-insert-text (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit pack-layout-demo-quit (result)
  (declare (ignore result))
  (when *pack-demo-window*
    (sdl3:stop-text-input *pack-demo-window*))
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
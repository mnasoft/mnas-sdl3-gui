;;;; ./demos/dialog/toggle/toggle-01/toggle-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(defparameter *toggle-01-window* nil)
(defparameter *toggle-01-renderer* nil)
(defparameter *toggle-01-window-id* 0)
(defparameter *toggle-01-layer-manager* nil)
(defparameter *toggle-01-toolbar* nil)
(defparameter *toggle-01-open* t)
(defparameter *toggle-01-style* :windows)
(defparameter *toggle-01-widgets* nil)
(defparameter *toggle-01-status* "Выберите переключатель в любой группе.")
(defparameter *toggle-01-status-y* 0)
(defparameter +toggle-01-toolbar-height+ 32)
(defparameter +toggle-01-margin+ 16)
(defparameter +toggle-01-status-band+ 26)
(defparameter +toggle-01-section-gap+ 8)

(defun toggle-01-create-toolbar ()
  "Create toolbar for toggle-01 demo." 
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar
                  :layout :horizontal
                  :height +toggle-01-toolbar-height+)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec
            :toggle-01/group-1-option-1
            :label "1"
            :width 40
            :type :radio
            :group :group-1)
           (mnas-sdl3-gui/toolbar:make-button-spec
            :toggle-01/group-1-option-2
            :label "2"
            :width 40
            :type :radio
            :group :group-1)
           (mnas-sdl3-gui/toolbar:make-button-spec
            :toggle-01/group-1-option-3
            :label "3"
            :width 40
            :type :radio
            :group :group-1)
           (mnas-sdl3-gui/toolbar:make-button-spec
            :toggle-01/group-1-option-4
            :label "4"
            :width 40
            :type :radio
            :group :group-1)
           (mnas-sdl3-gui/toolbar:make-button-spec
            :toggle-01/quit
            :label "Quit"
            :width 64)))
    toolbar))

(defun toggle-01-select (group label)
  "Select LABEL in GROUP and clear other toggles in the same group." 
  (dolist (widget *toggle-01-widgets*)
    (when (and (typep widget 'mnas-sdl3-gui/widgets:toggle)
               (eql (mnas-sdl3-gui/widgets:toggle-group widget) group))
      (let ((selected-p (string= (mnas-sdl3-gui/widgets:toggle-label widget) label)))
        (setf (mnas-sdl3-gui/widgets:toggle-state widget) selected-p
              (mnas-sdl3-gui/widgets:widget-value widget) selected-p))))
  (refresh-toggle-01-status))

(defun toggle-01-sync-command-state ()
  "Mirror grouped toggle checked-state into command model." 
  (dolist (spec +toggle-01-command-map+)
    (destructuring-bind (id group label shortcut) spec
      (declare (ignore shortcut))
      (let ((cmd (mnas-sdl3-gui/commands:find-command id)))
        (when cmd
          (mnas-sdl3-gui/commands:set-command-checked cmd
                                                      (string= (or (selected-toggle-label group) "") label)))))))

(defun selected-toggle-label (group)
  "Return label of the selected toggle in GROUP, or NIL."
  (let ((toggle
          (find-if (lambda (widget)
                     (and (typep widget 'mnas-sdl3-gui/widgets:toggle)
                          (eql (mnas-sdl3-gui/widgets:toggle-group widget) group)
                          (mnas-sdl3-gui/widgets:toggle-state widget)))
                   *toggle-01-widgets*)))
    (when toggle
      (mnas-sdl3-gui/widgets:toggle-label toggle))))

(defun refresh-toggle-01-status ()
  "Update the status line from the currently selected toggles."
  (let ((left (or (selected-toggle-label :group-1) "—"))
        (right (or (selected-toggle-label :group-2) "—")))
    (setf *toggle-01-status*
          (format nil "Группа 1: ~a   Группа 2: ~a" left right))))

(defun make-group-toggle (x y label group selected-p)
  "Create one radio-style toggle for the grouped demo."
  (let ((toggle (make-instance 'mnas-sdl3-gui/widgets:toggle
                               :x x :y y :width 180 :height 28
                               :label label
                               :group group
                               :state selected-p
                               :focused nil)))
    (setf (mnas-sdl3-gui/widgets:widget-value toggle) selected-p)
    (setf (mnas-sdl3-gui/widgets:widget-on-change toggle)
          (lambda (widget value)
            (declare (ignore widget))
            (when value
              (refresh-toggle-01-status))))
    toggle))

(defun create-toggle-01-widgets ()
  "Create demo widgets for two grouped toggle columns using pack layout."
  (mnas-sdl3-gui/widgets:clear-pack-layout)
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :text "Toggle groups demo"))
         (group-1-label (make-instance 'mnas-sdl3-gui/widgets:label
                                       :text "Группа 1"))
         (group-2-label (make-instance 'mnas-sdl3-gui/widgets:label
                                       :text "Группа 2"))
         (toggle-1 (make-group-toggle nil nil "Вариант 1" :group-1 t))
         (toggle-2 (make-group-toggle nil nil "Вариант 2" :group-1 nil))
         (toggle-3 (make-group-toggle nil nil "Вариант 3" :group-1 nil))
         (toggle-4 (make-group-toggle nil nil "Вариант 4" :group-1 nil))
         (toggle-a (make-group-toggle nil nil "Опция 1" :group-2 t))
         (toggle-b (make-group-toggle nil nil "Опция 2" :group-2 nil))
         (toggle-c (make-group-toggle nil nil "Опция 3" :group-2 nil))
         (toggle-d (make-group-toggle nil nil "Опция 4" :group-2 nil))
         (widgets (list title
                        group-1-label group-2-label
                        toggle-1 toggle-a
                        toggle-2 toggle-b
                        toggle-3 toggle-c
                        toggle-4 toggle-d))
         (rows `((,title)
                 (,group-1-label ,group-2-label)
                 (,toggle-1 ,toggle-a)
                 (,toggle-2 ,toggle-b)
                 (,toggle-3 ,toggle-c)
                 (,toggle-4 ,toggle-d))))
    (setf *toggle-01-widgets* widgets)

    (mnas-sdl3-gui/widgets:pack-widget title
                                       :side :top
                                       :fill :x
                                       :padx 8
                                       :pady 6
                                       :use-content-size t)

    (mnas-sdl3-gui/widgets:pack-widget group-1-label
                                       :side :left
                                       :fill :x
                                       :expand t
                                       :padx 8
                                       :pady 4
                                       :use-content-size t)
    (mnas-sdl3-gui/widgets:pack-widget group-2-label
                                       :side :left
                                       :fill :x
                                       :expand t
                                       :padx 8
                                       :pady 4
                                       :use-content-size t)

    (dolist (row (list (list toggle-1 toggle-a)
                       (list toggle-2 toggle-b)
                       (list toggle-3 toggle-c)
                       (list toggle-4 toggle-d)))
      (dolist (widget row)
        (mnas-sdl3-gui/widgets:pack-widget widget
                                           :side :left
                                           :fill :x
                                           :expand t
                                           :padx 8
                                           :pady 4
                                           :use-content-size t)))

    ;; Calculate required size and apply pack layout.
    (let ((content-width 0)
          (content-height 0)
          (section-w 0)
          (section-h 0))
      (dolist (row rows)
        (multiple-value-bind (req-w req-h)
            (mnas-sdl3-gui/widgets:pack-layout-required-size row)
          (setf content-width (max content-width req-w))
          (incf content-height req-h)))
      (incf content-height (* +toggle-01-section-gap+ (1- (length rows))))
      (let* ((window-width (+ (* 2 +toggle-01-margin+) content-width))
             (window-height (+ (* 2 +toggle-01-margin+)
                               +toggle-01-toolbar-height+
                               content-height
                               +toggle-01-status-band+))
             (usable-width (- window-width (* 2 +toggle-01-margin+)))
             (top-y (+ +toggle-01-margin+ +toggle-01-toolbar-height+ +toggle-01-section-gap+))
             (current-y top-y))
        (dolist (row rows)
          (multiple-value-bind (req-w req-h)
              (mnas-sdl3-gui/widgets:pack-layout-required-size row)
            (mnas-sdl3-gui/widgets:pack-layout-widgets row
                                                       +toggle-01-margin+
                                                       current-y
                                                       usable-width
                                                       req-h)
            (incf current-y (+ req-h +toggle-01-section-gap+))))
        (setf *toggle-01-status-y*
              (+ current-y 4))
        (refresh-toggle-01-status)
        (values *toggle-01-widgets*
                (round window-width)
                (round window-height))))))

(sdl3:def-app-init toggle-01-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Toggle Group Demo" "1.0"
                         "com.mna.sdl3.gui.toggle-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from toggle-01-demo-init :failure))
  (mnas-sdl3-gui/widgets:set-widget-style *toggle-01-style*)
  (mnas-sdl3-gui/widgets:init-ttf-font)
  (multiple-value-bind (widgets window-width window-height)
      (create-toggle-01-widgets)
    (multiple-value-bind (ok window renderer)
        (sdl3:create-window-and-renderer "Toggle Groups" window-width window-height 0)
      (if (not ok)
          (progn
            (format t "~a~%" (sdl3:get-error))
            (return-from toggle-01-demo-init :failure))
          (progn
            (setf *toggle-01-window* window
                  *toggle-01-renderer* renderer
                  *toggle-01-window-id* (sdl3:get-window-id window)
                  *toggle-01-open* t)
            (setf *toggle-01-layer-manager*
                  (mnas-sdl3-gui/window-manager:make-window-layer-manager))
            (mnas-sdl3-gui/window-manager:register-window
             *toggle-01-layer-manager*
             *toggle-01-window-id*
             :main
             :open-p t)
            (mnas-sdl3-gui/window-manager:set-focused-window
             *toggle-01-layer-manager*
             *toggle-01-window-id*)
            (toggle-01-register-commands)
            (toggle-01-register-shortcuts)
            (setf *toggle-01-toolbar* (toggle-01-create-toolbar))
            (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *toggle-01-toolbar*)
            (setf *toggle-01-widgets* widgets)
            (toggle-01-sync-command-state)
            (mnas-sdl3-gui/widgets:move-widget-focus *toggle-01-widgets*))))
    :continue))

(sdl3:def-app-iterate toggle-01-demo-iterate ()
  (unless *toggle-01-open*
    (return-from toggle-01-demo-iterate :success))

  (sdl3:set-render-draw-color *toggle-01-renderer* 240 240 240 255)
  (sdl3:render-clear *toggle-01-renderer*)

  (toggle-01-sync-command-state)
  (when *toggle-01-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *toggle-01-toolbar*
     *toggle-01-renderer*
     0.0
     0.0))

      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *toggle-01-widgets*)
        do (mnas-sdl3-gui/widgets:render *toggle-01-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/widgets:render-text *toggle-01-renderer*
                                     *toggle-01-status*
                                     20.0 *toggle-01-status-y* '(40 40 40 255))

  (mnas-sdl3-gui/widgets:render-text *toggle-01-renderer*
                                     "Click one toggle in each group to switch selection."
                                     20.0 (+ *toggle-01-status-y* 18.0) '(90 90 90 255))

  (sdl3:render-present *toggle-01-renderer*)
  :continue)

(sdl3:def-app-event toggle-01-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *toggle-01-open* nil)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let ((window-id (slot-value ev 'sdl3:%window-id))
               (action (and *toggle-01-layer-manager*
                            (mnas-sdl3-gui/window-manager:close-action
                             *toggle-01-layer-manager*
                             window-id))))
           (case action
             (:close-root
              (setf *toggle-01-open* nil)
              (return-from toggle-01-demo-event :success))
             (otherwise
              (setf *toggle-01-open* nil)
              (return-from toggle-01-demo-event :success)))))
       :continue)
      (sdl3:mouse-motion-event
         (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
        *toggle-01-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (let ((button (and *toggle-01-toolbar*
                                  (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                   *toggle-01-toolbar*
                                   mx
                                   my))))
                     (if button
                     (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                      *toggle-01-toolbar*
                      button
                      (list :window-id *toggle-01-window-id*))
                     (mnas-sdl3-gui/widgets:handle-widget-mouse-down
                      *toggle-01-widgets* mx my)))
                   (mnas-sdl3-gui/widgets:handle-widget-mouse-up *toggle-01-widgets* mx my))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                  (slot-value ev 'sdl3:%key)
                  :mods (slot-value ev 'sdl3:%mod)
                  :context (list :window-id *toggle-01-window-id*))
           (mnas-sdl3-gui/widgets:handle-widget-key-event
            *toggle-01-widgets*
            (slot-value ev 'sdl3:%key)
            nil
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda ()
                         (toggle-01-command :toggle-01/quit)
                         :success)))
         (unless *toggle-01-open*
           (return-from toggle-01-demo-event :success)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit toggle-01-demo-quit (result)
  (declare (ignore result))
  (when *toggle-01-window*
    (sdl3:destroy-renderer *toggle-01-renderer*))
  (when *toggle-01-window*
    (sdl3:destroy-window *toggle-01-window*))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun toggle-01 (&optional (style :windows))
  "Run a grouped toggle demo."
  (setf *toggle-01-style* style)
  (sdl3:enter-app-main-callbacks
   'toggle-01-demo-init
   'toggle-01-demo-iterate
   'toggle-01-demo-event
   'toggle-01-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/toggle)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/toggle-01)
;;;; (toggle-01)

;;;; ./demos/dialog/toggle/toggle-01/toggle-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(defun toggle-01-create-toolbar (window)
  "Create toolbar for toggle-01 demo." 
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :layout :horizontal
           :height +toolbar-height+
           :window window)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :toggle-01/group-1-option-1
            :label "1"
            :width 40
            :type :radio
            :group :group-1
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :toggle-01/group-1-option-2
            :label "2"
            :width 40
            :type :radio
            :group :group-1
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :toggle-01/group-1-option-3
            :label "3"
            :width 40
            :type :radio
            :group :group-1
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :toggle-01/group-1-option-1
            :label "4"
            :width 40
            :type :radio
            :group :group-1
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :toggle-01/quit
            :label "Quit"
            :width 64
            :window window
            )))
    toolbar))

(defun toggle-01-select (group label)
  "Select LABEL in GROUP and clear other toggles in the same group." 
  (dolist (widget *widgets*)
    (when (and (typep widget 'mnas-sdl3-gui/widgets:<toggle>)
               (eql (mnas-sdl3-gui/widgets:<toggle>-group widget) group))
      (let ((selected-p (string= (mnas-sdl3-gui/widgets:<toggle>-label widget) label)))
        (setf (mnas-sdl3-gui/widgets:<toggle>-state widget) selected-p
              (mnas-sdl3-gui/widgets:<widget>-value widget) selected-p))))
  (refresh-toggle-01-status))

(defun toggle-01-sync-command-state ()
  "Mirror grouped toggle checked-state into command model." 
  (dolist (spec +command-map+)
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
                     (and (typep widget 'mnas-sdl3-gui/widgets:<toggle>)
                          (eql (mnas-sdl3-gui/widgets:<toggle>-group widget) group)
                          (mnas-sdl3-gui/widgets:<toggle>-state widget)))
                   *widgets*)))
    (when toggle
      (mnas-sdl3-gui/widgets:<toggle>-label toggle))))

(defun refresh-toggle-01-status ()
  "Update the status line from the currently selected toggles."
  (let ((left (or (selected-toggle-label :group-1) "—"))
        (right (or (selected-toggle-label :group-2) "—")))
    (setf *status*
          (format nil "Группа 1: ~a   Группа 2: ~a" left right))))

(defun make-group-toggle (x y label group selected-p window)
  "Create one radio-style toggle for the grouped demo."
  (let ((toggle
          (make-instance
           'mnas-sdl3-gui/widgets:<toggle>
           :x x :y y :width 180 :height 28
           :label label
           :group group
           :state selected-p
           :focused nil
           :window  window)))
    (setf (mnas-sdl3-gui/widgets:<widget>-value toggle) selected-p)
    (setf (mnas-sdl3-gui/widgets:<widget>-on-change toggle)
          (lambda (widget value)
            (declare (ignore widget))
            (when value
              (refresh-toggle-01-status))))
    toggle))

(defun create-widgets (window)
  "Create demo widgets for two grouped toggle columns using pack layout."
  (mnas-sdl3-gui/widgets:clear-pack-layout)
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:<label>
                               :text "Toggle groups demo"))
         (group-1-label (make-instance 'mnas-sdl3-gui/widgets:<label>
                                       :text "Группа 1"))
         (group-2-label (make-instance 'mnas-sdl3-gui/widgets:<label>
                                       :text "Группа 2"))
         (toggle-1 (make-group-toggle nil nil "Вариант 1" :group-1 t   window))
         (toggle-2 (make-group-toggle nil nil "Вариант 2" :group-1 nil window))
         (toggle-3 (make-group-toggle nil nil "Вариант 3" :group-1 nil window))
         (toggle-4 (make-group-toggle nil nil "Вариант 4" :group-1 nil window))
         (toggle-a (make-group-toggle nil nil "Опция 1"   :group-2 t   window))
         (toggle-b (make-group-toggle nil nil "Опция 2"   :group-2 nil window))
         (toggle-c (make-group-toggle nil nil "Опция 3"   :group-2 nil window))
         (toggle-d (make-group-toggle nil nil "Опция 4"   :group-2 nil window))
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
    (setf *widgets* widgets)

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
      (incf content-height (* +section-gap+ (1- (length rows))))
      (let* ((window-width (+ (* 2 +margin+) content-width))
             (window-height (+ (* 2 +margin+)
                               +toolbar-height+
                               content-height
                               +status-band+))
             (usable-width (- window-width (* 2 +margin+)))
             (top-y (+ +margin+ +toolbar-height+ +section-gap+))
             (current-y top-y))
        (dolist (row rows)
          (multiple-value-bind (req-w req-h)
              (mnas-sdl3-gui/widgets:pack-layout-required-size row)
            (mnas-sdl3-gui/widgets:pack-layout-widgets row
                                                       +margin+
                                                       current-y
                                                       usable-width
                                                       req-h)
            (incf current-y (+ req-h +section-gap+))))
        (setf *status-y*
              (+ current-y 4))
        (refresh-toggle-01-status)
        (values *widgets*
                (round window-width)
                (round window-height))))))




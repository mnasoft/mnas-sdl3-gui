;;;; ./mnas-sdl3-gui/demos/dialog/check-box/check-box-01/check-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/check-box-01)

(defun check-box-content-widgets ()
  "Return non-toolbar widgets of the demo window for generic widget flows." 
  (remove-if (lambda (widget)
               (or (typep widget 'mnas-sdl3-gui/widgets:<toolbar>)
                   (typep widget 'mnas-sdl3-gui/widgets:<toolbar-button>)))
             (mnas-sdl3-gui/widgets:widgets-for-window *window*)))

(defun create-toolbar (window)
  "Create toolbar for the check-box demo." 
  (let ((toolbar     (make-instance 'mnas-sdl3-gui/widgets:<toolbar>
                                    :layout :horizontal
                                    :height +check-box-toolbar-height+
                                    :window window))
        (tb-btn-quit (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button>
                                    :command-id :check-box-01/quit
                                    :label "Quit"
                                    :width 64
                                    :window window
                                    )))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar) (list tb-btn-quit))
    toolbar))

(defun labels-in-column (prefix)
  "Return labels of checked check-box widgets whose label starts with PREFIX."
  (loop for widget in (mnas-sdl3-gui/widgets:widgets-for-window *window*)
        when (and (typep widget 'mnas-sdl3-gui/widgets:<check-box>)
                  (mnas-sdl3-gui/widgets:<check-box>-checked widget)
                  (search prefix (mnas-sdl3-gui/widgets:<check-box>-label widget)
                          :start1 0 :end1 (length prefix)))
          collect (mnas-sdl3-gui/widgets:<check-box>-label widget)))

(defun join-labels (labels)
  "Join LABELS with comma, or return dash when empty."
  (if labels
      (format nil "~{~a~^, ~}" labels)
      "—"))

(defun refresh-check-box-status ()
  "Update status line from selected check-box values in both columns."
  (let ((left (join-labels (labels-in-column "Л")))
        (right (join-labels (labels-in-column "П"))))
    (setf *status*
          (format nil "Левая колонка: ~a   Правая колонка: ~a" left right))))

(defun make-demo-check-box (x y label checked-p window)
  "Create one check-box for demo and attach status update callback."
  (let ((check-box (make-instance
                    'mnas-sdl3-gui/widgets:<check-box>
                    :x       x
                    :y       y
                    :width   190
                    :height  28
                    :label   label
                    :checked checked-p
                    :focused nil
                    :window  window)))
    (setf (mnas-sdl3-gui/widgets:<widget>-value check-box) checked-p)
    (setf (mnas-sdl3-gui/widgets:<widget>-on-change check-box)
          (lambda (widget value)
            (declare (ignore widget value))
            (refresh-check-box-status)))
    check-box))

(defun create-widgets (window)
  "Create demo widgets for two columns of check-box controls."
  (list
   (make-instance 'mnas-sdl3-gui/widgets:<label>
                  :x 20
                  :y 16
                  :width 420
                  :height 28
                  :text "Check-box demo"
                  :window window)
   (make-instance 'mnas-sdl3-gui/widgets:<label>
                  :x 40 :y 56
                  :width 190
                  :height 22
                  :text "Левая колонка"
                  :window window)
   (make-instance 'mnas-sdl3-gui/widgets:<label>
                  :x 250
                  :y 56
                  :width 190
                  :height 22
                  :text "Правая колонка"
                  :window window)
   (make-demo-check-box 40   90 "Л1 Уведомления"    t   window)
   (make-demo-check-box 40  124 "Л2 Звук"           nil window)
   (make-demo-check-box 40  158 "Л3 Подсказки"      t   window)
   (make-demo-check-box 40  192 "Л4 Автосохранение" nil window)
   (make-demo-check-box 250  90 "П1 Сеть"           nil window)
   (make-demo-check-box 250 124 "П2 Логи"           t   window)
   (make-demo-check-box 250 158 "П3 Кэш"            nil window)
   (make-demo-check-box 250 192 "П4 Резерв"         t   window))
  (refresh-check-box-status))


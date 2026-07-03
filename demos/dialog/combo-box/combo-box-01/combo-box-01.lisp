;;;; ./demos/dialog/combo-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defun report-value (app)
  "Update status line from current combo box selections."
  (let* ((small (<combo-box-01-app>-small-widget app))
         (large (combo-box-01-large-widget app))
         (status (format nil "Selected: ~A / ~A"
                         (mnas-sdl3-gui/widgets:<widget>-value small)
                         (mnas-sdl3-gui/widgets:<widget>-value large))))
    (setf (mnas-sdl3-gui/app:app-status app) status)
    (setf (<combo-box-01-app>-demo-status app) status)))

(defun sync-command-state (app)
  "Sync command state for combo-box-01 toolbar."
  (let* ((small (<combo-box-01-app>-small-widget app))
         (large (combo-box-01-large-widget app))
         (report-cmd (mnas-sdl3-gui/commands:find-command :combo-box-01/report))
         (enabled (and small large
                      (mnas-sdl3-gui/widgets:<widget>-value small)
                      (mnas-sdl3-gui/widgets:<widget>-value large))))
    (when report-cmd
      (mnas-sdl3-gui/commands:set-command-enabled report-cmd enabled))))

(defun items (prefix count)
  (loop :for index :from 1 :to count
        :collect (format nil "~A ~D" prefix index)))

(defun create-widgets (app window)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:<label>
                               :x 20 :y 18 :width 520 :height 24
                               :text "Combo-Box Demo"))
         (hint (make-instance 'mnas-sdl3-gui/widgets:<label>
                              :x 20 :y 42 :width 560 :height 24
                              :text "Return confirms, Escape closes popup, wheel scrolls expanded lists."))
         (small (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                               :x 20 :y 86 :width 240 :height 32
                               :items '("Flat" "Windows" "Motif" "Experimental")
                               :selected-index 1
                               :popup-host-window window
                               :window window))
         (large (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                               :x 20 :y 136 :width 320 :height 32
                               :items (items "Preset" 18)
                               :selected-index 4
                               :max-visible-items 7
                               :popup-host-window window
                               :window window))
         (action (make-instance 'mnas-sdl3-gui/widgets:<button>
                                :x 20 :y 196 :width 140 :height 34
                                :text "Report Value"
                                :on-click (lambda (widget)
                                            (declare (ignore widget))
                                            (let ((status (format nil "Selected: ~A / ~A"
                                                                  (mnas-sdl3-gui/widgets:<widget>-value small)
                                                                  (mnas-sdl3-gui/widgets:<widget>-value large))))
                                              (setf (mnas-sdl3-gui/app:app-status app) status)
                                              (setf (<combo-box-01-app>-demo-status app) status)))))
         (widgets (list title hint small large action)))
    (setf (<combo-box-01-app>-small-widget app) small
          (combo-box-01-large-widget app) large
          (mnas-sdl3-gui/app:app-widgets app) widgets)
    (when window
      (mnas-sdl3-gui/widgets:register-widgets-for-window window widgets))
    widgets))


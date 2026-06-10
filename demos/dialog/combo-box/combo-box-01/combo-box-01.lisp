;;;; ./demos/dialog/combo-box-01.lisp





(defun combo-box-01-report-value ()
  "Update status line from current combo box selections."
  (setf *status*
        (format nil "Selected: ~A / ~A"
                (mnas-sdl3-gui/widgets:widget-value *small*)
                (mnas-sdl3-gui/widgets:widget-value *large*))))



(defun combo-box-01-sync-command-state ()
  "Sync command state for combo-box-01 toolbar." 
  (let ((report-cmd (mnas-sdl3-gui/commands:find-command :combo-box-01/report))
        (enabled (and *small*
                      *large*
                      (mnas-sdl3-gui/widgets:widget-value *small*)
                      (mnas-sdl3-gui/widgets:widget-value *large*))))
    (when report-cmd
      (mnas-sdl3-gui/commands:set-command-enabled report-cmd enabled))))

(defun combo-box-01-items (prefix count)
  (loop for index from 1 to count
        collect (format nil "~A ~D" prefix index)))

(defun create-combo-box-01-widgets (&optional window)
  (let* ((title (make-instance 'mnas-sdl3-gui/widgets:label
                               :x 20 :y 18 :width 520 :height 24
                               :text "Combo-Box Demo"))
         (hint (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 42 :width 560 :height 24
                              :text "Return confirms, Escape closes popup, wheel scrolls expanded lists."))
         (small (make-instance 'mnas-sdl3-gui/widgets:combo-box
                               :x 20 :y 86 :width 240 :height 32
                               :items '("Flat" "Windows" "Motif" "Experimental")
                               :selected-index 1
                               :popup-host-window window
                               :window window))
         (large (make-instance 'mnas-sdl3-gui/widgets:combo-box
                               :x 20 :y 136 :width 320 :height 32
                               :items (combo-box-01-items "Preset" 18)
                               :selected-index 4
                               :max-visible-items 7
                               :popup-host-window window
                               :window window))
         (action (make-instance 'mnas-sdl3-gui/widgets:button
                                :x 20 :y 196 :width 140 :height 34
                                :text "Report Value"
                                :on-click (lambda (widget)
                                            (declare (ignore widget))
                                            (setf *status*
                                                  (format nil "Selected: ~A / ~A"
                                                          (mnas-sdl3-gui/widgets:widget-value small)
                                                          (mnas-sdl3-gui/widgets:widget-value large)))))))
    (setf *small* small
          *large* large
          *widgets* (list title hint small large action))
    (when window
      (mnas-sdl3-gui/widgets:register-widgets-for-window window *widgets*))
    *widgets*))





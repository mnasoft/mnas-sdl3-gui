;;;; ./demos/dialog/combo-box/combo-box-01/toolbar.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defun combo-box-01-create-toolbar (window)
  "Create toolbar for the combo-box-01 demo." 
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:toolbar
           :layout :horizontal
           :height +combo-box-01-toolbar-height+
           :window window
           )))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:toolbar-button
            :command-id :combo-box-01/report
            :label "Report"
            :width 72
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:toolbar-button
            :command-id :combo-box-01/quit
            :label "Quit"
            :width 64
            :window window)))
    toolbar))

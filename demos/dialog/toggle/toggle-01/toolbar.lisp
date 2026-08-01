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
            :command-id :toggle-01/group-1-option-4
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

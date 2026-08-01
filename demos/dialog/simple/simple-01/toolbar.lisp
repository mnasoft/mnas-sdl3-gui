;;;; ./demos/dialog/simple/simple-01/toolbar.lisp

(in-package :mnas-sdl3-gui/demos/dialog/simple-01)

(defun simple-01-create-toolbar ()
  "Create toolbar for simple-01 demo." 
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:<toolbar>
                                :layout :horizontal
                                :height +simple-dialog-toolbar-height+)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button>
                          :command-id :simple-01/ok
                          :label "OK"
                          :width 56)
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button>
                          :command-id :simple-01/cancel
                          :label "Cancel"
                          :width 72)
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button>
                          :command-id :simple-01/quit
                          :label "Quit"
                          :width 64)))
    toolbar))

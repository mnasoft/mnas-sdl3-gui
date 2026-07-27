(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defun combo-box-01 (&optional (style :windows))
  "Run combo-box demo with STYLE (:flat, :windows, :motif)."
  (let ((app (make-instance '<combo-box-01-app>
                            :title "Combo-Box Demo"
                            :width 620
                            :height +combo-box-01-window-height+
                            :style style)))
    (setf *combo-box-01-current-application* app)
    (sdl3:enter-app-main-callbacks
     'callback-init
     'callback-iterate
     'callback-event
     'callback-quit)))

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-01)

;;;; (mnas-sdl3-gui/demos/dialog/combo-box-01:combo-box-01)
;;;; (combo-box-01)

;;;;(mnas-debug:enable)
;;;;(mnas-debug:disable)
;;;; mnas-sdl3-gui/widgets::*ttf-font*
;;;; (mnas-sdl3-gui/widgets::widget-text-pixel-size "M")

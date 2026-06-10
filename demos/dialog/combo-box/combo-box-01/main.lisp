(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defun combo-box-01 (&optional (style :windows))
  "Run combo-box demo with STYLE (:flat, :windows, :motif)."
  (setf *style* style)
  (sdl3:enter-app-main-callbacks
   'combo-box-01-init
   'combo-box-01-iterate
   'combo-box-01-event
   'combo-box-01-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-01)

;;;; (mnas-sdl3-gui/demos/dialog/combo-box-01:combo-box-01)
;;;; (combo-box-01)

;;;;(mnas-debug:enable)
;;;;(mnas-debug:disable)

;;;; ./demos/dialog/window/window-02/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(defun main (&optional (style :windows))
  "Compatibility wrapper for the older demo entrypoint."
  (window-02 style))

(defun window-02 (&optional (style :windows))
  "Run popup-menu demo using a dedicated :popup-menu window."
  (mnas-sdl3-gui/widgets:set-widget-style style)
  (setf *main-window* nil
        *main-renderer* nil
        *main-id* 0
        *layer-manager* nil
        *toolbar* nil
        *popup-window* nil
        *popup-renderer* nil
        *popup-id* 0
        *popup-visible* nil
        *pin-popup* nil
        *open* t
        *hover-index* nil
        *selected-item* "No item selected")
  (sdl3:enter-app-main-callbacks
   'window-02-init
   'window-02-iterate
   'window-02-event
   'window-02-quit)
  :done)

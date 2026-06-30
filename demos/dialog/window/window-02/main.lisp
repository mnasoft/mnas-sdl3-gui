;;;; ./demos/dialog/window/window-02/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(defun main ()
  "Run the popup-menu window demo."
  (window-02))

(defun window-02 ()
  "Run popup-menu demo using a dedicated :popup-menu window."
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

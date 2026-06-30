;;;; ./demos/dialog/window/window-01/main.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

(defun main ()
  "Run the resizable window demo."
  (window-01))

(defun window-01 ()
  "Run a resizable window demo."
  (run-demo "Resizable Window Demo" :resizable))

(define-flag-demo fullscreen :fullscreen)
(define-flag-demo opengl :opengl)
(define-flag-demo occluded :occluded)
(define-flag-demo hidden :hidden)
(define-flag-demo borderless :borderless)
(define-flag-demo resizable :resizable)
(define-flag-demo minimized :minimized)
(define-flag-demo maximized :maximized)
(define-flag-demo mouse-grabbed :mouse-grabbed)
(define-flag-demo input-focus :input-focus)
(define-flag-demo mouse-focus :mouse-focus)
(define-flag-demo external :external)
(define-flag-demo modal :modal)
(define-flag-demo high-pixel-density :high-pixel-density)
(define-flag-demo mouse-capture :mouse-capture)
(define-flag-demo mouse-relative-mode :mouse-relative-mode)
(define-flag-demo always-on-top :always-on-top)
(define-flag-demo utility :utility)
(define-flag-demo tooltip :tooltip)
(define-flag-demo keyboard-grabbed :keyboard-grabbed)
(define-flag-demo vulkan :vulkan)
(define-flag-demo metal :metal)
(define-flag-demo not-focusable :not-focusable)

(defun transparent ()
  "Run dedicated transparent-window demo from window-03."
  (mnas-sdl3-gui/demos/dialog/window-03:window-03))

(defun popup-menu ()
  "Run dedicated popup-menu demo from window-02."
  (mnas-sdl3-gui/demos/dialog/window-02:window-02))

(defun all-flags ()
  "Run demo with all available window flags combined."
  (run-demo "Window Flag Demo: ALL" *all-flags*))

(defun modal-stack-runtime ()
  "Run visual runtime demo for nested modal focus-trap policy."
  (run-demo "Window Modal Stack Runtime Demo" :resizable))

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-01)
;;;; (mnas-sdl3-gui/demos/dialog/window-01:main)

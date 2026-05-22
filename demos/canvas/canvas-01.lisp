;;;; ./demos/canvas/canvas-01.lisp

(in-package :mnas-sdl3-gui/demos/canvas)

(defun demo-canvas-01 ()
  "Run a tiny interactive demo (non-blocking) — returns the canvas widget.
This is intended for manual invocation from the REPL." 
  (let ((c (make-canvas-demo :w 480 :h 320)))
    ;; normally we'd register it in a window manager and run an event loop;
    ;; for the demo we simply return the widget to be inspected.
    c))

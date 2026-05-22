;;;; ./demos/canvas/package.lisp

(defpackage :mnas-sdl3-gui/demos/canvas
  (:use #:cl)
  (:export #:make-canvas-demo))

(in-package :mnas-sdl3-gui/demos/canvas)

(defun make-canvas-demo (&key (w 400) (h 300))
  "Create a simple canvas demo widget with a few sample items.
Returns the canvas widget instance." 
  (let ((canvas (make-instance 'mnas-sdl3-gui/widgets:canvas-2d-widget
                               :x 0 :y 0 :width w :height h)))
    ;; simple scene: a few named circles
    (mnas-sdl3-gui/widgets:set-scene canvas
                                     (list
                                      (list :circle :a 50 50 20 '(200 50 50 255))
                                      (list :circle :b 150 120 30 '(50 200 80 255))))
    canvas))

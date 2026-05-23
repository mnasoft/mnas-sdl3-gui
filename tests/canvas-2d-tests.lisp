;;;; ./tests/canvas-2d-tests.lisp

(in-package #:mnas-sdl3-gui/tests)

;; Skip canvas tests when MNAS_SKIP_CANVAS_TESTS environment variable is set.
(unless (uiop:getenv "MNAS_SKIP_CANVAS_TESTS")

  (def-suite :canvas-2d-tests)
  (in-suite :canvas-2d-tests)

  (test canvas-world-screen-inverse
    (let ((c (mnas-sdl3-gui/demos/canvas:make-canvas-demo :w 200 :h 150)))
      (multiple-value-bind (sx sy) (mnas-sdl3-gui/widgets:world-to-screen c 10 20)
        (multiple-value-bind (wx wy) (mnas-sdl3-gui/widgets:screen-to-world c sx sy)
          (is (< (abs (- wx 10)) 1e-6))
          (is (< (abs (- wy 20)) 1e-6))))))

  (test canvas-pan-changes-offsets
    (let ((c (mnas-sdl3-gui/demos/canvas:make-canvas-demo :w 300 :h 200)))
      (multiple-value-bind (ox oy) (mnas-sdl3-gui/widgets:canvas-2d-viewport-offset-x c)
        ;; initial offsets are 0
        (is (= ox 0))
        (is (= oy 0)))
      (mnas-sdl3-gui/widgets:canvas-2d-pan-by c 15 25)
      (is (= (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-offset-x c) 15))
      (is (= (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-offset-y c) 25)))

  (test canvas-zoom-adjusts-scale-and-centering
    (let ((c (mnas-sdl3-gui/demos/canvas:make-canvas-demo :w 200 :h 200)))
      (setf (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-offset-x c) 0)
      (setf (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-offset-y c) 0)
      (setf (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-scale c) 1.0)
      (let ((old-scale (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-scale c)))
        (mnas-sdl3-gui/widgets:canvas-2d-zoom-by c 2.0 100 100)
        (is (= (mnas-sdl3-gui/widgets:canvas-2d-widget-viewport-scale c) (* old-scale 2.0))))))

)

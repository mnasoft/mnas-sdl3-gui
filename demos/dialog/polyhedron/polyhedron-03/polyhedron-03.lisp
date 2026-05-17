;;;; ./demos/dialog/polyhedron/polyhedron-vulkan-solid-01/polyhedron-vulkan-solid-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/polyhedron-03)


(defparameter *polyhedron-solid-window* nil)
(defparameter *polyhedron-solid-renderer* nil)
(defparameter *polyhedron-solid-open* t)
(defparameter *polyhedron-solid-last-time* nil)
(defparameter *polyhedron-solid-rotation* 0.0)
(defparameter *polyhedron-solid-shape-index* 0)
(defparameter *polyhedron-solid-window-width* 900)
(defparameter *polyhedron-solid-window-height* 700)

(defparameter *icosahedron-vertices*
  (let ((phi (/ (+ 1.0 (sqrt 5.0)) 2.0)))
    (list (list 0.0 1.0 phi)
          (list 0.0 -1.0 phi)
          (list 0.0 1.0 (- phi))
          (list 0.0 -1.0 (- phi))
          (list 1.0 phi 0.0)
          (list -1.0 phi 0.0)
          (list 1.0 (- phi) 0.0)
          (list -1.0 (- phi) 0.0)
          (list phi 0.0 1.0)
          (list (- phi) 0.0 1.0)
          (list phi 0.0 -1.0)
          (list (- phi) 0.0 -1.0))))

(defparameter *icosahedron-faces*
  '((0 1 8)
    (0 8 4)
    (0 4 5)
    (0 5 9)
    (0 9 1)
    (1 9 7)
    (1 7 6)
    (1 6 8)
    (2 3 11)
    (2 10 3)
    (2 5 4)
    (2 4 10)
    (2 11 5)
    (3 10 6)
    (3 6 7)
    (3 7 11)
    (4 8 10)
    (5 11 9)
    (6 10 8)
    (7 9 11)))

(defparameter *cube-vertices*
    '((1.0 1.0 1.0)
      (1.0 1.0 -1.0)
      (1.0 -1.0 1.0)
      (1.0 -1.0 -1.0)
      (-1.0 1.0 1.0)
      (-1.0 1.0 -1.0)
      (-1.0 -1.0 1.0)
      (-1.0 -1.0 -1.0)))

(defparameter *cube-faces*
  '((0 4 6 2)
    (1 3 7 5)
    (0 1 5 4)
    (2 6 7 3)
    (0 2 3 1)
    (4 5 7 6)))

(defparameter *tetrahedron-vertices*
    '((1.0 1.0 1.0)
      (1.0 -1.0 -1.0)
      (-1.0 1.0 -1.0)
      (-1.0 -1.0 1.0)))

(defparameter *tetrahedron-faces*
  '((0 1 2)
    (0 3 1)
    (0 2 3)
    (1 3 2)))

(defparameter *octahedron-vertices*
  '((1.0 0.0 0.0)
    (-1.0 0.0 0.0)
    (0.0 1.0 0.0)
    (0.0 -1.0 0.0)
    (0.0 0.0 1.0)
    (0.0 0.0 -1.0)))

(defparameter *octahedron-faces*
  '((0 2 4)
    (2 1 4)
    (1 3 4)
    (3 0 4)
    (0 5 2)
    (2 5 1)
    (1 5 3)
    (3 5 0)))

(defun polyhedron-solid-seconds-now ()
  (/ (get-internal-real-time) internal-time-units-per-second))

(defun vec-add (a b)
    (mapcar #'+ a b))

(defun vec-scale (vector factor)
    (mapcar (lambda (value) (* value factor)) vector))

(defun vec-sub (a b)
    (mapcar #'- a b))

(defun vec-dot (a b)
    (reduce #'+ (mapcar #'* a b)))

(defun vec-cross (a b)
    (list (- (* (second a) (third b)) (* (third a) (second b)))
          (- (* (third a) (first b)) (* (first a) (third b)))
          (- (* (first a) (second b)) (* (second a) (first b)))))

(defun vec-length (vector)
    (sqrt (max 0.0 (vec-dot vector vector))))

(defun vec-normalize (vector)
    (let ((length (vec-length vector)))
      (if (zerop length)
          vector
          (vec-scale vector (/ 1.0 length)))))

(defun compute-dodecahedron-vertices ()
    (loop for face in *icosahedron-faces*
          collect (vec-normalize
                   (vec-scale
                    (reduce #'vec-add
                            (mapcar (lambda (index)
                                      (nth index *icosahedron-vertices*))
                                    face)
                            :initial-value '(0.0 0.0 0.0))
                    (/ 1.0 3.0)))))

(defun vertex-face-indices (vertex-index)
    (loop for face-index from 0 below (length *icosahedron-faces*)
          for face in *icosahedron-faces*
          when (member vertex-index face)
            collect face-index))

(defun compute-dodecahedron-faces (dodeca-vertices)
    (let ((vertex-to-faces
            (loop for vertex-index from 0 below (length *icosahedron-vertices*)
                  collect (vertex-face-indices vertex-index))))
      (loop for vertex-index from 0 below (length *icosahedron-vertices*)
            for face-indices = (nth vertex-index vertex-to-faces)
            for center = (vec-normalize (nth vertex-index *icosahedron-vertices*))
            for up = (if (< (abs (first center)) 0.9)
                         '(1.0 0.0 0.0)
                         '(0.0 1.0 0.0))
            for axis-u = (vec-normalize (vec-cross up center))
            for axis-v = (vec-cross center axis-u)
            collect
            (stable-sort (copy-list face-indices) #'<
                         :key (lambda (face-index)
                                (let* ((point (nth face-index dodeca-vertices))
                                       (projection (vec-sub point
                                                            (vec-scale center (vec-dot point center))))
                                       (x (vec-dot projection axis-u))
                                       (y (vec-dot projection axis-v)))
                                  (atan y x)))))))

(defparameter *dodecahedron-vertices* (compute-dodecahedron-vertices))
(defparameter *dodecahedron-faces* (compute-dodecahedron-faces *dodecahedron-vertices*))

(defparameter *shape-specs*
    (list (list :name "Dodecahedron"
                :vertices *dodecahedron-vertices*
                :faces *dodecahedron-faces*
                :color '(80 220 255)
                :scale 1.15)
          (list :name "Icosahedron"
                :vertices *icosahedron-vertices*
                :faces *icosahedron-faces*
                :color '(80 220 255)
                :scale 1.15)
          (list :name "Cube"
                :vertices *cube-vertices*
                :faces *cube-faces*
                :color '(255 190 70)
                :scale 1.35)
          (list :name "Tetrahedron"
                :vertices *tetrahedron-vertices*
                :faces *tetrahedron-faces*
                :color '(255 120 180)
                :scale 1.45)
          (list :name "Octahedron"
                :vertices *octahedron-vertices*
                :faces *octahedron-faces*
                :color '(135 255 145)
                :scale 1.25)))

(defun current-shape-spec ()
    (nth *polyhedron-solid-shape-index* *shape-specs*))

(defun update-polyhedron-solid-window-size ()
    (when *polyhedron-solid-window*
      (multiple-value-bind (ok width height)
          (sdl3:get-window-size *polyhedron-solid-window*)
        (when ok
          (setf *polyhedron-solid-window-width* width
                *polyhedron-solid-window-height* height)))))

(defun project-point (point &key (distance 4.0) (scale 1.0))
    (destructuring-bind (x y z) point
      (let* ((depth (+ z distance))
             (factor (/ (* 0.42 (min *polyhedron-solid-window-width* *polyhedron-solid-window-height*) scale)
                        (max 0.4 depth)))
             (screen-x (+ (/ *polyhedron-solid-window-width* 2.0) (* x factor)))
             (screen-y (+ (/ *polyhedron-solid-window-height* 2.0) (* (- y) factor))))
        (list screen-x screen-y z))))

(defun clamp-byte (value)
    (round (max 0 (min 255 value))))

(defun face-brightness-color (base-color avg-z)
    (destructuring-bind (r g b) base-color
      (let ((brightness (+ 0.52 (* 0.35 (/ (+ avg-z 2.5) 5.0)))))
        (list (clamp-byte (* r brightness))
              (clamp-byte (* g brightness))
              (clamp-byte (* b brightness))))))

(defun line-x-at-y (p q y)
    (let ((x1 (first p)) (y1 (second p))
          (x2 (first q)) (y2 (second q)))
      (if (= y1 y2)
          x1
          (+ x1 (* (/ (- y y1) (- y2 y1)) (- x2 x1))))))

(defun fill-triangle (renderer p1 p2 p3)
    (let* ((sorted (sort (copy-list (list p1 p2 p3)) #'< :key #'second))
           (pa (first sorted))
           (pb (second sorted))
           (pc (third sorted))
           (ymin (floor (second pa)))
           (ymax (ceiling (second pc))))
      (loop for y from ymin to ymax do
        (let ((xs nil))
          (dolist (edge (list (list pa pb) (list pb pc) (list pa pc)))
            (destructuring-bind (p q) edge
              (let ((y1 (second p)) (y2 (second q)))
                (when (not (= y1 y2))
                  (let ((ymin-edge (min y1 y2))
                        (ymax-edge (max y1 y2)))
                    (when (and (<= ymin-edge y) (<= y ymax-edge))
                      (push (line-x-at-y p q y) xs)))))))
          (when (>= (length xs) 2)
            (setf xs (sort xs #'<))
            (sdl3:render-line renderer
                              (coerce (first xs) 'single-float)
                              (coerce y 'single-float)
                              (coerce (nth (1- (length xs)) xs) 'single-float)
                              (coerce y 'single-float)))))))

(defun face-visible-p (face rotated-vertices)
    (let* ((a (nth (first face) rotated-vertices))
           (b (nth (second face) rotated-vertices))
           (c (nth (third face) rotated-vertices))
           (normal (vec-cross (vec-sub b a) (vec-sub c a))))
      (< (vec-dot normal '(0.0 0.0 -1.0)) 0.0)))

(defun average-face-z (face rotated-vertices)
    (/ (reduce #'+ (mapcar (lambda (index) (third (nth index rotated-vertices))) face))
       (length face)))

(defun draw-polyhedron-solid-shape ()
    (let* ((shape (current-shape-spec))
           (vertices (getf shape :vertices))
           (faces (getf shape :faces))
           (scale (getf shape :scale))
           (base-color (getf shape :color))
           (rotated-vertices
             (mapcar (lambda (vertex)
                       (rotate-point (vec-scale vertex scale) *polyhedron-solid-rotation*))
                     vertices))
           (projected-vertices
             (mapcar #'project-point rotated-vertices))
           (visible-faces
             (stable-sort (copy-list (remove-if-not (lambda (face)
                                                      (face-visible-p face rotated-vertices))
                                                    faces))
                          #'<
                          :key (lambda (face)
                                 (average-face-z face rotated-vertices)))))
      (dolist (face visible-faces)
        (let* ((avg-z (average-face-z face rotated-vertices))
               (face-color (face-brightness-color base-color avg-z)))
          (sdl3:set-render-draw-color *polyhedron-solid-renderer*
                                      (first face-color)
                                      (second face-color)
                                      (third face-color)
                                      255)
          (let ((first-index (first face)))
            (loop for i from 1 below (- (length face) 1) do
              (fill-triangle *polyhedron-solid-renderer*
                             (nth first-index projected-vertices)
                             (nth (nth i face) projected-vertices)
                             (nth (nth (1+ i) face) projected-vertices))))
          (let ((edge-color (mapcar (lambda (v) (clamp-byte (* v 0.5))) base-color)))
            (sdl3:set-render-draw-color *polyhedron-solid-renderer*
                                        (first edge-color)
                                        (second edge-color)
                                        (third edge-color)
                                        255)
            (loop for i from 0 below (length face)
                  for a = (nth (nth i face) projected-vertices)
                  for b = (nth (nth (mod (1+ i) (length face)) face) projected-vertices)
                  do (sdl3:render-line *polyhedron-solid-renderer*
                                       (coerce (first a) 'single-float)
                                       (coerce (second a) 'single-float)
                                       (coerce (first b) 'single-float)
                                       (coerce (second b) 'single-float))))))))

(sdl3:def-app-init p-vulkan-demo-init (argc argv)
    (declare (ignore argc argv))
    (sdl3:set-app-metadata "Polyhedron Vulkan Solid Demo" "1.0"
                           "com.mna.sdl3.gui.polyhedron.vulkan.solid.demo")
    (unless (sdl3:init :video)
      (format t "~a~%" (sdl3:get-error))
      (return-from p-vulkan-demo-init :failure))
    (multiple-value-bind (ok window renderer)
        (sdl3:create-window-and-renderer "Polyhedron Vulkan Solid Demo"
                                         *polyhedron-solid-window-width*
                                         *polyhedron-solid-window-height*
                                         '(:vulkan :resizable))
      (unless ok
        (format t "~a~%" (sdl3:get-error))
        (return-from p-vulkan-demo-init :failure))
      (setf *polyhedron-solid-window* window
            *polyhedron-solid-renderer* renderer
            *polyhedron-solid-open* t
            *polyhedron-solid-last-time* (polyhedron-solid-seconds-now)
            *polyhedron-solid-rotation* 0.0
            *polyhedron-solid-shape-index* 0)
      (mnas-sdl3-gui/widgets:init-ttf-font)
      :continue))

(sdl3:def-app-iterate polyhedron-vulkan-solid-demo-iterate ()
    (unless *polyhedron-solid-open*
      (return-from polyhedron-vulkan-solid-demo-iterate :success))
    (let* ((now (polyhedron-solid-seconds-now))
           (delta (- now *polyhedron-solid-last-time*)))
      (setf *polyhedron-solid-last-time* now)
      (incf *polyhedron-solid-rotation* (* 1.15 delta)))
    (update-polyhedron-solid-window-size)
    (sdl3:set-render-draw-color *polyhedron-solid-renderer* 15 18 24 255)
    (sdl3:render-clear *polyhedron-solid-renderer*)
    (draw-polyhedron-solid-shape)
    (render-polyhedron-solid-overlay)
    (sdl3:render-present *polyhedron-solid-renderer*)
    :continue)

(sdl3:def-app-event polyhedron-vulkan-solid-demo-event (type event)
    (declare (ignore type))
    (let ((parsed (sdl3:event-unmarshal event)))
      (typecase parsed
        (sdl3:quit-event
         (setf *polyhedron-solid-open* nil)
         :success)
        (sdl3:keyboard-event
         (when (and (slot-value parsed 'sdl3:%down)
                    (not (slot-value parsed 'sdl3:%repeat)))
           (case (slot-value parsed 'sdl3:%key)
             (:escape
              (setf *polyhedron-solid-open* nil)
              (return-from polyhedron-vulkan-solid-demo-event :success))
             (:space
              (setf *polyhedron-solid-shape-index*
                    (mod (1+ *polyhedron-solid-shape-index*) (length *shape-specs*))))))
         :continue)
        (t :continue))))

(sdl3:def-app-quit polyhedron-vulkan-solid-demo-quit (result)
    (declare (ignore result))
    (mnas-sdl3-gui/widgets:cleanup-ttf)
    (when *polyhedron-solid-renderer*
      (sdl3:destroy-renderer *polyhedron-solid-renderer*))
    (when *polyhedron-solid-window*
      (sdl3:destroy-window *polyhedron-solid-window*))
    (sdl3:pump-events)
    (sdl3:quit-sub-system :video)
    (sdl3:quit))

(defun polyhedron-03 ()
    "Run the solid polyhedron Vulkan demo. Press Space to switch shapes."
    (sdl3:enter-app-main-callbacks
     #'p-vulkan-demo-init
     #'polyhedron-vulkan-solid-demo-iterate
     #'polyhedron-vulkan-solid-demo-event
     #'polyhedron-vulkan-solid-demo-quit))
  
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/polyhedron-03)
;;;; (polyhedron-03)


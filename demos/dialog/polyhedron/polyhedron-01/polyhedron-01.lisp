;;;; ./demos/dialog/polyhedron/polyhedron-01/polyhedron-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/polyhedron-01)

(defparameter *polyhedron-window* nil)
(defparameter *polyhedron-renderer* nil)
(defparameter *polyhedron-open* t)
(defparameter *polyhedron-last-time* nil)
(defparameter *polyhedron-rotation* 0.0)
(defparameter *polyhedron-shape-index* 0)
(defparameter *polyhedron-window-id* 0)
(defparameter *polyhedron-toolbar* nil)
(defparameter +polyhedron-toolbar-height+ 32)
(defparameter *polyhedron-window-width* 900)
(defparameter *polyhedron-window-height* 700)

(defun polyhedron-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST."
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun polyhedron-register-commands ()
  "Register commands for polyhedron-01 demo."
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :polyhedron-01/quit
    "Quit polyhedron demo"
    :group :polyhedron-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *polyhedron-open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :polyhedron-01/next-shape
    "Switch to next polyhedron"
    :group :polyhedron-01
    :shortcut :space
    :execute (lambda (context)
               (declare (ignore context))
               (setf *polyhedron-shape-index*
                     (mod (1+ *polyhedron-shape-index*) (length *shape-specs*)))
               t))
   :replace t))

(defun polyhedron-register-shortcuts ()
  "Register keyboard shortcuts for polyhedron-01 demo."
  (mnas-sdl3-gui/commands:register-shortcut :polyhedron-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :polyhedron-01/next-shape :space :replace t)
  t)

(defun polyhedron-create-toolbar ()
  "Create toolbar for polyhedron-01 demo."
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:toolbar
                  :layout :horizontal
                  :height +polyhedron-toolbar-height+)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Next"
                                                   :width 72)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Quit"
                                                   :width 64)))
    toolbar))

(defun polyhedron-01-sync-command-state ()
  "Sync toolbar button state with polyhedron-01 commands."
  (when *polyhedron-toolbar*
    (mnas-sdl3-gui/toolbar:update-toolbar-command-state *polyhedron-toolbar*)))

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

(defun polyhedron-seconds-now ()
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
  (nth *polyhedron-shape-index* *shape-specs*))

(defun update-polyhedron-window-size ()
  (when *polyhedron-window*
    (multiple-value-bind (ok width height)
        (sdl3:get-window-size *polyhedron-window*)
      (when ok
        (setf *polyhedron-window-width* width
              *polyhedron-window-height* height)))))

(defun edge-key (a b)
  (if (< a b)
      (list a b)
      (list b a)))

(defun unique-face-edges (faces)
  (let ((seen (make-hash-table :test #'equal))
        (result nil))
    (dolist (face faces)
      (loop for index from 0 below (length face)
            for a = (nth index face)
            for b = (nth (mod (1+ index) (length face)) face)
            for key = (edge-key a b)
            unless (gethash key seen)
              do (setf (gethash key seen) t)
                 (push key result)))
    (nreverse result)))

(defun rotate-point (point angle)
  (destructuring-bind (x y z) point
    (let* ((x-angle (* angle 0.7))
           (cx (cos x-angle))
           (sx (sin x-angle))
           (cy (cos angle))
           (sy (sin angle))
           (y1 (- (* y cx) (* z sx)))
           (z1 (+ (* y sx) (* z cx)))
           (x2 (+ (* x cy) (* z1 sy)))
           (z2 (- (* z1 cy) (* x sy))))
      (list x2 y1 z2))))

(defun project-point (point &key (distance 4.0) (scale 1.0))
  (destructuring-bind (x y z) point
    (let* ((depth (+ z distance))
           (factor (/ (* 0.42 (min *polyhedron-window-width* *polyhedron-window-height*) scale)
                      (max 0.4 depth)))
           (screen-x (+ (/ *polyhedron-window-width* 2.0) (* x factor)))
           (screen-y (+ (/ *polyhedron-window-height* 2.0) (* (- y) factor))))
      (list screen-x screen-y z))))

(defun clamp-byte (value)
  (round (max 0 (min 255 value))))

(defun edge-color-for-depth (base-color avg-z)
  (destructuring-bind (r g b) base-color
    (let ((brightness (+ 0.45 (* 0.35 (/ (+ avg-z 2.5) 5.0)))))
      (list (clamp-byte (* r brightness))
            (clamp-byte (* g brightness))
            (clamp-byte (* b brightness))))))

(defun draw-polyhedron-shape ()
  (let* ((shape (current-shape-spec))
         (vertices (getf shape :vertices))
         (edges (unique-face-edges (getf shape :faces)))
         (scale (getf shape :scale))
         (base-color (getf shape :color))
         (rotated-projected
           (mapcar (lambda (vertex)
                     (project-point
                      (rotate-point (vec-scale vertex scale) *polyhedron-rotation*)))
                   vertices)))
    (dolist (edge edges)
      (destructuring-bind (a b) edge
        (destructuring-bind (x1 y1 z1) (nth a rotated-projected)
          (destructuring-bind (x2 y2 z2) (nth b rotated-projected)
            (destructuring-bind (r g b-color)
                (edge-color-for-depth base-color (/ (+ z1 z2) 2.0))
              (sdl3:set-render-draw-color *polyhedron-renderer* r g b-color 255)
              (sdl3:render-line *polyhedron-renderer*
                                (coerce x1 'single-float)
                                (coerce y1 'single-float)
                                (coerce x2 'single-float)
                                (coerce y2 'single-float)))))))))

(defun render-polyhedron-overlay ()
  (mnas-sdl3-gui/widgets:render-text *polyhedron-renderer*
                                     "Polyhedron demo"
                                     24.0 20.0 '(235 235 235 255))
  (mnas-sdl3-gui/widgets:render-text *polyhedron-renderer*
                                     (format nil "Shape: ~A" (getf (current-shape-spec) :name))
                                     24.0 50.0 '(180 190 205 255))
  (mnas-sdl3-gui/widgets:render-text *polyhedron-renderer*
                                     "Space: next shape, Escape: exit"
                                     24.0 80.0 '(145 155 170 255)))

(sdl3:def-app-init polyhedron-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Polyhedron Demo" "1.0"
                         "com.mna.sdl3.gui.polyhedron.demo")
  (unless (sdl3:init :video)
    (format t "~a~%" (sdl3:get-error))
    (return-from polyhedron-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Polyhedron Demo"
                                       *polyhedron-window-width*
                                       *polyhedron-window-height*
                                       :resizable)
    (unless ok
      (format t "~a~%" (sdl3:get-error))
      (return-from polyhedron-demo-init :failure))
    (setf *polyhedron-window* window
          *polyhedron-window-id* (sdl3:get-window-id window)
          *polyhedron-renderer* renderer
          *polyhedron-open* t
          *polyhedron-last-time* (polyhedron-seconds-now)
          *polyhedron-rotation* 0.0
          *polyhedron-shape-index* 0)
    (polyhedron-register-commands)
    (polyhedron-register-shortcuts)
    (setf *polyhedron-toolbar* (polyhedron-create-toolbar))
    #+nil(mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *polyhedron-toolbar*)
    (mnas-sdl3-gui/widgets:init-ttf-font))
  :continue)

(sdl3:def-app-iterate polyhedron-demo-iterate ()
  (unless *polyhedron-open*
    (return-from polyhedron-demo-iterate :success))
  (let* ((now (polyhedron-seconds-now))
         (delta (- now *polyhedron-last-time*)))
    (setf *polyhedron-last-time* now)
    (incf *polyhedron-rotation* (* 1.15 delta)))
  (update-polyhedron-window-size)
  (sdl3:set-render-draw-color *polyhedron-renderer* 15 18 24 255)
  (sdl3:render-clear *polyhedron-renderer*)
  (polyhedron-01-sync-command-state)
  (when *polyhedron-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *polyhedron-toolbar*
     *polyhedron-renderer*
     0.0
     0.0))
  (draw-polyhedron-shape)
  (render-polyhedron-overlay)
  (sdl3:render-present *polyhedron-renderer*)
  :continue)

(sdl3:def-app-event polyhedron-demo-event (type event)
  (declare (ignore type))
  (let ((parsed (sdl3:event-unmarshal event)))
    (typecase parsed
      (sdl3:quit-event
       (setf *polyhedron-open* nil)
       :success)
      (sdl3:mouse-button-event
       (when (= (slot-value parsed 'sdl3:%button) 1)
         (when (slot-value parsed 'sdl3:%down)
           (let* ((mx (round (slot-value parsed 'sdl3:%x)))
                  (my (round (slot-value parsed 'sdl3:%y)))
                  (button (and *polyhedron-toolbar*
                               (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                *polyhedron-toolbar* mx my))))
             (when button
               (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                *polyhedron-toolbar*
                button
                (list :window-id *polyhedron-window-id*)))))
         :continue)
       (sdl3:keyboard-event
        (when (and (slot-value parsed 'sdl3:%down)
                   (not (slot-value parsed 'sdl3:%repeat)))
          (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                   (slot-value parsed 'sdl3:%key)
                   :mods nil
                   :context (list :window-id *polyhedron-window-id*))
            (case (slot-value parsed 'sdl3:%key)
              (:escape
               (setf *polyhedron-open* nil)
               (return-from polyhedron-demo-event :success))
              (:space
               (setf *polyhedron-shape-index*
                     (mod (1+ *polyhedron-shape-index*) (length *shape-specs*))))))))
       :continue)
      (t :continue))))

(sdl3:def-app-quit polyhedron-demo-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *polyhedron-renderer*
    (sdl3:destroy-renderer *polyhedron-renderer*))
  (when *polyhedron-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *polyhedron-window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun polyhedron-01 ()
  "Run the polyhedron demo. Press Space to switch shapes."
  (sdl3:enter-app-main-callbacks
   'polyhedron-demo-init
   'polyhedron-demo-iterate
   'polyhedron-demo-event
   'polyhedron-demo-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/polyhedron)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/polyhedron-01)
;;;; (polyhedron-01)

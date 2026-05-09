;;;; ./src/widgets/renderer.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; SDL3 Rendering Functions

(defconstant +widget-padding+ 4)
(defconstant +widget-border-width+ 1)
(defconstant +font-char-width+ 8)
(defconstant +font-text-height+ 16)

;;; Color definitions (RGBA) - use list form to avoid redefinition issues
(defparameter +color-bg+ '(240 240 240 255))
(defparameter +color-border+ '(100 100 100 255))
(defparameter +color-text+ '(0 0 0 255))
(defparameter +color-disabled+ '(160 160 160 255))
(defparameter +color-highlight+ '(200 220 255 255))
(defparameter +color-button-hover+ '(220 220 220 255))
(defparameter +color-button-active+ '(200 200 200 255))
(defparameter +color-focus-border+ '(0 100 200 255))

(defun fill-rect (renderer x y w h color)
  "Fill a rectangle with specified color."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (let ((rect (make-instance 'sdl3:frect 
                             :%x (float x 1.0) :%y (float y 1.0)
                             :%w (float w 1.0) :%h (float h 1.0))))
    (sdl3:render-fill-rect renderer rect)))

(defun stroke-rect (renderer x y w h color &optional (width 1))
  "Draw rectangle outline with specified color."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a))
  (let ((rect (make-instance 'sdl3:frect 
                             :%x (float x 1.0) :%y (float y 1.0)
                             :%w (float w 1.0) :%h (float h 1.0))))
    (loop repeat width
          for offset from 0
          do (let ((outline (make-instance 'sdl3:frect
                                          :%x (float (+ x offset) 1.0)
                                          :%y (float (+ y offset) 1.0)
                                          :%w (float (- w (* 2 offset)) 1.0)
                                          :%h (float (- h (* 2 offset)) 1.0))))
               (sdl3:render-rect renderer outline)))))

(defun render-text (renderer text x y color)
  "Render simple text (placeholder - would use font rendering in real app)."
  (destructuring-bind (r g b a) color
    (sdl3:set-render-draw-color renderer r g b a)))

(defun render-widget (renderer widget)
  "Render a widget using appropriate method based on widget type."
  (when (widget-visible widget)
    (cond
      ((typep widget 'label)
       (render-label renderer widget))
      ((typep widget 'button)
       (render-button renderer widget))
      ((typep widget 'toggle)
       (render-toggle renderer widget))
      ((typep widget 'check-box)
       (render-check-box renderer widget))
      ((typep widget 'edit-box)
       (render-edit-box renderer widget))
      ((typep widget 'list-box)
       (render-list-box renderer widget)))))

(defun render-label (renderer widget)
  "Render a label widget."
  (fill-rect renderer (widget-x widget) (widget-y widget)
             (widget-width widget) (widget-height widget)
             +color-bg+)
  (stroke-rect renderer (widget-x widget) (widget-y widget)
               (widget-width widget) (widget-height widget)
               +color-border+)
  ;; Text would be rendered here with actual font rendering
  (render-text renderer (label-text widget)
               (+ (widget-x widget) +widget-padding+)
               (+ (widget-y widget) +widget-padding+)
               (if (widget-enabled widget) +color-text+ +color-disabled+)))

(defun render-button (renderer widget)
  "Render a button widget."
  (let ((color (if (widget-enabled widget) +color-bg+ +color-disabled+)))
    (fill-rect renderer (widget-x widget) (widget-y widget)
               (widget-width widget) (widget-height widget)
               color)
    (stroke-rect renderer (widget-x widget) (widget-y widget)
                 (widget-width widget) (widget-height widget)
                 (if (widget-focused widget) +color-focus-border+ +color-border+)
                 2))
  (render-text renderer (button-text widget)
               (+ (widget-x widget) +widget-padding+)
               (+ (widget-y widget) (/ (- (widget-height widget) +font-text-height+) 2))
               (if (widget-enabled widget) +color-text+ +color-disabled+)))

(defun render-toggle (renderer widget)
  "Render a toggle switch widget."
  (let* ((toggle-width 40)
         (toggle-height 20)
         (toggle-x (widget-x widget))
         (toggle-y (+ (widget-y widget) (/ (- (widget-height widget) toggle-height) 2)))
         (knob-size 16)
         (knob-x (if (toggle-state widget)
                    (+ toggle-x toggle-width (- knob-size 4))
                    (+ toggle-x 4))))
    ;; Toggle background
    (fill-rect renderer toggle-x toggle-y toggle-width toggle-height
               (if (toggle-state widget) '(100 150 200 255) +color-bg+))
    ;; Knob
    (fill-rect renderer knob-x toggle-y knob-size knob-size +color-text+)
    ;; Label
    (render-text renderer (toggle-label widget)
                 (+ toggle-x toggle-width +widget-padding+ 5)
                 (+ toggle-y (/ (- toggle-height +font-text-height+) 2))
                 +color-text+)))

(defun render-check-box (renderer widget)
  "Render a checkbox widget."
  (let* ((box-size 16)
         (box-x (widget-x widget))
         (box-y (+ (widget-y widget) (/ (- (widget-height widget) box-size) 2))))
    ;; Box background
    (fill-rect renderer box-x box-y box-size box-size +color-bg+)
    ;; Box border
    (stroke-rect renderer box-x box-y box-size box-size +color-border+)
    ;; Check mark if checked
    (when (check-box-checked widget)
      (fill-rect renderer (+ box-x 3) (+ box-y 3) 10 10 +color-text+))
    ;; Label
    (render-text renderer (check-box-label widget)
                 (+ box-x box-size +widget-padding+)
                 (+ box-y (/ (- box-size +font-text-height+) 2))
                 +color-text+)))

(defun render-edit-box (renderer widget)
  "Render an edit box widget."
  ;; Background
  (fill-rect renderer (widget-x widget) (widget-y widget)
             (widget-width widget) (widget-height widget)
             (if (widget-focused widget) '(255 255 255 255) '(245 245 245 255)))
  ;; Border
  (stroke-rect renderer (widget-x widget) (widget-y widget)
               (widget-width widget) (widget-height widget)
               (if (widget-focused widget) +color-focus-border+ +color-border+)
               2)
  ;; Text
  (render-text renderer (edit-box-text widget)
               (+ (widget-x widget) +widget-padding+)
               (+ (widget-y widget) (/ (- (widget-height widget) +font-text-height+) 2))
               +color-text+)
  ;; Cursor
  (when (widget-focused widget)
    (let ((cursor-x (+ (widget-x widget) +widget-padding+
                       (* (edit-box-cursor widget) +font-char-width+))))
      (sdl3:set-render-draw-color renderer 0 0 0 255)
      (sdl3:render-line renderer (float cursor-x 1.0) (float (+ (widget-y widget) 2) 1.0)
                        (float cursor-x 1.0) (float (- (+ (widget-y widget) (widget-height widget)) 2) 1.0)))))

(defun render-list-box (renderer widget)
  "Render a list box widget."
  ;; Background
  (fill-rect renderer (widget-x widget) (widget-y widget)
             (widget-width widget) (widget-height widget)
             +color-bg+)
  ;; Border
  (stroke-rect renderer (widget-x widget) (widget-y widget)
               (widget-width widget) (widget-height widget)
               +color-border+)
  ;; Items
  (loop for i from 0
        for item in (list-box-items widget)
        for item-y = (+ (widget-y widget) (* i (list-box-item-height widget)))
        while (< item-y (+ (widget-y widget) (widget-height widget)))
        do (progn
             ;; Item background
             (when (= i (list-box-selected-index widget))
               (fill-rect renderer (widget-x widget) item-y
                         (widget-width widget) (list-box-item-height widget)
                         +color-highlight+))
             ;; Item text
             (render-text renderer (format nil "~a" item)
                         (+ (widget-x widget) +widget-padding+)
                         (+ item-y (/ (- (list-box-item-height widget) +font-text-height+) 2))
                         +color-text+))))

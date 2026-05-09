;;;; ./src/widgets/renderer.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; SDL3 Rendering Functions

(defconstant +widget-padding+ 4)
(defconstant +widget-border-width+ 1)
(defconstant +font-char-width+ 8)
(defconstant +font-text-height+ 16)

(defclass widget-style ()
  ()
  (:documentation "Base rendering style for widgets."))

(defclass flat-widget-style (widget-style)
  ()
  (:documentation "Flat widget rendering style."))

(defclass windows-widget-style (widget-style)
  ()
  (:documentation "Windows-like beveled widget rendering style."))

(defclass motif-widget-style (widget-style)
  ()
  (:documentation "Motif-like beveled widget rendering style."))

(defparameter *widget-style* (make-instance 'flat-widget-style)
  "Current widget rendering style.")

;;; Color definitions (RGBA) - use list form to avoid redefinition issues
(defparameter +color-bg+ '(240 240 240 255))
(defparameter +color-border+ '(100 100 100 255))
(defparameter +color-text+ '(0 0 0 255))
(defparameter +color-disabled+ '(160 160 160 255))
(defparameter +color-highlight+ '(200 220 255 255))
(defparameter +color-button-hover+ '(220 220 220 255))
(defparameter +color-button-active+ '(200 200 200 255))
(defparameter +color-focus-border+ '(0 100 200 255))

(defun widget-style-name (style)
  "Return keyword designator for STYLE instance."
  (typecase style
    (windows-widget-style :windows)
    (motif-widget-style :motif)
    (flat-widget-style :flat)
    (t :flat)))

(defun make-widget-style (style-designator)
  "Create widget style object from keyword or return existing instance." 
  (typecase style-designator
    (widget-style style-designator)
    ((eql :windows) (make-instance 'windows-widget-style))
    ((eql :motif) (make-instance 'motif-widget-style))
    ((or (eql :flat) null) (make-instance 'flat-widget-style))
    (t (error "Unknown widget style: ~a" style-designator))))

(defun set-widget-style (style-designator)
  "Set current widget rendering style. Returns the style instance." 
  (setf *widget-style* (make-widget-style style-designator)))

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

(defun render-bevel-rect (renderer x y w h top-left-color bottom-right-color &optional (width 1))
  "Draw a beveled border using different colors on opposite edges." 
  (loop repeat width
        for offset from 0
        do (progn
             (destructuring-bind (r g b a) top-left-color
               (sdl3:set-render-draw-color renderer r g b a))
             (sdl3:render-line renderer
                               (float (+ x offset) 1.0)
                               (float (+ y offset) 1.0)
                               (float (- (+ x w) offset 1) 1.0)
                               (float (+ y offset) 1.0))
             (sdl3:render-line renderer
                               (float (+ x offset) 1.0)
                               (float (+ y offset) 1.0)
                               (float (+ x offset) 1.0)
                               (float (- (+ y h) offset 1) 1.0))
             (destructuring-bind (r g b a) bottom-right-color
               (sdl3:set-render-draw-color renderer r g b a))
             (sdl3:render-line renderer
                               (float (+ x offset) 1.0)
                               (float (- (+ y h) offset 1) 1.0)
                               (float (- (+ x w) offset 1) 1.0)
                               (float (- (+ y h) offset 1) 1.0))
             (sdl3:render-line renderer
                               (float (- (+ x w) offset 1) 1.0)
                               (float (+ y offset) 1.0)
                               (float (- (+ x w) offset 1) 1.0)
                               (float (- (+ y h) offset 1) 1.0)))))

(defun render-button-label (renderer widget color)
  "Render centered button label." 
  (let* ((x (+ (widget-x widget) +widget-padding+))
         (y (+ (widget-y widget) (/ (- (widget-height widget) +font-text-height+) 2))))
    (render-text renderer (button-text widget) x y color)))

(defgeneric render-widget-with-style (style renderer widget)
  (:documentation "Render WIDGET using STYLE on RENDERER."))

(defun render-text (renderer text x y color)
  "Render text using TTF font if available, with fallback to ASCII approximation.
   Supports Unicode text including Cyrillic characters."
  (render-text-with-ttf renderer text x y color))

(defun render-widget (renderer widget)
  "Render a widget using appropriate method based on widget type."
  (when (widget-visible widget)
    (render-widget-with-style *widget-style* renderer widget)))

(defmethod render-widget-with-style ((style widget-style) renderer (widget label))
  (declare (ignore style))
  (render-label renderer widget))

(defmethod render-widget-with-style ((style widget-style) renderer (widget toggle))
  (declare (ignore style))
  (render-toggle renderer widget))

(defmethod render-widget-with-style ((style widget-style) renderer (widget check-box))
  (declare (ignore style))
  (render-check-box renderer widget))

(defmethod render-widget-with-style ((style widget-style) renderer (widget edit-box))
  (declare (ignore style))
  (render-edit-box renderer widget))

(defmethod render-widget-with-style ((style widget-style) renderer (widget list-box))
  (declare (ignore style))
  (render-list-box renderer widget))

(defmethod render-widget-with-style ((style flat-widget-style) renderer (widget button))
  (let ((color (if (widget-enabled widget) +color-bg+ +color-disabled+)))
    (fill-rect renderer (widget-x widget) (widget-y widget)
               (widget-width widget) (widget-height widget)
               color)
    (stroke-rect renderer (widget-x widget) (widget-y widget)
                 (widget-width widget) (widget-height widget)
                 (if (widget-focused widget) +color-focus-border+ +color-border+)
                 2))
  (render-button-label renderer widget
                       (if (widget-enabled widget) +color-text+ +color-disabled+)))

(defmethod render-widget-with-style ((style windows-widget-style) renderer (widget button))
  (declare (ignore style))
  (let ((x (widget-x widget))
        (y (widget-y widget))
        (w (widget-width widget))
        (h (widget-height widget))
        (face (if (widget-enabled widget) '(212 208 200 255) '(190 190 190 255))))
    (fill-rect renderer x y w h face)
    (when (widget-focused widget)
      (stroke-rect renderer x y w h +color-focus-border+ 1))
    (render-bevel-rect renderer x y w h '(255 255 255 255) '(128 128 128 255) 1)
    (render-bevel-rect renderer (+ x 1) (+ y 1) (- w 2) (- h 2)
                       '(240 240 240 255) '(64 64 64 255) 1))
  (render-button-label renderer widget
                       (if (widget-enabled widget) +color-text+ +color-disabled+)))

(defmethod render-widget-with-style ((style motif-widget-style) renderer (widget button))
  (declare (ignore style))
  (let ((x (widget-x widget))
        (y (widget-y widget))
        (w (widget-width widget))
        (h (widget-height widget))
        (face (if (widget-enabled widget) '(196 196 196 255) '(170 170 170 255))))
    (fill-rect renderer x y w h face)
    (render-bevel-rect renderer x y w h '(238 238 238 255) '(90 90 90 255) 2)
    (when (widget-focused widget)
      (stroke-rect renderer (+ x 3) (+ y 3) (- w 6) (- h 6) +color-focus-border+ 1)))
  (render-button-label renderer widget
                       (if (widget-enabled widget) +color-text+ +color-disabled+)))

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
  (render-widget-with-style *widget-style* renderer widget))

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

(defun edit-box-cursor-pixel-offset (widget)
  "Return cursor offset in pixels using real glyph widths when TTF is available."
  (let* ((text (edit-box-text widget))
         (cursor (max 0 (min (edit-box-cursor widget) (length text))))
         (prefix (subseq text 0 cursor)))
    (if (and *ttf-available-p* *ttf-font*)
        (handler-case
            (multiple-value-bind (w h)
                (sdl3-ttf:ttf-get-string-size *ttf-font* prefix)
              (declare (ignore h))
              (or w 0))
          (error ()
            (* cursor +font-char-width+)))
        (* cursor +font-char-width+))))

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
                       (edit-box-cursor-pixel-offset widget))))
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

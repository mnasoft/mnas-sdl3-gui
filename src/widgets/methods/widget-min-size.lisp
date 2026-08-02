;;;; ./src/widgets/methods/widget-min-size.lisp
;;;; [^A-Za-z-><]widget[^A-Za-z-><]

(in-package :mnas-sdl3-gui/widgets)

(defmethod widget-min-size ((obj <widget>))
  (values (max 1 (<widget>-width obj)
          (max 1 (<widget>-height obj)))))

(defmethod widget-min-size ((obj <label>))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (<label>-label obj))
    (values (max 24 (+ tw 8))
            (max 20 (+ th 8)))))

(defmethod widget-min-size ((obj <button>))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (<button>-text obj))
    (values (max 64 (+ tw 24))
            (max 28 (+ th 12)))))

(defmethod widget-min-size ((obj <toggle>))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (<toggle>-label obj))
    (declare (ignore th))
    (let ((indicator-width 16)
          (<label>-gap (nth-value 0 (widget-text-pixel-size "M"))))
      (values (max 80 (+ indicator-width <label>-gap tw))
              24))))

(defmethod widget-min-size ((obj <check-box>))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (<check-box>-label obj))
    (let* ((padding (or (<widget>-padding obj) 0))
           (indicator-width 16)
           (content-height (max 8 (max 16 th)))
           (<label>-gap (nth-value 0 (widget-text-pixel-size "M"))))
      (values (max 72 (+ (* 2 padding) indicator-width <label>-gap tw))
              (max 20 (+ (* 2 padding) content-height))))))

(defmethod widget-min-size ((obj <entry>))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (<entry>-text obj))
    (values (max 120 (+ tw 12))
            (max 30 (+ th 10)))))

(defmethod widget-min-size ((obj <tree-view>))
  (values (max 160 (<widget>-width obj))
          (max 96 (<widget>-height obj))))

(defmethod widget-min-size ((obj <list-box>))
  (let* ((items (list-box-items obj))
         (longest-item (or (loop for item in items
                                 maximize (length (format nil "~a" (item-display-value item))))
                          8))
         (lines (max 3 (min 8 (length items))))
         (scrollbar-width (if (> (length items) lines) 12 0))
         (text-width (* longest-item +layout-font-char-width+))
         (min-height (+ (* lines (item-height obj)) 4)))
    (values (max 120 (+ text-width 12 scrollbar-width))
            (max min-height 72))))

(defmethod widget-min-size ((obj <combo-box>))
  (let* ((items (list-box-items obj))
         (longest-item (or (loop for item in items
                                 maximize (length (format nil "~a" (item-display-value item))))
                          8))
         (text-width (* longest-item +layout-font-char-width+))
         (arrow-width 24))
    (values (max 120 (+ text-width arrow-width 12))
      (max (combo-box-total-height obj)
        (main-height obj)))))

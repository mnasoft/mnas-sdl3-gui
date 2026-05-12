;;;; ./src/widgets/methods/widget-min-size.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod widget-min-size ((widget widget))
  (values (max 1 (widget-width widget))
          (max 1 (widget-height widget))))

(defmethod widget-min-size ((widget label))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (label-text widget))
    (values (max 24 (+ tw 8))
            (max 20 (+ th 8)))))

(defmethod widget-min-size ((widget button))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (button-text widget))
    (values (max 64 (+ tw 24))
            (max 28 (+ th 12)))))

(defmethod widget-min-size ((widget toggle))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (toggle-label widget))
    (declare (ignore th))
    (values (max 80 (+ 40 9 tw))
            24)))

(defmethod widget-min-size ((widget check-box))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (check-box-label widget))
    (values (max 72 (+ 16 4 tw))
            (max 22 (+ th 8)))))

(defmethod widget-min-size ((widget edit-box))
  (multiple-value-bind (tw th)
      (widget-text-pixel-size (edit-box-text widget))
    (values (max 120 (+ tw 12))
            (max 30 (+ th 10)))))

(defmethod widget-min-size ((widget list-box))
  (let* ((longest-item (or (loop for item in (list-box-items widget)
                                 maximize (length (format nil "~a" item)))
                          8))
         (lines (max 3 (min 8 (length (list-box-items widget)))))
         (text-width (* longest-item +layout-font-char-width+))
         (min-height (+ (* lines (list-box-item-height widget)) 4)))
    (values (max 120 (+ text-width 12))
            (max min-height 72))))
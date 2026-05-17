;;;; ./src/widgets/methods/render-entry-text-and-cursor.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod render-entry-text-and-cursor (renderer (widget entry))
  (let* ((text (entry-text widget))
         (text-x (+ (widget-x widget) +widget-padding+))
         (text-y (+ (widget-y widget)
                    (/ (- (widget-height widget) +font-text-height+) 2)))
         (sel-start (entry-selection-start widget))
         (sel-end (entry-selection-end widget))
         (has-selection (and (not (null sel-start))
                             (not (null sel-end))
                             (< sel-start sel-end))))
    (multiple-value-bind (visible-start visible-end)
        (entry-visible-range widget)
      (labels ((segment-x (position)
                 (+ text-x
                    (compute-text-segment-pixel-width widget visible-start position)))
               (render-visible-segment (start end color)
                 (when (< start end)
                   (render-text renderer (subseq text start end)
                                (segment-x start)
                                text-y
                                color))))
        (if has-selection
            (let ((before-start visible-start)
                  (before-end (min visible-end sel-start))
                  (selected-start (max visible-start sel-start))
                  (selected-end (min visible-end sel-end))
                  (after-start (max visible-start sel-end))
                  (after-end visible-end))
              (render-visible-segment before-start before-end +color-text+)
              (when (< selected-start selected-end)
                (let ((selection-x (segment-x selected-start))
                      (selection-w (compute-text-segment-pixel-width
                                    widget
                                    selected-start
                                    selected-end)))
                  (fill-rect renderer selection-x (- text-y 2)
                             selection-w (+ +font-text-height+ 4)
                             '(0 120 215 255))
                  (render-visible-segment selected-start selected-end
                                          '(255 255 255 255))))
              (render-visible-segment after-start after-end +color-text+))
            (render-visible-segment visible-start visible-end +color-text+))
        (when (widget-focused widget)
          (let ((cursor-x (segment-x (entry-cursor widget))))
            (sdl3:set-render-draw-color renderer 0 0 0 255)
            (sdl3:render-line renderer
                              (float cursor-x 1.0)
                              (float (+ (widget-y widget) 2) 1.0)
                              (float cursor-x 1.0)
                              (float (- (+ (widget-y widget)
                                           (widget-height widget))
                                        2)
                                     1.0))))))))
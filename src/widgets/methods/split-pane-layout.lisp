;;;; ./src/widgets/methods/split-pane-layout.lisp

(in-package :mnas-sdl3-gui/widgets)

(defun split-pane-normalize-ratio (ratio)
  "Clamp split ratio to the inclusive range [0.0, 1.0]."
  (max 0.0 (min 1.0 ratio)))

(defmethod widget-min-size ((widget split-pane))
  (let* ((orientation (split-pane-orientation widget))
         (padding (split-pane-padding widget))
         (divider (max 0 (split-pane-divider-size widget)))
         (children-list (children widget))
         (first-child (first children-list))
         (second-child (second children-list))
         (first-min-w 0) (first-min-h 0)
         (second-min-w 0) (second-min-h 0))
    (when first-child
      (multiple-value-setq (first-min-w first-min-h)
        (widget-min-size first-child)))
    (when second-child
      (multiple-value-setq (second-min-w second-min-h)
        (widget-min-size second-child)))
    (let ((min-first (split-pane-min-first-pane widget))
          (min-second (split-pane-min-second-pane widget)))
      (if (eq orientation :vertical)
          (values (max 1 (+ (* 2 padding) (max first-min-w second-min-w)))
                  (max 1 (+ (* 2 padding)
                            (max min-first first-min-h)
                            (max min-second second-min-h)
                            divider)))
          (values (max 1 (+ (* 2 padding)
                            (max min-first first-min-w)
                            (max min-second second-min-w)
                            divider))
                  (max 1 (+ (* 2 padding) (max first-min-h second-min-h))))))))

(defmethod widget-arrange ((widget split-pane) x y width height)
  (place-widget widget :x x :y y :width width :height height)
  (let* ((orientation (split-pane-orientation widget))
         (ratio (split-pane-normalize-ratio (split-pane-ratio widget)))
         (padding (split-pane-padding widget))
         (divider (max 0 (split-pane-divider-size widget)))
         (inner-x (+ (<widget>-x widget) padding))
         (inner-y (+ (<widget>-y widget) padding))
         (inner-w (max 0 (- (<widget>-width widget) (* 2 padding) (if (eq orientation :horizontal) divider 0))))
         (inner-h (max 0 (- (<widget>-height widget) (* 2 padding) (if (eq orientation :vertical) divider 0))))
         (children-list (children widget))
         (first-child (first children-list))
         (second-child (second children-list))
        (min-first (split-pane-min-first-pane widget))
         (min-second (split-pane-min-second-pane widget)))
    (cond
      ((and (eq orientation :horizontal) first-child)
       (let* ((target-first (max 0 (round (* inner-w ratio))))
              (first-w (max min-first target-first))
              (second-w (max min-second (- inner-w first-w))))
         (when (< second-w min-second)
           (setf second-w min-second
                 first-w (max 1 (- inner-w second-w))))
         (setf first-w (max 1 first-w)
               second-w (max 1 second-w))
         (widget-arrange first-child 0 0 first-w inner-h)
        (when second-child
          (widget-arrange second-child
                          (+ first-w divider)
                          0
                          second-w
                          inner-h))))
      ((and (eq orientation :vertical) first-child)
       (let* ((target-first (max 0 (round (* inner-h ratio))))
              (first-h (max min-first target-first))
              (second-h (max min-second (- inner-h first-h))))
         (when (< second-h min-second)
           (setf second-h min-second
                 first-h (max 1 (- inner-h second-h))))
         (setf first-h (max 1 first-h)
               second-h (max 1 second-h))
         (widget-arrange first-child 0 0 inner-w first-h)
         (when second-child
           (widget-arrange second-child
                           0
                           (+ first-h divider)
                           inner-w
                           second-h))))
      (first-child
       (widget-arrange first-child 0 0 inner-w inner-h)))))

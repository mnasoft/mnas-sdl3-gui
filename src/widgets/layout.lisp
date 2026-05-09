;;;; ./src/widgets/layout.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Layout managers

(defparameter *pack-layout-options* (make-hash-table :test #'eq)
  "Mapping from widget object to pack options plist.")

(defun pack-widget (widget &key (side :top) (fill :none) (expand nil) (padx 0) (pady 0)
                                (use-content-size nil))
  "Register WIDGET for pack layout.
SIDE is one of :top, :bottom, :left, :right.
FILL is one of :none, :x, :y, :both.
EXPAND controls whether WIDGET can consume extra slot space along packing axis.
USE-CONTENT-SIZE makes PACK use only WIDGET-MIN-SIZE as preferred dimensions.
When PACK-LAYOUT-WIDGETS is applied, WIDGET X/Y are always computed by layout."
  (check-type side (member :top :bottom :left :right))
  (check-type fill (member :none :x :y :both))
  (setf (gethash widget *pack-layout-options*)
        (list :side side :fill fill :expand (not (null expand))
              :padx (max 0 padx) :pady (max 0 pady)
              :use-content-size (not (null use-content-size))))
  widget)

(defun unpack-widget (widget)
  "Remove WIDGET from pack layout."
  (remhash widget *pack-layout-options*)
  widget)

(defun clear-pack-layout ()
  "Remove all registered pack layout options."
  (clrhash *pack-layout-options*))

(defun place-widget (widget &key x y width height
                            relx rely relwidth relheight
                            (container-x 0) (container-y 0)
                            container-width container-height)
  "Apply absolute or relative placement to WIDGET.
Absolute coordinates use X/Y/WIDTH/HEIGHT.
Relative coordinates use RELX/RELY/RELWIDTH/RELHEIGHT in [0,1] against container size."
  (let* ((cw (or container-width (widget-width widget)))
         (ch (or container-height (widget-height widget)))
         (new-x (or x (and relx (+ container-x (round (* cw relx)))) (widget-x widget)))
         (new-y (or y (and rely (+ container-y (round (* ch rely)))) (widget-y widget)))
         (new-w (or width (and relwidth (round (* cw relwidth))) (widget-width widget)))
         (new-h (or height (and relheight (round (* ch relheight))) (widget-height widget))))
    (setf (widget-x widget) new-x
          (widget-y widget) new-y
          (widget-width widget) (max 1 new-w)
          (widget-height widget) (max 1 new-h))
    widget))

(defun axis-fill-p (fill axis)
  "Return true when FILL expands along AXIS (:x or :y)."
  (or (eq fill :both)
      (eq fill axis)))

(defun count-remaining-expand (widgets start-index axis)
  "Count remaining widgets from START-INDEX that expand along packing AXIS."
  (loop for idx from start-index below (length widgets)
        for widget = (nth idx widgets)
        for opts = (gethash widget *pack-layout-options*)
        for side = (getf opts :side)
        for expand = (getf opts :expand)
        count (and opts
                   expand
                   (if (eq axis :y)
                       (member side '(:top :bottom))
                       (member side '(:left :right))))))

(defun pack-layout-required-size (widgets)
  "Return minimal container width and height for packed WIDGETS.
Only widgets registered by PACK-WIDGET are included in the calculation."
  (let ((required-width 0)
        (required-height 0))
    (loop for widget in widgets
          for opts = (gethash widget *pack-layout-options*)
          do (when opts
               (let* ((side (getf opts :side :top))
                      (padx (getf opts :padx 0))
                      (pady (getf opts :pady 0))
                      (use-content-size (getf opts :use-content-size nil))
                      (min-w 1)
                      (min-h 1))
                 (multiple-value-setq (min-w min-h)
                   (widget-min-size widget))
                 (let* ((pref-w (if use-content-size min-w
                                    (max min-w (widget-width widget))))
                        (pref-h (if use-content-size min-h
                                    (max min-h (widget-height widget))))
                        (slot-w (+ pref-w (* 2 padx)))
                        (slot-h (+ pref-h (* 2 pady))))
                   (if (member side '(:top :bottom))
                       (progn
                         (setf required-width (max required-width slot-w))
                         (incf required-height slot-h))
                       (progn
                         (incf required-width slot-w)
                         (setf required-height (max required-height slot-h))))))))
    (values (max 1 required-width) (max 1 required-height))))

(defun pack-layout-widgets (widgets x y width height)
  "Lay out WIDGETS inside container rectangle by pack options.
Only widgets previously registered with PACK-WIDGET are repositioned."
  (let ((left x)
        (top y)
        (right (+ x width))
        (bottom (+ y height)))
    (loop for widget in widgets
          for idx from 0
          for opts = (gethash widget *pack-layout-options*)
          do (when opts
               (let* ((side (getf opts :side :top))
                      (fill (getf opts :fill :none))
                      (expand (getf opts :expand nil))
                      (padx (getf opts :padx 0))
                      (pady (getf opts :pady 0))
                      (use-content-size (getf opts :use-content-size nil))
                (min-w 1)
                (min-h 1)
                      (avail-w (max 0 (- right left)))
                      (avail-h (max 0 (- bottom top)))
                      (rem-expand-y (max 1 (count-remaining-expand widgets idx :y)))
                      (rem-expand-x (max 1 (count-remaining-expand widgets idx :x))))
              (multiple-value-setq (min-w min-h)
                (widget-min-size widget))
                 (cond
                   ((member side '(:top :bottom))
                    (let* ((pref-h (if use-content-size min-h
                                       (max (widget-height widget) min-h)))
                           (pref-w (if use-content-size min-w
                                       (max (widget-width widget) min-w)))
                  (slot-h (if expand
                        (max pref-h
                                            (floor avail-h rem-expand-y))
                        pref-h))
                           (slot-h (max 1 (min slot-h avail-h)))
                           (inner-w (max 1 (- avail-w (* 2 padx))))
                           (inner-h (max 1 (- slot-h (* 2 pady))))
                           (new-w (if (axis-fill-p fill :x)
                                      inner-w
                       (max 1 (min inner-w (max pref-w min-w)))))
                           (new-h (if (axis-fill-p fill :y)
                                      inner-h
                       (max 1 (min inner-h (max pref-h min-h)))))
                           (new-x (+ left padx (floor (- inner-w new-w) 2)))
                           (new-y (if (eq side :top)
                                      (+ top pady (floor (- inner-h new-h) 2))
                                      (+ (- bottom slot-h) pady (floor (- inner-h new-h) 2)))))
                      (setf (widget-x widget) new-x
                            (widget-y widget) new-y
                            (widget-width widget) new-w
                            (widget-height widget) new-h)
                      (if (eq side :top)
                          (incf top slot-h)
                          (decf bottom slot-h))))
                   ((member side '(:left :right))
                              (let* ((pref-w (if use-content-size min-w
                                  (max (widget-width widget) min-w)))
                                (pref-h (if use-content-size min-h
                                  (max (widget-height widget) min-h)))
                            (slot-w (if expand
                                  (max pref-w
                                            (floor avail-w rem-expand-x))
                                  pref-w))
                           (slot-w (max 1 (min slot-w avail-w)))
                           (inner-w (max 1 (- slot-w (* 2 padx))))
                           (inner-h (max 1 (- avail-h (* 2 pady))))
                           (new-w (if (axis-fill-p fill :x)
                                      inner-w
                                 (max 1 (min inner-w (max pref-w min-w)))))
                           (new-h (if (axis-fill-p fill :y)
                                      inner-h
                                 (max 1 (min inner-h (max pref-h min-h)))))
                           (new-x (if (eq side :left)
                                      (+ left padx (floor (- inner-w new-w) 2))
                                      (+ (- right slot-w) padx (floor (- inner-w new-w) 2))))
                           (new-y (+ top pady (floor (- inner-h new-h) 2))))
                      (setf (widget-x widget) new-x
                            (widget-y widget) new-y
                            (widget-width widget) new-w
                            (widget-height widget) new-h)
                      (if (eq side :left)
                          (incf left slot-w)
                          (decf right slot-w))))))))
    widgets))

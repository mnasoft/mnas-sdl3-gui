;;;; ./src/widgets/functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Shared widget helpers

(defvar *ttf-available-p* nil)
(defvar *ttf-font* nil)

(defparameter +layout-font-char-width+ 8)
(defparameter +layout-font-text-height+ 16)
(defparameter +list-box-scrollbar-width+ 12)

(defun widget-text-pixel-size (text)
  "Return TEXT width and height using SDL3_ttf metrics when available."
  (if (and (boundp '*ttf-available-p*)
           (boundp '*ttf-font*)
           *ttf-available-p*
           *ttf-font*)
      (handler-case
          (multiple-value-bind (w h)
              (sdl3-ttf:ttf-get-string-size *ttf-font* text)
            (values (or w 0) (or h +layout-font-text-height+)))
        (error ()
          (values (* (length text) +layout-font-char-width+)
                  +layout-font-text-height+)))
      (values (* (length text) +layout-font-char-width+)
              +layout-font-text-height+)))

(defun list-box-visible-item-count (widget)
  "Return how many list-box rows fit into WIDGET's current height."
  (max 1
       (floor (max 1 (- (widget-height widget) 4))
              (max 1 (list-box-item-height widget)))))

(defun list-box-max-scroll-offset (widget)
  "Return the largest valid first-visible row index for WIDGET."
  (max 0
       (- (length (list-box-items widget))
          (list-box-visible-item-count widget))))

(defun list-box-scrollbar-needed-p (widget)
  "Return true when WIDGET needs a vertical scrollbar."
  (> (length (list-box-items widget))
     (list-box-visible-item-count widget)))

(defun normalize-list-box-scroll-offset (widget)
  "Clamp WIDGET scroll offset to the visible item range."
  (setf (list-box-scroll-offset widget)
        (max 0
             (min (list-box-scroll-offset widget)
                  (list-box-max-scroll-offset widget)))))

(defun ensure-list-box-selection-visible (widget)
  "Adjust WIDGET scroll offset so the selected row remains visible."
  (let* ((item-count (length (list-box-items widget)))
         (visible-count (list-box-visible-item-count widget))
         (max-offset (list-box-max-scroll-offset widget))
         (selected-index (if (plusp item-count)
                             (max 0 (min (list-box-selected-index widget) (1- item-count)))
                             0))
         (scroll-offset (max 0 (min (list-box-scroll-offset widget) max-offset))))
    (cond
      ((< selected-index scroll-offset)
       (setf scroll-offset selected-index))
      ((>= selected-index (+ scroll-offset visible-count))
       (setf scroll-offset (1+ (- selected-index visible-count)))))
    (setf (list-box-selected-index widget) selected-index
          (list-box-scroll-offset widget) (max 0 (min scroll-offset max-offset)))))

(defun list-box-content-width (widget)
  "Return the drawable content width of WIDGET excluding scrollbar if present."
  (- (widget-width widget)
     (if (list-box-scrollbar-needed-p widget)
         +list-box-scrollbar-width+
         0)))

(defun list-box-scrollbar-geometry (widget)
  "Return scrollbar geometry for WIDGET.
Values are: needed-p, track-x, track-y, track-height, thumb-y, thumb-height, max-offset."
  (let ((needed-p (list-box-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (list-box-visible-item-count widget))
               (item-count (length (list-box-items widget)))
               (track-x (+ (widget-x widget) (list-box-content-width widget)))
               (track-y (1+ (widget-y widget)))
               (track-height (max 1 (- (widget-height widget) 2)))
               (max-offset (list-box-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count item-count)))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (list-box-scroll-offset widget) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun list-box-set-scroll-offset-from-thumb-top (widget thumb-top)
  "Update WIDGET scroll offset from scrollbar thumb top position."
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (list-box-scrollbar-geometry widget)
    (declare (ignore track-x thumb-y))
    (when needed-p
      (let* ((thumb-travel (max 1 (- track-height thumb-height)))
             (clamped-thumb-top (max track-y
                                     (min thumb-top
                      (+ track-y thumb-travel))))
             (relative-top (- clamped-thumb-top track-y)))
        (setf (list-box-scroll-offset widget)
              (if (zerop max-offset)
                  0
                  (round (* max-offset (/ relative-top thumb-travel))))))
      (normalize-list-box-scroll-offset widget))))

(defun list-box-scroll-by (widget delta)
  "Scroll WIDGET by DELTA rows. Returns true when offset changed." 
  (let ((old-offset (list-box-scroll-offset widget)))
    (setf (list-box-scroll-offset widget)
          (+ old-offset delta))
    (normalize-list-box-scroll-offset widget)
    (/= old-offset (list-box-scroll-offset widget))))
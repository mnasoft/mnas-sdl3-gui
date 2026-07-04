;;;; ./src/widgets/combo-box-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Compatibility helpers for list-box items operate directly on the
;; inherited children container state.
(defun normalize-list-box-item (item)
  "Convert ITEM into a <list-box-item> object when needed."
  (cond
    ((typep item '<list-box-item>) item)
    ((typep item '<widget>) item)
    (t (make-instance '<list-box-item> :text (format nil "~a" item)))))

(defun normalize-list-box-items (items)
  "Normalize a list of list-box items into <list-box-item> objects."
  (mapcar #'normalize-list-box-item items))

(defun list-box-item-display-value (item)
  "Return a compatibility-friendly value for ITEM.
For <list-box-item> instances this exposes the item text; other widget values
remain intact so existing callers can still work with strings or widgets."
  (if (typep item '<list-box-item>)
      (<list-box-item>-text item)
      item))

(defun list-box-items (widget)
  "Return items list for LIST-BOX or combo-box via its popup."
  (cond
    ((typep widget '<combo-box>)
     (let ((popup (<combo-box>-popup-widget widget)))
       (when popup (list-box-items popup))))
    ((typep widget '<widget-container>)
     (mapcar #'list-box-item-display-value (<widget-container>-children widget)))
    (t nil)))

(defun (setf list-box-items) (new-value widget)
  "Set items list for LIST-BOX or combo-box via its popup."
  (cond
    ((typep widget '<combo-box>)
     (let ((popup (<combo-box>-popup-widget widget)))
       (when popup (setf (list-box-items popup) new-value))))
    ((typep widget '<widget-container>)
     (setf (<widget-container>-children widget) (normalize-list-box-items new-value)))
    (t nil))
  new-value)

(defgeneric item-height (widget)
  (:documentation "Return per-item height for LIST-BOX or combo-box via its popup."))

(defgeneric scrollbar-dragging-p (widget)
  (:documentation "Return scrollbar dragging flag for LIST-BOX or combo-box via its popup."))

(defgeneric scrollbar-drag-offset (widget)
  (:documentation "Return scrollbar drag offset for LIST-BOX or combo-box via its popup."))

(defmethod selected-index ((w <list-box>))
  (slot-value w 'selected-index))

(defmethod item-height ((w <list-box>))
  (slot-value w 'item-height))

(defmethod (setf item-height) (new-value (w <list-box>))
  (setf (slot-value w 'item-height) new-value)
  new-value)

(defmethod scrollbar-dragging-p ((w <list-box>))
  (slot-value w 'scrollbar-dragging-p))

(defmethod scrollbar-drag-offset ((w <list-box>))
  (slot-value w 'scrollbar-drag-offset))

(defmethod selected-index ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (if p (selected-index p) 0)))

(defmethod (setf selected-index) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (selected-index p) new-value)))
  new-value)

(defmethod scroll-offset ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (if p (scroll-offset p) 0)))

(defmethod (setf scroll-offset) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (scroll-offset p) new-value)))
  new-value)

(defmethod item-height ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (if p (item-height p) 24)))

(defmethod (setf item-height) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (item-height p) new-value)))
  new-value)

(defmethod scrollbar-dragging-p ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (if p (scrollbar-dragging-p p) nil)))

(defmethod (setf scrollbar-dragging-p) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (scrollbar-dragging-p p) new-value)))
  new-value)

(defmethod scrollbar-drag-offset ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (if p (scrollbar-drag-offset p) 0)))

(defmethod (setf scrollbar-drag-offset) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (scrollbar-drag-offset p) new-value)))
  new-value)


(defmethod selected-index ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (selected-index p))))

(defmethod scrollbar-dragging-p ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (scrollbar-dragging-p p))))


(defmethod scrollbar-drag-offset ((w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (scrollbar-drag-offset p))))

    ;; Setf generics and methods -------------------------------------------------

(defgeneric (setf selected-index) (new-value widget)
  (:documentation "Set selected index for LIST-BOX or combo-box via its popup."))

(defgeneric (setf scrollbar-dragging-p) (new-value widget)
  (:documentation "Set scrollbar dragging flag for LIST-BOX or combo-box via its popup."))

(defgeneric (setf scrollbar-drag-offset) (new-value widget)
  (:documentation "Set scrollbar drag offset for LIST-BOX or combo-box via its popup."))

(defmethod (setf selected-index) (new-value (w <list-box>))
  (setf (slot-value w 'selected-index) new-value)
  new-value)

(defmethod (setf scrollbar-dragging-p) (new-value (w <list-box>))
  (setf (slot-value w 'scrollbar-dragging-p) new-value)
  new-value)

(defmethod (setf scrollbar-drag-offset) (new-value (w <list-box>))
  (setf (slot-value w 'scrollbar-drag-offset) new-value)
  new-value)

;; Forwarding setf methods for combo-box that delegate to popup widget.
(defmethod (setf selected-index) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (selected-index p) new-value))
    new-value))

(defmethod (setf scrollbar-dragging-p) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (scrollbar-dragging-p p) new-value))
    new-value))

(defmethod (setf scrollbar-drag-offset) (new-value (w <combo-box>))
  (let ((p (<combo-box>-popup-widget w)))
    (when p (setf (scrollbar-drag-offset p) new-value))
    new-value))

(defun combo-box-selected-item (widget)
  "Return currently selected item of combo-box WIDGET, or NIL when unavailable."
  (let* ((popup (<combo-box>-popup-widget widget))
         (items (and popup (list-box-items popup)))
         (index (and popup (selected-index popup))))
    (when (and items (<= 0 index) (< index (length items)))
      (nth index items))))

(defmethod <combo-box>-popup-widget ((widget <combo-box-popup>))
  widget)

(defmethod <combo-box>-header-widget ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (and (typep owner '<combo-box>)
         (<combo-box>-header-widget owner))))

(defmethod <combo-box>-main-height ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'main-height))
        (<combo-box>-main-height owner)
        30)))

(defmethod (setf <combo-box>-main-height) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'main-height))
        (setf (<combo-box>-main-height owner) new-value)
        (setf (slot-value widget 'main-height) new-value)))
  new-value)

(defmethod <combo-box>-expanded-p ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'expanded-p))
        (<combo-box>-expanded-p owner)
        nil)))

(defmethod (setf <combo-box>-expanded-p) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'expanded-p))
        (setf (<combo-box>-expanded-p owner) new-value)
        (setf (slot-value widget 'expanded-p) new-value)))
  new-value)

(defmethod <combo-box>-max-visible-items ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'max-visible-items))
        (<combo-box>-max-visible-items owner)
        6)))

(defmethod (setf <combo-box>-max-visible-items) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'max-visible-items))
        (setf (<combo-box>-max-visible-items owner) new-value)
        (setf (slot-value widget 'max-visible-items) new-value)))
  new-value)

(defmethod <combo-box>-ignore-next-popup-mouse-down-p ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (<combo-box>-ignore-next-popup-mouse-down-p owner)
        nil)))

(defmethod (setf <combo-box>-ignore-next-popup-mouse-down-p) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (setf (<combo-box>-ignore-next-popup-mouse-down-p owner) new-value)
        (setf (slot-value widget 'ignore-next-popup-mouse-down-p) new-value)))
  new-value)

(defmethod <combo-box>-ignore-next-popup-mouse-down-p ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (<combo-box>-ignore-next-popup-mouse-down-p owner)
        nil)))

(defmethod (setf <combo-box>-ignore-next-popup-mouse-down-p) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (if (and (typep owner '<combo-box>)
             (slot-boundp owner 'ignore-next-popup-mouse-down-p))
        (setf (<combo-box>-ignore-next-popup-mouse-down-p owner) new-value)
        (setf (slot-value widget 'ignore-next-popup-mouse-down-p) new-value)))
  new-value)

(defgeneric <combo-box-popup>-host-window (widget))
(defgeneric (setf <combo-box-popup>-host-window) (new-value widget))

(defgeneric <combo-box-popup>-y (widget))
(defgeneric <combo-box-popup>-width (widget))
(defgeneric <combo-box-popup>-height (widget))
(defgeneric <combo-box-popup>-renderer (widget))
(defgeneric <combo-box-popup>-visible-p (widget))
(defgeneric <combo-box-popup>-scrollbar-geometry (widget popup-x popup-y)
  (:documentation "Return popup scrollbar geometry for WIDGET at POPUP-X/POPUP-Y."))
(defgeneric <combo-box-popup>-set-scroll-offset-from-thumb-top (widget popup-x popup-y thumb-top)
  (:documentation "Update popup scroll offset from a scrollbar thumb drag for WIDGET."))

(defmethod <combo-box-popup>-host-window ((widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (and owner (<widget>-window owner))))

(defmethod (setf <combo-box-popup>-host-window) (new-value (widget <combo-box-popup>))
  (let ((owner (<widget>-owner widget)))
    (when owner
      (setf (<widget>-window owner) new-value)))
  new-value)

(defmethod <combo-box-popup>-host-window ((widget <combo-box>))
  (let ((popup (<combo-box>-popup-widget widget)))
    (and popup (<combo-box-popup>-host-window popup))))

(defmethod (setf <combo-box-popup>-host-window) (new-value (widget <combo-box>))
  (let ((popup (<combo-box>-popup-widget widget)))
    (if popup
        (setf (<combo-box-popup>-host-window popup) new-value)
        (setf (<widget>-window widget) new-value)))
  new-value)

(defmethod <combo-box-popup>-y ((widget <combo-box-popup>))
  (<widget>-y widget))

(defmethod <combo-box-popup>-width ((widget <combo-box-popup>))
  (<widget>-width widget))

(defmethod <combo-box-popup>-height ((widget <combo-box-popup>))
  (<widget>-height widget))

(defmethod <combo-box-popup>-renderer ((widget <combo-box-popup>))
  (slot-value widget 'renderer))

(defmethod <combo-box-popup>-visible-p ((widget <combo-box-popup>))
  (<widget>-visible widget))

(defmethod (setf <combo-box-popup>-visible-p) (new-value (widget <combo-box-popup>))
  (setf (<widget>-visible widget) new-value)
  new-value)

(defmethod <combo-box-popup>-y ((widget <combo-box>))
  (combo-box-popup-y widget))

(defmethod <combo-box-popup>-width ((widget <combo-box>))
  (<widget>-width widget))

(defmethod <combo-box-popup>-height ((widget <combo-box>))
  (combo-box-popup-height widget))

(defmethod <combo-box-popup>-renderer ((widget <combo-box>))
  (let ((popup (<combo-box>-popup-widget widget)))
    (and popup (<combo-box-popup>-renderer popup))))

(defmethod <combo-box-popup>-visible-p ((widget <combo-box>))
  (let ((popup (<combo-box>-popup-widget widget)))
    (and popup (<combo-box-popup>-visible-p popup))))

(defmethod <combo-box-popup>-scrollbar-geometry ((widget <combo-box-popup>) popup-x popup-y)
  (combo-box-popup-scrollbar-geometry widget popup-x popup-y))

(defmethod <combo-box-popup>-scrollbar-geometry ((widget <combo-box>) popup-x popup-y)
  (combo-box-popup-scrollbar-geometry widget popup-x popup-y))

(defmethod <combo-box-popup>-set-scroll-offset-from-thumb-top ((widget <combo-box-popup>) popup-x popup-y thumb-top)
  (combo-box-popup-set-scroll-offset-from-thumb-top widget popup-x popup-y thumb-top))

(defmethod <combo-box-popup>-set-scroll-offset-from-thumb-top ((widget <combo-box>) popup-x popup-y thumb-top)
  (combo-box-popup-set-scroll-offset-from-thumb-top widget popup-x popup-y thumb-top))

(defun combo-box-popup-host-window (widget)
  "Compatibility accessor: return host SDL window for combo-box WIDGET.
  In the new model popups use their own window; the host is the widget's window."
  (let ((popup (<combo-box>-popup-widget widget)))
    (or (and popup (<combo-box-popup>-host-window popup))
        (<widget>-window widget))))

(defun (setf combo-box-popup-host-window) (new-value widget)
  "Compatibility setter for legacy popup-host-window initargs and callers."
  (let ((popup (<combo-box>-popup-widget widget)))
    (when popup
      (setf (<combo-box-popup>-host-window popup) new-value))
    (when (and (null popup) (typep widget '<combo-box>))
      (setf (<widget>-window widget) new-value)))
  new-value)

(defun combo-box-popup-mode (widget)
    "Compatibility accessor: popup mode is always :window in the new model." 
    :window)

(defun combo-box-find-item-index (widget item)
  "Return index of ITEM in combo-box WIDGET items, or NIL if missing."
  (let ((popup (<combo-box>-popup-widget widget)))
    (when popup
      (position item (list-box-items popup) :test #'equal))))

(defun combo-box-add-item (widget item &key (select t))
  "Add ITEM to combo-box WIDGET items, optionally selecting it.
If ITEM already exists, it becomes selected instead of duplicated." 
  (let* ((popup (<combo-box>-popup-widget widget))
         (items (and popup (list-box-items popup)))
         (index (combo-box-find-item-index widget item)))
    (when popup
      (if index
          (when select
            (setf (selected-index popup) index))
          (progn
            (setf (list-box-items popup) (append items (list item))
                  (selected-index popup) (1- (length (list-box-items popup))))))))
    (when select
      (update-<widget>-value widget item))
  widget)

(defun combo-box-total-height (widget)
  "Return total reserved height of combo-box WIDGET including popup when expanded."
  (+ (<combo-box>-main-height widget)
     (if (and (<combo-box>-expanded-p widget)
              (not (<combo-box-popup>-window-enabled-p widget)))
         (combo-box-popup-height widget)
         0)))

(defun <combo-box-popup>-window-enabled-p (widget)
  "Return true when WIDGET uses a separate popup window for the drop-down.
The popup is considered enabled when the combo-box has a host window, the
popup widget already owns a popup window, or the popup widget already has a
non-zero window id/renderer from a previous creation step."
  (and (typep widget '<combo-box>)
       (let* ((popup (<combo-box>-popup-widget widget))
              (host (<widget>-window widget))
              (popup-window (and popup (<widget>-window popup)))
              (popup-window-id (and popup (<combo-box-popup>-window-id popup)))
              (popup-renderer (and popup (<combo-box-popup>-renderer popup))))
         (and popup
              (or (and host
                       (not (and (numberp host) (zerop host)))
                       (not (and (typep host 'cffi:foreign-pointer)
                                 (cffi:null-pointer-p host))))
                  (and popup-window
                       (not (and (numberp popup-window) (zerop popup-window)))
                       (not (and (typep popup-window 'cffi:foreign-pointer)
                                 (cffi:null-pointer-p popup-window))))
                  (and (numberp popup-window-id) (plusp popup-window-id))
                  (and popup-renderer (not (cffi:null-pointer-p popup-renderer))))))))

(defun sync-combo-box-expanded-state (widget expanded-p)
  "Synchronize combo-box expansion state and reserved widget height."
  (let ((main-height (if (<combo-box>-expanded-p widget)
                         (<combo-box>-main-height widget)
                         (<widget>-height widget))))
    (setf (<combo-box>-main-height widget) (max 1 main-height)
          (<combo-box>-expanded-p widget) expanded-p
          (<widget>-height widget)
          (if (and expanded-p
                   (not (<combo-box-popup>-window-enabled-p widget)))
              (+ (<combo-box>-main-height widget)
                 (combo-box-popup-height widget))
              (<combo-box>-main-height widget))))
  (format t "[combo-box] sync expanded=~A enabled=~A host=~S~%"
          expanded-p
          (<combo-box-popup>-window-enabled-p widget)
          (combo-box-popup-host-window widget))
  (when (<combo-box-popup>-window-enabled-p widget)
    (if expanded-p
        (progn
          (format t "[combo-box] calling show-popup~%")
          (finish-output)
          (combo-box-show-popup-window widget))
        (progn
          (format t "[combo-box] calling hide-popup~%")
          (finish-output)
          (combo-box-hide-popup-window widget))))
  ;; Call optional demo hook to allow creating transient popup surfaces/windows.
  (when *combo-box-expanded-callback*
    (handler-case
        (funcall *combo-box-expanded-callback* widget expanded-p)
      (error (e)
        (format t "Error in *combo-box-expanded-callback*: ~A~%" e))))
  widget)

(defun combo-box-visible-item-count (widget)
  "Return visible row count for combo-box popup of WIDGET."
  (let ((popup (<combo-box>-popup-widget widget)))
    (max 1
      (min (<combo-box>-max-visible-items widget)
        (max 1 (length (list-box-items popup)))))))

(defun combo-box-max-scroll-offset (widget)
  "Return maximum valid popup scroll offset for combo-box WIDGET."
  (let ((popup (<combo-box>-popup-widget widget)))
    (max 0
         (- (length (list-box-items popup))
            (combo-box-visible-item-count widget)))))

(defun combo-box-scrollbar-needed-p (widget)
  "Return true when combo-box popup requires a scrollbar." 
  (let ((popup (<combo-box>-popup-widget widget)))
    (> (length (list-box-items popup))
       (combo-box-visible-item-count widget))))

(defun normalize-combo-box-scroll-offset (widget)
  "Clamp combo-box popup scroll offset for WIDGET." 
  (let ((popup (<combo-box>-popup-widget widget)))
    (setf (scroll-offset popup)
    (max 0
      (min (scroll-offset popup)
        (combo-box-max-scroll-offset widget))))))

(defun ensure-combo-box-selection-visible (widget)
  "Adjust popup scroll of WIDGET so selected row stays visible." 
  (let* ((popup (<combo-box>-popup-widget widget))
         (item-count (length (list-box-items popup)))
         (visible-count (combo-box-visible-item-count widget))
         (max-offset (combo-box-max-scroll-offset widget))
         (selected-index (if (plusp item-count)
                             (max 0 (min (selected-index popup) (1- item-count)))
                             0))
         (scroll-offset (max 0 (min (scroll-offset popup) max-offset))))
    (cond
      ((< selected-index scroll-offset)
       (setf scroll-offset selected-index))
      ((>= selected-index (+ scroll-offset visible-count))
       (setf scroll-offset (1+ (- selected-index visible-count)))))
    (setf (selected-index popup) selected-index
          (scroll-offset popup) (max 0 (min scroll-offset max-offset)))))

(defun combo-box-popup-y (widget)
  "Return popup top Y coordinate for combo-box WIDGET." 
  (+ (<widget>-y widget) (<combo-box>-main-height widget)))

(defun combo-box-popup-height (widget)
  "Return popup height for combo-box WIDGET." 
  (let ((popup (<combo-box>-popup-widget widget)))
    (+ 2 (* (combo-box-visible-item-count widget)
            (item-height popup)))))

(defun combo-box-content-width (widget)
  "Return popup content width excluding scrollbar when present." 
  (- (<widget>-width widget)
     (if (combo-box-scrollbar-needed-p widget)
         +list-box-scrollbar-width+
         0)))

(defun combo-box-scrollbar-geometry (widget)
  "Return popup scrollbar geometry for WIDGET.
Values are: needed-p, track-x, track-y, track-height, thumb-y, thumb-height, max-offset." 
  (let ((needed-p (combo-box-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (combo-box-visible-item-count widget))
               (popup (<combo-box>-popup-widget widget))
               (item-count (length (list-box-items popup)))
               (track-x (+ (<widget>-x widget) (combo-box-content-width widget)))
               (track-y (1+ (combo-box-popup-y widget)))
               (track-height (max 1 (- (combo-box-popup-height widget) 2)))
               (max-offset (combo-box-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count item-count)))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (scroll-offset popup) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun combo-box-popup-scrollbar-geometry (widget popup-x popup-y)
  "Return popup scrollbar geometry for WIDGET with popup at POPUP-X/POPUP-Y." 
  (let ((needed-p (combo-box-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (combo-box-visible-item-count widget))
               (popup (<combo-box>-popup-widget widget))
               (item-count (length (list-box-items popup)))
               (track-x (+ popup-x (combo-box-content-width widget)))
               (track-y (1+ popup-y))
               (track-height (max 1 (- (combo-box-popup-height widget) 2)))
               (max-offset (combo-box-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count item-count)))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (scroll-offset popup) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun combo-box-set-scroll-offset-from-thumb-top (widget thumb-top)
  "Update popup scroll offset of combo-box WIDGET from scrollbar thumb top." 
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (combo-box-scrollbar-geometry widget)
    (declare (ignore track-x thumb-y))
    (when needed-p
      (let* ((popup (<combo-box>-popup-widget widget))
             (thumb-travel (max 1 (- track-height thumb-height)))
             (clamped-thumb-top (max track-y
                                     (min thumb-top
                                          (+ track-y thumb-travel))))
             (relative-top (- clamped-thumb-top track-y)))
        (setf (scroll-offset popup)
              (if (zerop max-offset)
                  0
                  (round (* max-offset (/ relative-top thumb-travel)))))
        (normalize-combo-box-scroll-offset widget)))))

(defun combo-box-popup-set-scroll-offset-from-thumb-top (widget popup-x popup-y thumb-top)
  "Update popup scroll offset using POPUP-X/POPUP-Y geometry and THUMB-TOP."
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (combo-box-popup-scrollbar-geometry widget popup-x popup-y)
    (declare (ignore track-x thumb-y))
    (when needed-p
      (let* ((popup (<combo-box>-popup-widget widget))
             (thumb-travel (max 1 (- track-height thumb-height)))
             (clamped-thumb-top (max track-y
                                     (min thumb-top
                                          (+ track-y thumb-travel))))
             (relative-top (- clamped-thumb-top track-y)))
        (setf (scroll-offset popup)
              (if (zerop max-offset)
                  0
                  (round (* max-offset (/ relative-top thumb-travel)))))
        (normalize-combo-box-scroll-offset widget)))
    widget))

(defun combo-box-ensure-popup-window (widget)
  "Ensure popup window/renderer exist for WIDGET. Returns popup window or NIL."
  (let* ((popup (or (<combo-box>-popup-widget widget)
                    (let ((p (make-instance '<combo-box-popup> :owner widget)))
                      (setf (<combo-box>-popup-widget widget) p)
                      p)))
         (host-window (or (<combo-box-popup>-host-window widget)
                          (<widget>-window widget)
                          (<widget>-window popup))))
    (cond
      ((and popup (<widget>-window popup))
       (<widget>-window popup))
      ((and (<combo-box-popup>-window-enabled-p widget)
            host-window)
       (format t "[combo-box] ensure-popup host=~S size=~Dx~D~%"
               host-window
               (<widget>-width widget)
               (<combo-box-popup>-height widget))
       (finish-output)
       (let* ((popup-window (sdl3:create-popup-window
                             host-window
                             0
                             0
                             (<widget>-width widget)
                             (<combo-box-popup>-height widget)
                             :popup-menu)))
         (when (or (null popup-window) (cffi:null-pointer-p popup-window))
           (format t "Failed to create combo-box popup window: ~A~%" (sdl3:get-error))
           (return-from combo-box-ensure-popup-window nil))
         (let ((popup-renderer (sdl3:create-renderer popup-window "")))
           (when (or (null popup-renderer) (cffi:null-pointer-p popup-renderer))
             (format t "Failed to create combo-box popup renderer: ~A~%" (sdl3:get-error))
             (return-from combo-box-ensure-popup-window nil))
           (setf (<widget>-window popup) popup-window
                 (<combo-box-popup>-renderer popup) popup-renderer
                 (<combo-box-popup>-window-id popup) (sdl3:get-window-id popup-window))
           ;; Register mapping from the SDL popup window id to this widget so
           ;; event dispatchers can quickly find the widgets associated with
           ;; transient popup windows.
           (when (and (<combo-box-popup>-window-id popup)
                      (numberp (<combo-box-popup>-window-id popup))
                      (> (<combo-box-popup>-window-id popup) 0))
             (register-widget-for-window-id (<combo-box-popup>-window-id popup) widget))
           (format t "[combo-box] popup created id=~S renderer=~S~%"
                   (<combo-box-popup>-window-id popup)
                   popup-renderer)
           (finish-output)
           (when (<combo-box-popup>-layer-manager popup)
             (mnas-sdl3-gui/window-manager:register-window
              (<combo-box-popup>-layer-manager popup)
              (<combo-box-popup>-window-id popup)
              :dropdown-host
              :parent-id (sdl3:get-window-id host-window)
              :open-p nil))
           (<widget>-window popup)))))))

(defun combo-box-show-popup-window (widget)
  "Show popup window for WIDGET if popup mode is enabled."
  (let* ((popup (<combo-box>-popup-widget widget))
         (host-window (or (<combo-box-popup>-host-window widget)
                          (<widget>-window widget)
                          (and popup (<widget>-window popup)))))
    (when (typep widget '<combo-box>)
      (setf (<combo-box>-ignore-next-popup-mouse-down-p widget) t))
    (format t "[combo-box] show-popup enter host=~S popup=~S~%"
            host-window
            (and popup (<widget>-window popup)))
    (finish-output)
    (when (combo-box-ensure-popup-window widget)
      (multiple-value-bind (ok wx wy)
          (sdl3:get-window-position host-window)
        (let ((global-x (if ok (+ wx (<widget>-x widget)) (<widget>-x widget)))
              (global-y (if ok (+ wy (<widget>-y widget) (<combo-box>-main-height widget))
                            (+ (<widget>-y widget) (<combo-box>-main-height widget)))))
          (format t "[combo-box] show-popup ok=~A host=~S popup-id=~S pos=(~D,~D) expanded=~A~%"
                  ok
                  (<combo-box-popup>-host-window widget)
                  (and popup (<combo-box-popup>-window-id popup))
                  global-x global-y
                  (<combo-box>-expanded-p widget))
          (finish-output)
          (when popup
            (sdl3:set-window-position (<widget>-window popup) global-x global-y)
            (sdl3:show-window (<widget>-window popup))
            (sdl3:raise-window (<widget>-window popup))
            (setf (<combo-box-popup>-visible-p popup) t)
            (when (<combo-box-popup>-renderer popup)
              (render (<combo-box-popup>-renderer popup) popup *widget-style*)
              (sdl3:render-present (<combo-box-popup>-renderer popup)))
            (when (<combo-box-popup>-layer-manager popup)
              (mnas-sdl3-gui/window-manager:open-dropdown-host
               (<combo-box-popup>-layer-manager popup)
               (<combo-box-popup>-window-id popup)
               (sdl3:get-window-id (<combo-box-popup>-host-window widget))))
            (setf (<combo-box>-ignore-next-popup-mouse-down-p widget) t))))
      (let ((popup (<combo-box>-popup-widget widget)))
        (and popup (<combo-box-popup>-visible-p popup))))))

(defun combo-box-hide-popup-window (widget)
  "Hide popup window for WIDGET if present."
  (let ((popup (<combo-box>-popup-widget widget)))
    (when popup
      (setf (<combo-box-popup>-visible-p popup) nil
            (<combo-box>-ignore-next-popup-mouse-down-p widget) nil)
      (when (<widget>-window popup)
        (ignore-errors (sdl3:hide-window (<widget>-window popup))))
      (when (<combo-box-popup>-layer-manager popup)
        (mnas-sdl3-gui/window-manager:close-window
         (<combo-box-popup>-layer-manager popup)
         (<combo-box-popup>-window-id popup)
         :close-children t))))
  nil)

(defun combo-box-enable-popup-window (widget host-window &key layer-manager)
  "Enable popup window mode for WIDGET using HOST-WINDOW." 
  (let ((popup (or (<combo-box>-popup-widget widget)
                   (let ((p (make-instance '<combo-box-popup> :owner widget)))
                     (setf (<combo-box>-popup-widget widget) p)
                     p))))
    (setf (combo-box-popup-host-window widget) host-window
          (<combo-box-popup>-layer-manager popup) layer-manager)
    (combo-box-ensure-popup-window widget)
    widget))

(defun combo-box-disable-popup-window (widget)
  "Disable popup window mode and destroy popup resources for WIDGET." 
  (combo-box-hide-popup-window widget)
  ;; Capture popup window id before destroying resources so we can remove
  ;; the mapping from window id -> widget.
  (let ((popup (<combo-box>-popup-widget widget))
        (old-id nil))
    (when popup
      (setf old-id (<combo-box-popup>-window-id popup))
      (when (<combo-box-popup>-renderer popup)
        (sdl3:destroy-renderer (<combo-box-popup>-renderer popup)))
      (when (<widget>-window popup)
        (destroy-window-and-unregister (<widget>-window popup)
                                       :layer-manager (<combo-box-popup>-layer-manager popup))))
    (when popup
      (setf (<widget>-window popup) nil
            (<combo-box-popup>-renderer popup) nil
            (<combo-box-popup>-window-id popup) 0
            (<combo-box-popup>-layer-manager popup) nil
            (<combo-box-popup>-visible-p popup) nil))
    widget))

(defun combo-box-handle-popup-mouse-down (widget x y)
  "Handle mouse-down inside popup window for WIDGET with local X/Y coords." 
  (when (and (<combo-box>-ignore-next-popup-mouse-down-p widget)
             (typep widget '<combo-box>))
    (setf (<combo-box>-ignore-next-popup-mouse-down-p widget) nil)
    (return-from combo-box-handle-popup-mouse-down t))
  (normalize-combo-box-scroll-offset widget)
  (let* ((popup (<combo-box>-popup-widget widget))
         (item-height (and popup (item-height popup)))
         (visible-count (combo-box-visible-item-count widget))
         (scrollbar-needed-p (combo-box-scrollbar-needed-p widget))
         (content-width (combo-box-content-width widget))
         (rel-x x)
         (rel-y y))
    (format t "[combo-box] popup-mouse-down x=~A y=~A rel-x=~A rel-y=~A popup-id=~S item-height=~A~%"
            x y rel-x rel-y (and popup (<combo-box-popup>-window-id popup)) item-height)
    (finish-output)
    (cond
      ((and scrollbar-needed-p (>= rel-x content-width))
       (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
           (<combo-box-popup>-scrollbar-geometry widget 0 0)
         (declare (ignore needed-p track-x track-height max-offset))
         (let ((thumb-hit-p (<= thumb-y y (+ thumb-y thumb-height))))
           (when popup
             (setf (scrollbar-dragging-p popup) t
                   (scrollbar-drag-offset popup)
                   (if thumb-hit-p
                       (- y thumb-y)
                       (floor thumb-height 2)))
             (<combo-box-popup>-set-scroll-offset-from-thumb-top widget 0 0
                                                               (- y (scrollbar-drag-offset popup)))))))
      ((>= rel-y 0)
       (when popup (setf (scrollbar-dragging-p popup) nil))
       (let* ((row (floor rel-y item-height))
              (new-index (+ (and popup (scroll-offset popup)) row)))
         (format t "[combo-box] compute row=~A new-index=~A visible-count=~A items=~A~%"
                 row new-index visible-count (and popup (length (list-box-items popup))))
         (finish-output)
         (when (and popup (< row visible-count)
                    (< new-index (length (list-box-items popup))))
           (setf (selected-index popup) new-index)
           (when (typep widget '<editable-combo-box>)
             (setf (<entry>-text widget) (format nil "~a" (nth new-index (list-box-items popup)))
                   (<entry>-cursor widget) (length (<entry>-text widget)))
             (<entry>-scroll-to-start widget))
           (sync-combo-box-expanded-state widget nil)
           (update-<widget>-value widget
                                  (nth new-index (list-box-items popup))))))
      (t
       (when popup (setf (scrollbar-dragging-p popup) nil))
       (sync-combo-box-expanded-state widget nil)))
    t))

(defun combo-box-handle-popup-mouse-up (widget x y)
  "Handle mouse-up inside popup window for WIDGET." 
  (declare (ignore x y))
  (let ((popup (<combo-box>-popup-widget widget))
        (dragging-p nil))
    (when popup
      (setf dragging-p (scrollbar-dragging-p popup))
      (setf (scrollbar-dragging-p popup) nil
            (scrollbar-drag-offset popup) 0))
    dragging-p))

(defun combo-box-handle-popup-mouse-motion (widget x y)
  "Handle mouse-motion inside popup window for WIDGET." 
  (let ((popup (<combo-box>-popup-widget widget)))
    (when (and popup (scrollbar-dragging-p popup))
      (<combo-box-popup>-set-scroll-offset-from-thumb-top
       widget 0 0
       (- y (scrollbar-drag-offset popup)))
      t)))

(defun combo-box-handle-popup-mouse-wheel (widget dy)
  "Handle mouse-wheel inside popup window for WIDGET." 
  (when (not (zerop dy))
    (let ((ev (sdl3:mouse-wheel-event :%yrel dy :%y dy :%x 0)))
      (handle-mouse-wheel-event widget ev))))

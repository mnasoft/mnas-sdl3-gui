;;;; ./src/widgets/functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Shared widget helpers

(defvar *ttf-available-p* nil)
(defvar *ttf-font* nil)

(defparameter +layout-font-char-width+ 8)
(defparameter +layout-font-text-height+ 16)
(defparameter +list-box-scrollbar-width+ 12)

(defun make-tree-node (&key id text kind path children children-loaded-p
                            modified-time expanded-p data)
  "Create a TREE-NODE instance." 
  (make-instance 'tree-node
                 :id id
                 :text (or text "")
                 :kind (or kind :item)
                 :path path
                 :children (or children nil)
                 :children-loaded-p children-loaded-p
                 :modified-time modified-time
                 :expanded-p expanded-p
                 :data data))

(defun tree-node-directory-p (node)
  "Return true when NODE represents a directory." 
  (and node (eq (tree-node-kind node) :directory)))

(defun tree-node-file-p (node)
  "Return true when NODE represents a file." 
  (and node (eq (tree-node-kind node) :file)))

(defun %filesystem-file-extension (path)
  "Return lowercase file extension for PATH without leading dot." 
  (let* ((name (%filesystem-entry-name path))
         (dot-pos (position #\. name :from-end t)))
    (if (and dot-pos (> dot-pos 0) (< dot-pos (1- (length name))))
        (string-downcase (subseq name (1+ dot-pos)))
        "")))

(defun tree-view-normalize-extensions (extensions)
  "Normalize EXTENSIONS to lowercase strings without leading dot." 
  (remove-duplicates
   (loop for ext in (or extensions nil)
         for raw = (string-downcase (string-trim '(#\Space #\Tab #\.)
                                                  (format nil "~A" ext)))
         unless (zerop (length raw))
           collect raw)
   :test #'string=))

(defun %filesystem-path-write-date (path)
  "Return write timestamp for PATH, or NIL on errors." 
  (handler-case
      (file-write-date path)
    (error () nil)))

(defun %tree-node-sort< (left right sort-mode)
  "Return true when LEFT must be ordered before RIGHT for SORT-MODE." 
  (let ((left-directory (tree-node-directory-p left))
        (right-directory (tree-node-directory-p right)))
    (cond
      ((not (eq left-directory right-directory))
       left-directory)
      ((eq sort-mode :date)
       (let ((left-time (or (tree-node-modified-time left) 0))
             (right-time (or (tree-node-modified-time right) 0)))
         (if (/= left-time right-time)
             (> left-time right-time)
             (string-lessp (string-downcase (tree-node-text left))
                           (string-downcase (tree-node-text right))))))
      ((eq sort-mode :type)
       (let ((left-ext (%filesystem-file-extension (or (tree-node-path left)
                                                       (tree-node-text left))))
             (right-ext (%filesystem-file-extension (or (tree-node-path right)
                                                        (tree-node-text right)))))
         (if (string/= left-ext right-ext)
             (string-lessp left-ext right-ext)
             (string-lessp (string-downcase (tree-node-text left))
                           (string-downcase (tree-node-text right))))))
      (t
       (string-lessp (string-downcase (tree-node-text left))
                     (string-downcase (tree-node-text right)))))))

(defun tree-node-children-sorted (node &key (sort-mode :name))
  "Return NODE children sorted with directories first and SORT-MODE ordering." 
  (stable-sort (copy-list (tree-node-children node))
               (lambda (left right)
                 (%tree-node-sort< left right sort-mode))))

(defun %filesystem-entry-name (path)
  "Return leaf name of PATH for display in tree labels." 
  (let* ((namestr (uiop:native-namestring path))
         (trimmed (string-right-trim '(#\/) namestr))
         (last-slash (position #\/ trimmed :from-end t)))
    (if (and last-slash (< last-slash (1- (length trimmed))))
        (subseq trimmed (1+ last-slash))
        trimmed)))

(defun %hidden-filesystem-entry-p (path)
  "Return true when PATH refers to a hidden entry (name starts with '.')." 
  (let ((name (%filesystem-entry-name path)))
    (and (> (length name) 0)
         (char= (char name 0) #\.))))

(defun %directory-child-paths (directory-path show-hidden-p)
  "Return DIRECTORY-PATH children as pathname list, respecting SHOW-HIDDEN-P." 
  (let* ((subdirs (uiop:subdirectories directory-path))
         (files (uiop:directory-files directory-path))
         (all (append subdirs files)))
    (if show-hidden-p
        all
        (remove-if #'%hidden-filesystem-entry-p all))))

(defun %filesystem-entry-allowed-p (path filter-extensions)
  "Return true when PATH should be visible for FILTER-EXTENSIONS." 
  (or (uiop:directory-exists-p path)
      (null filter-extensions)
      (member (%filesystem-file-extension path) filter-extensions :test #'string=)))

(defun %sort-filesystem-paths (paths sort-mode)
  "Sort PATHS by type and SORT-MODE (:name, :type, :date)." 
  (stable-sort (copy-list paths)
               (lambda (left right)
                 (let* ((left-dir-p (not (null (uiop:directory-exists-p left))))
                        (right-dir-p (not (null (uiop:directory-exists-p right))))
                        (left-name (string-downcase (%filesystem-entry-name left)))
                        (right-name (string-downcase (%filesystem-entry-name right))))
                   (cond
                     ((not (eq left-dir-p right-dir-p))
                      left-dir-p)
                     ((eq sort-mode :date)
                      (let ((left-time (or (%filesystem-path-write-date left) 0))
                            (right-time (or (%filesystem-path-write-date right) 0)))
                        (if (/= left-time right-time)
                            (> left-time right-time)
                            (string-lessp left-name right-name))))
                     ((eq sort-mode :type)
                      (let ((left-ext (%filesystem-file-extension left))
                            (right-ext (%filesystem-file-extension right)))
                        (if (string/= left-ext right-ext)
                            (string-lessp left-ext right-ext)
                            (string-lessp left-name right-name))))
                     (t
                      (string-lessp left-name right-name)))))))

(defun make-filesystem-tree-node (path &key (expanded-p nil) (children-loaded-p nil))
  "Create a lazy TREE-NODE for filesystem PATH." 
  (let* ((directory-p (uiop:directory-exists-p path))
         (file-p (and (not directory-p) (uiop:file-exists-p path)))
         (kind (cond (directory-p :directory)
                     (file-p :file)
        (t :item))))
    (make-tree-node :id (uiop:native-namestring path)
                    :text (%filesystem-entry-name path)
                    :kind kind
                    :path (uiop:native-namestring path)
                    :children nil
                    :children-loaded-p (if directory-p children-loaded-p t)
                    :modified-time (%filesystem-path-write-date path)
                    :expanded-p (and directory-p expanded-p)
                    :data path)))

(defun tree-view-load-node-children (widget node)
  "Load NODE children lazily from filesystem according to WIDGET options." 
  (when (and (tree-node-directory-p node)
             (not (tree-node-children-loaded-p node)))
    (let* ((directory-path (or (tree-node-path node)
                               (tree-node-id node)
                               (tree-node-data node)))
           (filter-exts (tree-view-normalize-extensions
                         (tree-view-filter-extensions widget)))
           (max-depth (tree-view-max-depth widget))
           (depth (tree-view-node-depth widget node))
           (paths (if (and max-depth (>= depth max-depth))
                      nil
                      (%sort-filesystem-paths
                       (remove-if-not
                        (lambda (child-path)
                          (%filesystem-entry-allowed-p child-path filter-exts))
                        (%directory-child-paths directory-path
                                                (tree-view-show-hidden-p widget)))
                       (tree-view-sort-mode widget)))))
      (setf (tree-node-children node)
            (loop for child-path in paths
                  collect (make-filesystem-tree-node child-path
                                                     :expanded-p nil
                                                     :children-loaded-p nil))
            (tree-node-children-loaded-p node) t))
    (setf (tree-node-children node)
          (tree-node-children-sorted node :sort-mode (tree-view-sort-mode widget))))
  node)

(defun tree-view-expand-node (widget node)
  "Expand NODE in WIDGET and ensure lazy children are loaded." 
  (when (tree-node-directory-p node)
    (tree-view-load-node-children widget node)
    (setf (tree-node-expanded-p node) t))
  node)

(defun tree-view-toggle-node-expanded (widget node)
  "Toggle NODE expansion in WIDGET, loading children lazily when opening." 
  (when (tree-node-directory-p node)
    (if (tree-node-expanded-p node)
        (setf (tree-node-expanded-p node) nil)
        (tree-view-expand-node widget node)))
  node)

(defun build-filesystem-tree (root-path &key (show-hidden-p nil)
                                        (filter-extensions nil)
                                        (sort-mode :name)
                                        (max-depth nil)
                                        (expanded-root-p t))
  "Build a single-root filesystem tree list from ROOT-PATH." 
  (declare (ignore show-hidden-p filter-extensions sort-mode max-depth))
  (let ((root-node (make-filesystem-tree-node root-path
                                              :expanded-p expanded-root-p
                                              :children-loaded-p nil)))
    (if root-node
        (list root-node)
        nil)))

(defun tree-view-load-directory (widget root-path &key (show-hidden-p nil)
                                          (filter-extensions nil)
                                          (sort-mode :name)
                                          (max-depth nil)
                                          (expanded-root-p t))
  "Populate TREE-VIEW WIDGET roots from ROOT-PATH filesystem contents." 
  (let* ((normalized-exts (tree-view-normalize-extensions filter-extensions))
         (roots (build-filesystem-tree root-path
                                       :show-hidden-p show-hidden-p
                                       :filter-extensions normalized-exts
                                       :sort-mode sort-mode
                                       :max-depth max-depth
                                       :expanded-root-p expanded-root-p)))
    (setf (tree-view-root-path widget) (uiop:native-namestring root-path)
        (tree-view-show-hidden-p widget) show-hidden-p
          (tree-view-filter-extensions widget) normalized-exts
          (tree-view-sort-mode widget) sort-mode
          (tree-view-max-depth widget) max-depth
          (tree-view-roots widget) roots
          (tree-view-selected-node widget) nil)
    (when (and expanded-root-p roots)
      (tree-view-expand-node widget (first roots))))
  widget)

(defun tree-node-has-children-p (node)
  "Return true when NODE has child nodes." 
  (and node
       (or (consp (tree-node-children node))
           (and (tree-node-directory-p node)
                (not (tree-node-children-loaded-p node))))))

(defun tree-view-node-depth (widget target)
  "Return depth of TARGET in WIDGET tree roots, or 0 when missing." 
  (labels ((walk (nodes depth)
             (loop for node in nodes do
               (when (eq node target)
                 (return-from tree-view-node-depth depth))
               (when (tree-node-has-children-p node)
                 (walk (tree-node-children node) (1+ depth))))))
    (walk (tree-view-roots widget) 0)
    0))

(defun tree-view-visible-rows (widget)
  "Return visible rows as a list of (NODE DEPTH) pairs for TREE-VIEW WIDGET." 
  (labels ((collect-visible (nodes depth)
             (loop for node in nodes append
                   (cons (list node depth)
                         (progn
                           (when (and (tree-node-expanded-p node)
                                      (tree-node-directory-p node)
                                      (not (tree-node-children-loaded-p node)))
                             (tree-view-load-node-children widget node))
                           (if (and (tree-node-expanded-p node)
                                    (tree-node-has-children-p node))
                               (collect-visible (tree-node-children node) (1+ depth))
                               nil))))))
    (collect-visible (tree-view-roots widget) 0)))

(defun tree-view-parent-node (widget target)
  "Return parent node of TARGET inside TREE-VIEW WIDGET, or NIL." 
  (labels ((find-parent (nodes parent)
             (loop for node in nodes do
               (when (eq node target)
                 (return-from find-parent parent))
               (when (tree-node-has-children-p node)
                 (let ((found (find-parent (tree-node-children node) node)))
                   (when found
                     (return found))))
               finally (return nil))))
    (find-parent (tree-view-roots widget) nil)))

(defun tree-view-select-node (widget node)
  "Select NODE in TREE-VIEW WIDGET and trigger update callback." 
  (setf (tree-view-selected-node widget) node)
  (update-widget-value widget node)
  node)

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

(defun combo-box-selected-item (widget)
  "Return currently selected item of combo-box WIDGET, or NIL when unavailable."
  (let ((items (list-box-items widget))
        (index (list-box-selected-index widget)))
    (when (and items (<= 0 index) (< index (length items)))
      (nth index items))))

(defun combo-box-find-item-index (widget item)
  "Return index of ITEM in combo-box WIDGET items, or NIL if missing."
  (position item (list-box-items widget) :test #'equal))

(defun combo-box-add-item (widget item &key (select t))
  "Add ITEM to combo-box WIDGET items, optionally selecting it.
If ITEM already exists, it becomes selected instead of duplicated." 
  (let ((items (list-box-items widget))
        (index (combo-box-find-item-index widget item)))
    (if index
        (when select
          (setf (list-box-selected-index widget) index))
        (progn
          (setf (list-box-items widget) (append items (list item))
                (list-box-selected-index widget) (1- (length (list-box-items widget))))))
    (when select
      (update-widget-value widget item)))
  widget)

(defun widget-effective-z-order (widget)
  "Return effective z-order for WIDGET, keeping expanded combo-box popups on top."
  (+ (widget-z-order widget)
     (if (and (typep widget 'combo-box)
              (combo-box-expanded-p widget))
         1000000
         0)))

(defun widgets-in-render-order (widgets)
  "Return WIDGETS sorted from back to front for painting."
  (stable-sort (copy-list widgets) #'< :key #'widget-effective-z-order))

(defun widgets-in-hit-test-order (widgets)
  "Return WIDGETS sorted from front to back for hit-testing."
  (stable-sort (copy-list widgets) #'> :key #'widget-effective-z-order))

(defun combo-box-total-height (widget)
  "Return total reserved height of combo-box WIDGET including popup when expanded."
  (+ (combo-box-main-height widget)
     (if (combo-box-expanded-p widget)
         (combo-box-popup-height widget)
         0)))

(defun sync-combo-box-expanded-state (widget expanded-p)
  "Synchronize combo-box expansion state and reserved widget height."
  (let ((main-height (if (combo-box-expanded-p widget)
                         (combo-box-main-height widget)
                         (widget-height widget))))
    (setf (combo-box-main-height widget) (max 1 main-height)
          (combo-box-expanded-p widget) expanded-p
          (widget-height widget) (if expanded-p
                                     (+ (combo-box-main-height widget)
                                        (combo-box-popup-height widget))
                                     (combo-box-main-height widget))))
  widget)

(defun combo-box-visible-item-count (widget)
  "Return visible row count for combo-box popup of WIDGET."
  (max 1
       (min (combo-box-max-visible-items widget)
            (max 1 (length (list-box-items widget))))))

(defun combo-box-max-scroll-offset (widget)
  "Return maximum valid popup scroll offset for combo-box WIDGET."
  (max 0
       (- (length (list-box-items widget))
          (combo-box-visible-item-count widget))))

(defun combo-box-scrollbar-needed-p (widget)
  "Return true when combo-box popup requires a scrollbar." 
  (> (length (list-box-items widget))
     (combo-box-visible-item-count widget)))

(defun normalize-combo-box-scroll-offset (widget)
  "Clamp combo-box popup scroll offset for WIDGET." 
  (setf (list-box-scroll-offset widget)
        (max 0
             (min (list-box-scroll-offset widget)
                  (combo-box-max-scroll-offset widget)))))

(defun ensure-combo-box-selection-visible (widget)
  "Adjust popup scroll of WIDGET so selected row stays visible." 
  (let* ((item-count (length (list-box-items widget)))
         (visible-count (combo-box-visible-item-count widget))
         (max-offset (combo-box-max-scroll-offset widget))
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

(defun combo-box-popup-y (widget)
  "Return popup top Y coordinate for combo-box WIDGET." 
  (+ (widget-y widget) (combo-box-main-height widget)))

(defun combo-box-popup-height (widget)
  "Return popup height for combo-box WIDGET." 
  (+ 2 (* (combo-box-visible-item-count widget)
          (list-box-item-height widget))))

(defun combo-box-content-width (widget)
  "Return popup content width excluding scrollbar when present." 
  (- (widget-width widget)
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
               (item-count (length (list-box-items widget)))
               (track-x (+ (widget-x widget) (combo-box-content-width widget)))
               (track-y (1+ (combo-box-popup-y widget)))
               (track-height (max 1 (- (combo-box-popup-height widget) 2)))
               (max-offset (combo-box-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count item-count)))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (list-box-scroll-offset widget) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun combo-box-set-scroll-offset-from-thumb-top (widget thumb-top)
  "Update popup scroll offset of combo-box WIDGET from scrollbar thumb top." 
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (combo-box-scrollbar-geometry widget)
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
      (normalize-combo-box-scroll-offset widget))))
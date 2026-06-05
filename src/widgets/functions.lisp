;;;; ./src/widgets/functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Shared widget helpers

(defvar *ttf-available-p* nil)
(defvar *ttf-font* nil)

;; Mapping from SDL window id -> list of widgets associated with that window
;; Used to quickly find widgets that should receive events coming from
;; transient popup windows (for example, combo-box popup windows).
(defvar *window-id->widgets* (make-hash-table :test 'eql)
  "Hash table mapping SDL window id (integer) to a list of widget objects.")

(defun register-widget-for-window-id (win-id widget)
  "Associate WIDGET with WIN-ID in the global window->widgets hash table.
Multiple widgets may be associated with the same window id. Returns the
updated list of widgets for WIN-ID." 
  (when (and win-id (numberp win-id) (> win-id 0))
    (let ((lst (gethash win-id *window-id->widgets*)))
      (setf (gethash win-id *window-id->widgets*)
            (if lst (pushnew widget lst :test #'eq) (list widget)))
      (gethash win-id *window-id->widgets*))))

(defun unregister-widget-for-window-id (win-id widget)
  "Remove association of WIDGET from WIN-ID. If no widgets remain for
WIN-ID, the hash entry is removed. Returns the remaining list or NIL." 
  (when (and win-id (numberp win-id) (> win-id 0))
    (let ((lst (gethash win-id *window-id->widgets*)))
      (when lst
        (let ((new (remove widget lst :test #'eq)))
          (if new
              (progn (setf (gethash win-id *window-id->widgets*) new) new)
              (progn (remhash win-id *window-id->widgets*) nil)))))))

(defun widgets-for-window-id (win-id)
  "Return the list of widgets associated with WIN-ID or NIL." 
  (and win-id (gethash win-id *window-id->widgets*)))

;;; Utilities accepting SDL window objects or integer ids -------------------
(defun window-id-from (window-or-id)
  "Return SDL window id integer for WINDOW-OR-ID which may be an SDL window object or an integer.
Returns NIL when the id cannot be determined." 
  (cond
    ((null window-or-id) nil)
    ((integerp window-or-id) window-or-id)
    (t (handler-case
         (sdl3:get-window-id window-or-id)
       (error nil)))))

(defun widgets-for-window (window-or-id)
  "Return widgets associated with WINDOW-OR-ID (SDL window object or integer id).
This delegates to `widgets-for-window-id'."
  (let ((wid (window-id-from window-or-id)))
    (and wid (widgets-for-window-id wid))))

(defun register-widgets-for-window (window-or-id widgets)
  "Register each widget from WIDGETS list for WINDOW-OR-ID (object or id).
Returns the updated list of widgets for the window." 
  (let ((wid (window-id-from window-or-id)))
    (when (and wid widgets)
      (dolist (w widgets)
        (register-widget-for-window-id wid w))
      (widgets-for-window-id wid))))

(defun unregister-widgets-for-window (window-or-id &optional widgets)
  "Unregister WIDGETS (list) from WINDOW-OR-ID. If WIDGETS is NIL remove all associations for that window.
Returns remaining widget list or NIL." 
  (let ((wid (window-id-from window-or-id)))
    (when wid
      (if widgets
          (dolist (w widgets)
            (unregister-widget-for-window-id wid w))
          (remhash wid *window-id->widgets*))
      (gethash wid *window-id->widgets*))))

(defun clear-window-widget-registry ()
  "Clear the global window-id -> widgets registry used for transient popup windows."
  (clrhash *window-id->widgets*)
  t)

(defun destroy-window-and-unregister (window-or-id &key (layer-manager nil))
  "Destroy SDL WINDOW-OR-ID (object or integer) and unregister any widget
associations for that window id. If LAYER-MANAGER is provided, also call
`mnas-sdl3-gui/window-manager:unregister-window' to remove the managed window.
Returns the window id that was processed or NIL." 
  (let ((wid (window-id-from window-or-id)))
    (when (and window-or-id (not (integerp window-or-id)))
      (ignore-errors (sdl3:destroy-window window-or-id)))
    (when wid
      (ignore-errors (unregister-widgets-for-window wid))
      (when layer-manager
        (ignore-errors (mnas-sdl3-gui/window-manager:unregister-window layer-manager wid)))
      wid)))

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

(defun make-widget-container (&key (x 0) (y 0) (width 100) (height 100) (children nil))
  "Create a new widget container that holds child widgets." 
  (make-instance 'mnas-sdl3-gui/widgets:widget-container
                 :x x
                 :y y
                 :width width
                 :height height
                 :children (or children nil)))

(defun make-scroll-container (&key (x 0) (y 0) (width 100) (height 100) (children nil))
  "Create a new scroll-container for vertically stacked child widgets." 
  (make-instance 'mnas-sdl3-gui/widgets:scroll-container
                 :x x
                 :y y
                 :width width
                 :height height
                 :children (or children nil)
                 :scroll-offset 0))

(defun make-row-stack (&key (x 0) (y 0) (width 100) (height 40)
                        (children nil)
                        (spacing 4)
                        (padding 4))
  "Create a row-stack container that arranges child widgets horizontally." 
  (make-instance 'mnas-sdl3-gui/widgets:row-stack
                 :x x
                 :y y
                 :width width
                 :height height
                 :children (or children nil)
                 :spacing spacing
                 :padding padding))

(defun make-column-stack (&key (x 0) (y 0) (width 100) (height 100)
                           (children nil)
                           (spacing 4)
                           (padding 4))
  "Create a column-stack container that arranges child widgets vertically." 
  (make-instance 'mnas-sdl3-gui/widgets:column-stack
                 :x x
                 :y y
                 :width width
                 :height height
                 :children (or children nil)
                 :spacing spacing
                 :padding padding))

(defun make-split-pane (&key (x 0) (y 0) (width 100) (height 100)
                           (children nil)
                           (orientation :horizontal)
                           (split-ratio 0.5)
                           (divider-size 4)
                           (padding 8)
                           (min-first-pane 32)
                           (min-second-pane 32))
  "Create a split-pane container that divides available space into two panes." 
  (make-instance 'mnas-sdl3-gui/widgets:split-pane
                 :x x
                 :y y
                 :width width
                 :height height
                 :children (or children nil)
                 :orientation orientation
                 :split-ratio split-ratio
                 :divider-size divider-size
                 :padding padding
                 :min-first-pane min-first-pane
                 :min-second-pane min-second-pane))

(defun make-canvas-2d-widget (&key (x 0) (y 0) (width 300) (height 200)
                                 (scene nil)
                                 (viewport-scale 1.0)
                                 (viewport-offset-x 0)
                                 (viewport-offset-y 0)
                                 (pan-enabled t)
                                 (zoom-enabled t))
  "Create a new canvas-2d-widget with viewport state and optional scene model." 
  (make-instance 'mnas-sdl3-gui/widgets:canvas-2d-widget
                 :x x
                 :y y
                 :width width
                 :height height
                 :scene scene
                 :viewport-scale viewport-scale
                 :viewport-offset-x viewport-offset-x
                 :viewport-offset-y viewport-offset-y
                 :pan-enabled pan-enabled
                 :zoom-enabled zoom-enabled
                 :redraw-requested t))

(defmethod set-scene ((widget canvas-2d-widget) scene)
  (setf (canvas-2d-widget-scene widget) scene)
  (request-redraw widget)
  widget)

(defmethod request-redraw ((widget canvas-2d-widget))
  (setf (canvas-2d-widget-redraw-requested widget) t)
  t)

(defmethod world-to-screen ((widget canvas-2d-widget) x y &optional z)
  (let ((scale (max 0.01 (canvas-2d-widget-viewport-scale widget)))
        (offset-x (canvas-2d-widget-viewport-offset-x widget))
        (offset-y (canvas-2d-widget-viewport-offset-y widget)))
    (values (+ (widget-x widget)
               offset-x
               (* x scale))
            (+ (widget-y widget)
               offset-y
               (* y scale))
            z)))

(defmethod screen-to-world ((widget canvas-2d-widget) x y &optional z)
  (let ((scale (max 0.01 (canvas-2d-widget-viewport-scale widget)))
        (offset-x (canvas-2d-widget-viewport-offset-x widget))
        (offset-y (canvas-2d-widget-viewport-offset-y widget)))
    (values (/ (- x (widget-x widget) offset-x) scale)
            (/ (- y (widget-y widget) offset-y) scale)
            z)))

(defmethod handle-viewport-resize ((widget canvas-2d-widget) width height)
  (when (or (/= (widget-width widget) width)
            (/= (widget-height widget) height))
    (setf (widget-width widget) width
          (widget-height widget) height)
    (request-redraw widget)))

(defun render-canvas-2d-grid (renderer widget)
  "Render a faint background grid for a canvas-2d-widget." 
  (let ((x (widget-x widget))
        (y (widget-y widget))
        (w (widget-width widget))
        (h (widget-height widget))
        (grid-step 32)
        (grid-color '(220 220 220 255)))
    (loop for gx from 0 below w by grid-step
          do (stroke-rect renderer (+ x gx) y 1 h grid-color))
    (loop for gy from 0 below h by grid-step
          do (stroke-rect renderer x (+ y gy) w 1 grid-color))))

(defun render-canvas-2d-placeholder (renderer widget)
  "Render placeholder content when a 2D scene model is not provided." 
  (let ((x (widget-x widget))
        (y (widget-y widget)))
    (render-text renderer "Canvas-2D" (+ x 8) (+ y 8) +color-text+)
    (render-text renderer "set-scene to display content" (+ x 8) (+ y 26) +color-text+)))

(defun render-canvas-2d-scene (renderer widget)
  "Render a very small default canvas scene for 2D canvas widgets." 
  (let ((x0 (widget-x widget))
        (y0 (widget-y widget))
        (scale (max 0.01 (canvas-2d-widget-viewport-scale widget))))
    (fill-circle renderer (+ x0 80) (+ y0 80) (max 8 (floor (* 8 scale))) '(0 128 255 255))
    (stroke-rect renderer (+ x0 120) (+ y0 40) (max 24 (floor (* 56 scale))) (max 24 (floor (* 40 scale))) '(0 0 0 255))))

(defun scroll-container-content-height (widget)
  "Return total height of child widgets inside scroll container." 
    (loop for child in (children widget)
      sum (widget-height child)))

(defun scroll-container-max-scroll-offset (widget)
  "Return maximal vertical scroll offset for SCROLL-CONTAINER." 
  (max 0 (- (scroll-container-content-height widget)
            (widget-height widget))))

(defun normalize-scroll-container-scroll-offset (widget)
  "Clamp SCROLL-CONTAINER scroll offset to valid range." 
  (setf (scroll-container-scroll-offset widget)
        (max 0 (min (scroll-container-scroll-offset widget)
                    (scroll-container-max-scroll-offset widget)))))

;; `scroll-container-scroll-by` moved to methods/scroll-by.lisp (defgeneric `scroll-by` and per-type methods).

(defun widget-add-child (container child)
  "Add CHILD to CONTAINER's child widget list." 
  (push child (children container))
  container)

(defun widget-remove-child (container child)
  "Remove CHILD from CONTAINER's child widget list." 
    (setf (children container)
      (remove child (children container) :test #'eq))
  container)

(defun widget-clear-children (container)
  "Remove all children from CONTAINER." 
  (setf (children container) nil)
  container)

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
          (tree-view-scroll-offset widget) 0
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

(defun tree-view-visible-row-count (widget)
  "Return number of tree rows that fit in WIDGET viewport." 
  (max 1
       (floor (max 1 (- (widget-height widget) 2))
              (max 1 (tree-view-row-height widget)))))

(defun tree-view-max-scroll-offset (widget)
  "Return maximum valid first-visible row index for TREE-VIEW WIDGET." 
  (max 0
       (- (length (tree-view-visible-rows widget))
          (tree-view-visible-row-count widget))))

(defun tree-view-scrollbar-needed-p (widget)
  "Return true when TREE-VIEW needs a vertical scrollbar." 
  (> (length (tree-view-visible-rows widget))
     (tree-view-visible-row-count widget)))

(defun tree-view-scrollbar-geometry (widget)
  "Return geometry values for the TREE-VIEW scrollbar.
Values are: needed-p, track-x, track-y, track-height, thumb-y, thumb-height, max-offset."
  (let ((needed-p (tree-view-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (tree-view-visible-row-count widget))
               (row-height (max 16 (tree-view-row-height widget)))
               (track-x (+ (widget-x widget) (- (widget-width widget) +list-box-scrollbar-width+)))
               (track-y (1+ (widget-y widget)))
               (track-height (max 1 (- (widget-height widget) 2)))
               (max-offset (tree-view-max-scroll-offset widget))
               (thumb-height (max 18 (floor (* track-height (/ visible-count (float (length (tree-view-visible-rows widget))))))))
               (thumb-travel (max 0 (- track-height thumb-height)))
               (thumb-y (+ track-y
                           (if (zerop max-offset)
                               0
                               (round (* thumb-travel
                                         (/ (tree-view-scroll-offset widget) max-offset)))))))
          (values t track-x track-y track-height thumb-y thumb-height max-offset)))))

(defun normalize-tree-view-scroll-offset (widget)
  "Clamp tree-view scroll offset to valid row range." 
  (setf (tree-view-scroll-offset widget)
        (max 0
             (min (tree-view-scroll-offset widget)
                  (tree-view-max-scroll-offset widget)))))

(defun ensure-tree-view-selection-visible (widget)
  "Adjust tree-view scroll so selected node is within visible viewport." 
  (let* ((rows (tree-view-visible-rows widget))
         (selected (tree-view-selected-node widget))
         (selected-index (position selected rows :key #'first :test #'eq))
         (visible-count (tree-view-visible-row-count widget))
         (max-offset (tree-view-max-scroll-offset widget))
         (scroll-offset (max 0 (min (tree-view-scroll-offset widget) max-offset))))
    (when selected-index
      (cond
        ((< selected-index scroll-offset)
         (setf scroll-offset selected-index))
        ((>= selected-index (+ scroll-offset visible-count))
         (setf scroll-offset (1+ (- selected-index visible-count))))))
    (setf (tree-view-scroll-offset widget)
          (max 0 (min scroll-offset max-offset)))))

;; `tree-view-scroll-by` moved to methods/scroll-by.lisp (defgeneric `scroll-by` and per-type methods).

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
  (ensure-tree-view-selection-visible widget)
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

;; `scroll-by` implementation moved to methods/scroll-by.lisp (defgeneric + defmethods).

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

;; Public hook called when a combo-box expansion state changes.
;; Demo code can set this to a function that accepts two args: (widget expanded-p).
(defparameter *combo-box-expanded-callback* nil
  "Optional callback called as (funcall fn widget expanded-p) when a combo-box expands or collapses.")

(defun widgets-in-render-order (widgets)
  "Return WIDGETS sorted from back to front for painting.
If a combo-box uses a separate popup window, append a transient popup-proxy
object at the end so popup windows are rendered after main widgets.
The popup proxy's render method will perform popup-window rendering and
present the popup's renderer."  
  (let* ((sorted (stable-sort (copy-list widgets) #'< :key #'widget-effective-z-order))
         (popups '()))
    (dolist (w sorted)
      (when (and (typep w 'combo-box)
                 (combo-box-popup-window-enabled-p w))
        (push (make-instance 'combo-box-popup :owner w) popups)))
    (append sorted (nreverse popups))))

(defun widgets-in-hit-test-order (widgets)
  "Return WIDGETS sorted from front to back for hit-testing."
  (stable-sort (copy-list widgets) #'> :key #'widget-effective-z-order))

(defun combo-box-total-height (widget)
  "Return total reserved height of combo-box WIDGET including popup when expanded."
  (+ (combo-box-main-height widget)
     (if (and (combo-box-expanded-p widget)
              (not (combo-box-popup-window-enabled-p widget)))
         (combo-box-popup-height widget)
         0)))

(defun combo-box-popup-window-enabled-p (widget)
  "Return true when WIDGET uses a separate popup window for the drop-down."
  (let ((host (combo-box-popup-host-window widget)))
    (and (typep widget 'combo-box)
         (eq (combo-box-popup-mode widget) :window)
         host
         (not (cffi:null-pointer-p host)))))

(defun sync-combo-box-expanded-state (widget expanded-p)
  "Synchronize combo-box expansion state and reserved widget height."
  (let ((main-height (if (combo-box-expanded-p widget)
                         (combo-box-main-height widget)
                         (widget-height widget))))
    (setf (combo-box-main-height widget) (max 1 main-height)
          (combo-box-expanded-p widget) expanded-p
          (widget-height widget)
          (if (and expanded-p
                   (not (combo-box-popup-window-enabled-p widget)))
              (+ (combo-box-main-height widget)
                 (combo-box-popup-height widget))
              (combo-box-main-height widget))))
  (format t "[combo-box] sync expanded=~A enabled=~A host=~S~%"
          expanded-p
          (combo-box-popup-window-enabled-p widget)
          (combo-box-popup-host-window widget))
  (when (combo-box-popup-window-enabled-p widget)
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

(defun combo-box-popup-scrollbar-geometry (widget popup-x popup-y)
  "Return popup scrollbar geometry for WIDGET with popup at POPUP-X/POPUP-Y."
  (let ((needed-p (combo-box-scrollbar-needed-p widget)))
    (if (not needed-p)
        (values nil nil nil nil nil nil 0)
        (let* ((visible-count (combo-box-visible-item-count widget))
               (item-count (length (list-box-items widget)))
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

(defun combo-box-popup-set-scroll-offset-from-thumb-top (widget popup-x popup-y thumb-top)
  "Update popup scroll offset using POPUP-X/POPUP-Y geometry and THUMB-TOP."
  (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
      (combo-box-popup-scrollbar-geometry widget popup-x popup-y)
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

(defun combo-box-ensure-popup-window (widget)
  "Ensure popup window/renderer exist for WIDGET. Returns popup window or NIL."
  (cond
    ((combo-box-popup-window widget)
     (combo-box-popup-window widget))
    ((and (combo-box-popup-window-enabled-p widget)
          (combo-box-popup-host-window widget))
     (format t "[combo-box] ensure-popup host=~S size=~Dx~D~%"
             (combo-box-popup-host-window widget)
             (widget-width widget)
             (combo-box-popup-height widget))
     (finish-output)
     (let* ((popup-window (sdl3:create-popup-window
                           (combo-box-popup-host-window widget)
                           0
                           0
                           (widget-width widget)
                           (combo-box-popup-height widget)
                           :popup-menu)))
       (when (or (null popup-window) (cffi:null-pointer-p popup-window))
         (format t "Failed to create combo-box popup window: ~A~%" (sdl3:get-error))
         (return-from combo-box-ensure-popup-window nil))
       (let ((popup-renderer (sdl3:create-renderer popup-window "")))
         (when (or (null popup-renderer) (cffi:null-pointer-p popup-renderer))
           (format t "Failed to create combo-box popup renderer: ~A~%" (sdl3:get-error))
           (return-from combo-box-ensure-popup-window nil))
         (setf (combo-box-popup-window widget) popup-window
               (combo-box-popup-renderer widget) popup-renderer
               (combo-box-popup-window-id widget) (sdl3:get-window-id popup-window))
           ;; Register mapping from the SDL popup window id to this widget so
           ;; event dispatchers can quickly find the widgets associated with
           ;; transient popup windows.
           (when (and (combo-box-popup-window-id widget)
              (numberp (combo-box-popup-window-id widget))
              (> (combo-box-popup-window-id widget) 0))
             (register-widget-for-window-id (combo-box-popup-window-id widget) widget))
         (format t "[combo-box] popup created id=~S renderer=~S~%"
                 (combo-box-popup-window-id widget)
                 popup-renderer)
         (finish-output)
         (when (combo-box-popup-layer-manager widget)
           (mnas-sdl3-gui/window-manager:register-window
            (combo-box-popup-layer-manager widget)
            (combo-box-popup-window-id widget)
            :dropdown-host
            :parent-id (sdl3:get-window-id (combo-box-popup-host-window widget))
            :open-p nil))
         popup-window)))
    (t nil)))

(defun combo-box-show-popup-window (widget)
  "Show popup window for WIDGET if popup mode is enabled."
  (format t "[combo-box] show-popup enter host=~S popup=~S~%"
    (combo-box-popup-host-window widget)
    (combo-box-popup-window widget))
  (finish-output)
  (when (combo-box-ensure-popup-window widget)
    (multiple-value-bind (ok wx wy)
        (sdl3:get-window-position (combo-box-popup-host-window widget))
      (let ((global-x (if ok (+ wx (widget-x widget)) (widget-x widget)))
            (global-y (if ok (+ wy (widget-y widget) (combo-box-main-height widget))
                          (+ (widget-y widget) (combo-box-main-height widget)))))
        (format t "[combo-box] show-popup ok=~A host=~S popup-id=~S pos=(~D,~D) expanded=~A~%"
                ok
                (combo-box-popup-host-window widget)
                (combo-box-popup-window-id widget)
                global-x global-y
                (combo-box-expanded-p widget))
  (finish-output)
        (sdl3:set-window-position (combo-box-popup-window widget) global-x global-y)
        (sdl3:show-window (combo-box-popup-window widget))
        (sdl3:raise-window (combo-box-popup-window widget))
        (when (combo-box-popup-layer-manager widget)
          (mnas-sdl3-gui/window-manager:open-dropdown-host
           (combo-box-popup-layer-manager widget)
           (combo-box-popup-window-id widget)
           (sdl3:get-window-id (combo-box-popup-host-window widget))))
        (setf (combo-box-popup-visible-p widget) t))))
  (combo-box-popup-visible-p widget))

(defun combo-box-hide-popup-window (widget)
  "Hide popup window for WIDGET if present."
  (setf (combo-box-popup-visible-p widget) nil)
  (when (combo-box-popup-window widget)
    (ignore-errors (sdl3:hide-window (combo-box-popup-window widget))))
  (when (combo-box-popup-layer-manager widget)
    (mnas-sdl3-gui/window-manager:close-window
     (combo-box-popup-layer-manager widget)
     (combo-box-popup-window-id widget)
     :close-children t))
  nil)

(defun combo-box-enable-popup-window (widget host-window &key layer-manager)
  "Enable popup window mode for WIDGET using HOST-WINDOW." 
  (setf (combo-box-popup-mode widget) :window
        (combo-box-popup-host-window widget) host-window
        (combo-box-popup-layer-manager widget) layer-manager)
  (combo-box-ensure-popup-window widget)
  widget)

(defun combo-box-disable-popup-window (widget)
  "Disable popup window mode and destroy popup resources for WIDGET." 
  (combo-box-hide-popup-window widget)
  ;; Capture popup window id before destroying resources so we can remove
  ;; the mapping from window id -> widget.
  (let ((old-id (combo-box-popup-window-id widget)))
    (when (combo-box-popup-renderer widget)
      (sdl3:destroy-renderer (combo-box-popup-renderer widget)))
    (when (combo-box-popup-window widget)
      (destroy-window-and-unregister (combo-box-popup-window widget)
                                     :layer-manager (combo-box-popup-layer-manager widget)))
    )
  (setf (combo-box-popup-window widget) nil
        (combo-box-popup-renderer widget) nil
        (combo-box-popup-window-id widget) 0
        (combo-box-popup-host-window widget) nil
        (combo-box-popup-layer-manager widget) nil
        (combo-box-popup-visible-p widget) nil
        (combo-box-popup-mode widget) :inline)
  widget)

(defun combo-box-handle-popup-mouse-down (widget x y)
  "Handle mouse-down inside popup window for WIDGET with local X/Y coords." 
  (normalize-combo-box-scroll-offset widget)
  (let* ((item-height (list-box-item-height widget))
         (visible-count (combo-box-visible-item-count widget))
         (scrollbar-needed-p (combo-box-scrollbar-needed-p widget))
         (content-width (combo-box-content-width widget))
         (rel-x x)
         (rel-y y))
    (cond
      ((and scrollbar-needed-p (>= rel-x content-width))
       (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
           (combo-box-popup-scrollbar-geometry widget 0 0)
         (declare (ignore needed-p track-x track-height max-offset))
         (let ((thumb-hit-p (<= thumb-y y (+ thumb-y thumb-height))))
           (setf (list-box-scrollbar-dragging-p widget) t
                 (list-box-scrollbar-drag-offset widget)
                 (if thumb-hit-p
                     (- y thumb-y)
                     (floor thumb-height 2)))
           (combo-box-popup-set-scroll-offset-from-thumb-top widget 0 0
                                                             (- y (list-box-scrollbar-drag-offset widget))))))
      ((>= rel-y 0)
       (setf (list-box-scrollbar-dragging-p widget) nil)
       (let* ((row (floor rel-y item-height))
              (new-index (+ (list-box-scroll-offset widget) row)))
         (when (and (< row visible-count)
                    (< new-index (length (list-box-items widget))))
           (setf (list-box-selected-index widget) new-index)
           (when (typep widget 'editable-combo-box)
             (setf (entry-text widget) (format nil "~a" (nth new-index (list-box-items widget)))
                   (entry-cursor widget) (length (entry-text widget)))
             (entry-scroll-to-start widget))
           (sync-combo-box-expanded-state widget nil)
           (update-widget-value widget
                                (nth new-index (list-box-items widget))))))
      (t
       (setf (list-box-scrollbar-dragging-p widget) nil)
       (sync-combo-box-expanded-state widget nil)))
    t))

(defun combo-box-handle-popup-mouse-up (widget x y)
  "Handle mouse-up inside popup window for WIDGET." 
  (declare (ignore x y))
  (let ((dragging-p (list-box-scrollbar-dragging-p widget)))
    (setf (list-box-scrollbar-dragging-p widget) nil
          (list-box-scrollbar-drag-offset widget) 0)
    dragging-p))

(defun combo-box-handle-popup-mouse-motion (widget x y)
  "Handle mouse-motion inside popup window for WIDGET." 
  (when (list-box-scrollbar-dragging-p widget)
    (combo-box-popup-set-scroll-offset-from-thumb-top widget 0 0
                                                      (- y (list-box-scrollbar-drag-offset widget)))
    t))

(defun combo-box-handle-popup-mouse-wheel (widget dy)
  "Handle mouse-wheel inside popup window for WIDGET." 
  (when (not (zerop dy))
    (let ((ev (sdl3:mouse-wheel-event :%yrel dy :%mouse-y dy :%x 0 :%y 0)))
      (handle-mouse-wheel-event widget ev))))

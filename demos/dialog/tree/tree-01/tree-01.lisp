;;;; ./demos/dialog/tree/tree-01/tree-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/tree-01)

(defparameter *tree-01-window* nil)
(defparameter *tree-01-renderer* nil)
(defparameter *tree-01-open* t)
(defparameter *tree-01-style* :flat)
(defparameter *tree-01-widgets* nil)
(defparameter *tree-01-status* "Ready")

(defparameter *tree-01-root-entry* nil)
(defparameter *tree-01-filter-entry* nil)
(defparameter *tree-01-sort-combo* nil)
(defparameter *tree-01-show-hidden* nil)
(defparameter *tree-01-tree* nil)
(defparameter *tree-01-status-label* nil)

(defun tree-01-default-root ()
  "Return default root path for the demo." 
  (or (uiop:getenv "HOME")
      (uiop:getcwd)))

(defun tree-01-current-sort-mode ()
  "Return selected sort mode keyword from combo-box." 
  (let* ((index (mnas-sdl3-gui/widgets:list-box-selected-index *tree-01-sort-combo*))
         (items (mnas-sdl3-gui/widgets:list-box-items *tree-01-sort-combo*))
         (selected (and (<= 0 index) (< index (length items))
                        (nth index items))))
    (cond
      ((string-equal selected "type") :type)
      ((string-equal selected "date") :date)
      (t :name))))

(defun tree-01-parse-extensions (text)
  "Parse comma/space separated extension list from TEXT." 
  (let ((trimmed (string-trim '(#\Space #\Tab #\Newline #\Return) (or text ""))))
    (if (zerop (length trimmed))
        nil
        (mnas-sdl3-gui/widgets:tree-view-normalize-extensions
         (uiop:split-string trimmed :separator '(#\, #\; #\Space #\Tab))))))

(defun tree-01-set-status (text)
  "Update status label text." 
  (setf *tree-01-status* text)
  (when *tree-01-status-label*
    (setf (mnas-sdl3-gui/widgets:label-text *tree-01-status-label*) text)))

(defun tree-01-load-tree ()
  "Load tree-view from current controls." 
  (let* ((root (string-trim '(#\Space #\Tab #\Newline #\Return)
                            (mnas-sdl3-gui/widgets:entry-text *tree-01-root-entry*)))
         (root-path (if (zerop (length root))
                        (tree-01-default-root)
                        root))
         (extensions (tree-01-parse-extensions
                      (mnas-sdl3-gui/widgets:entry-text *tree-01-filter-entry*)))
         (sort-mode (tree-01-current-sort-mode))
         (show-hidden (mnas-sdl3-gui/widgets:check-box-checked *tree-01-show-hidden*)))
    (handler-case
        (progn
          (mnas-sdl3-gui/widgets:tree-view-load-directory
           *tree-01-tree*
           root-path
           :show-hidden-p show-hidden
           :filter-extensions extensions
           :sort-mode sort-mode
           :expanded-root-p t)
          (setf (mnas-sdl3-gui/widgets:entry-text *tree-01-root-entry*) root-path
                (mnas-sdl3-gui/widgets:entry-cursor *tree-01-root-entry*) (length root-path))
          (tree-01-set-status
           (format nil "Loaded: ~A | sort=~A | ext=~A | hidden=~A"
                   root-path
                   sort-mode
                   (or extensions :all)
                   show-hidden)))
      (error (condition)
        (tree-01-set-status (format nil "Load error: ~A" condition))))))

(defun tree-01-on-tree-change (widget node)
  "Update status when selected node changes." 
  (declare (ignore widget))
  (when node
    (tree-01-set-status
     (format nil "Selected: ~A (~A)"
             (or (mnas-sdl3-gui/widgets:tree-node-path node)
                 (mnas-sdl3-gui/widgets:tree-node-text node))
             (mnas-sdl3-gui/widgets:tree-node-kind node)))))

(defun create-tree-01-widgets ()
  "Create widgets for filesystem tree demo." 
  (let ((title (make-instance 'mnas-sdl3-gui/widgets:label
                              :x 20 :y 16 :width 920 :height 24
                              :text "Filesystem Tree Demo"))
        (root-label (make-instance 'mnas-sdl3-gui/widgets:label
                                   :x 20 :y 48 :width 90 :height 24
                                   :text "Root path:"))
        (root-entry (make-instance 'mnas-sdl3-gui/widgets:entry
                                   :x 110 :y 48 :width 560 :height 30
                                   :text (tree-01-default-root)
                                   :max-length 512))
        (reload-button (make-instance 'mnas-sdl3-gui/widgets:button
                                      :x 680 :y 48 :width 80 :height 30
                                      :text "Load"
                                      :on-click (lambda (widget)
                                                  (declare (ignore widget))
                                                  (tree-01-load-tree))))
        (refresh-button (make-instance 'mnas-sdl3-gui/widgets:button
                                       :x 770 :y 48 :width 90 :height 30
                                       :text "Refresh"
                                       :on-click (lambda (widget)
                                                   (declare (ignore widget))
                                                   (tree-01-load-tree))))
        (filter-label (make-instance 'mnas-sdl3-gui/widgets:label
                                     :x 20 :y 84 :width 90 :height 24
                                     :text "Ext filter:"))
        (filter-entry (make-instance 'mnas-sdl3-gui/widgets:entry
                                     :x 110 :y 84 :width 280 :height 30
                                     :text "lisp,asd,md,txt"
                                     :max-length 256))
        (sort-label (make-instance 'mnas-sdl3-gui/widgets:label
                                   :x 402 :y 84 :width 90 :height 24
                                   :text "Sort:"))
        (sort-combo (make-instance 'mnas-sdl3-gui/widgets:combo-box
                                   :x 450 :y 84 :width 120 :height 30
                                   :items '("name" "type" "date")
                                   :selected-index 0))
        (show-hidden (make-instance 'mnas-sdl3-gui/widgets:check-box
                                    :x 580 :y 84 :width 130 :height 30
                                    :label "Show hidden"
                                    :checked nil))
        (apply-button (make-instance 'mnas-sdl3-gui/widgets:button
                                     :x 720 :y 84 :width 140 :height 30
                                     :text "Apply filter/sort"
                                     :on-click (lambda (widget)
                                                 (declare (ignore widget))
                                                 (tree-01-load-tree))))
        (tree (make-instance 'mnas-sdl3-gui/widgets:tree-view
                             :x 20 :y 124 :width 920 :height 430
                             :row-height 22
                             :indent-width 18
                             :on-change #'tree-01-on-tree-change))
        (status-label (make-instance 'mnas-sdl3-gui/widgets:label
                                     :x 20 :y 564 :width 920 :height 24
                                     :text *tree-01-status*)))
    (setf *tree-01-root-entry* root-entry
          *tree-01-filter-entry* filter-entry
          *tree-01-sort-combo* sort-combo
          *tree-01-show-hidden* show-hidden
          *tree-01-tree* tree
          *tree-01-status-label* status-label
          *tree-01-widgets*
          (list title
                root-label root-entry reload-button refresh-button
                filter-label filter-entry sort-label sort-combo show-hidden apply-button
                tree
                status-label))
    (tree-01-load-tree)
    *tree-01-widgets*))

(sdl3:def-app-init tree-01-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Filesystem Tree Demo" "1.0"
                         "com.mna.sdl3.gui.tree-01.demo")
  (when (not (sdl3:init :video))
    (format t "~A~%" (sdl3:get-error))
    (return-from tree-01-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Filesystem Tree Demo" 960 620 0)
    (if (not ok)
        (progn
          (format t "~A~%" (sdl3:get-error))
          (return-from tree-01-init :failure))
        (progn
          (setf *tree-01-window* window
                *tree-01-renderer* renderer
                *tree-01-open* t)
          (mnas-sdl3-gui/widgets:set-widget-style *tree-01-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-tree-01-widgets)
            (mnas-sdl3-gui/widgets:set-widget-focus *tree-01-widgets* *tree-01-tree*))))
  :continue)

(sdl3:def-app-iterate tree-01-iterate ()
  (unless *tree-01-open*
    (return-from tree-01-iterate :success))
  (sdl3:set-render-draw-color *tree-01-renderer* 242 242 242 255)
  (sdl3:render-clear *tree-01-renderer*)
  (mnas-sdl3-gui/widgets:render-widgets *tree-01-renderer* *tree-01-widgets*)
  (sdl3:render-present *tree-01-renderer*)
  :continue)

(sdl3:def-app-event tree-01-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *tree-01-open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *tree-01-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down *tree-01-widgets* mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up *tree-01-widgets* mx my))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-wheel
        *tree-01-widgets*
        (round (slot-value ev 'sdl3:%mouse-x))
        (round (slot-value ev 'sdl3:%mouse-y))
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
          *tree-01-widgets*
          (slot-value ev 'sdl3:%key)
          :mods (slot-value ev 'sdl3:%mod)
          :on-escape (lambda ()
                       (setf *tree-01-open* nil)
                       :success)
          :on-return (lambda ()
                       (tree-01-load-tree)
                       :continue)))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        *tree-01-widgets*
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit tree-01-quit (result)
  (declare (ignore result))
  (mnas-sdl3-gui/widgets:stop-widget-text-input *tree-01-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *tree-01-renderer*
    (sdl3:destroy-renderer *tree-01-renderer*))
  (when *tree-01-window*
    (sdl3:destroy-window *tree-01-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun tree-01 (&optional (style :flat))
  "Run filesystem tree demo." 
  (setf *tree-01-style* style)
  (sdl3:enter-app-main-callbacks
   'tree-01-init
   'tree-01-iterate
   'tree-01-event
   'tree-01-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/tree-01)
;;;; (tree-01)

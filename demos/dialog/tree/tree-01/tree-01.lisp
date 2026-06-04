;;;; ./demos/dialog/tree/tree-01/tree-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/tree-01)

(defparameter *tree-01-window* nil)
(defparameter *tree-01-renderer* nil)
(defparameter *tree-01-window-id* 0)
(defparameter *tree-01-layer-manager* nil)
(defparameter *tree-01-toolbar* nil)
(defparameter *tree-01-open* t)
(defparameter *tree-01-style* :flat)
(defparameter *tree-01-widgets* nil)
(defparameter *tree-01-status* "Ready")

(defparameter +tree-01-toolbar-x+ 20.0)
(defparameter +tree-01-toolbar-y+ 592.0)
(defparameter +tree-01-toolbar-height+ 24.0)
(defparameter +tree-01-mouse-left+ 1)

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

(defun make-tree-01-toolbar ()
  "Create toolbar as a secondary presenter of tree-01 commands." 
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:toolbar :layout :horizontal :height 24)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Load" :width 56)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Hidden" :width 68 :type :toggle)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Clear filter" :width 92)
           (make-instance 'mnas-sdl3-gui/widgets:toolbar-button :command-id :label "Quit" :width 52)))
    toolbar))

(defun tree-01-sync-command-state ()
  "Sync dynamic full-state command properties for toolbar rendering." 
  (let* ((toggle-hidden-cmd (mnas-sdl3-gui/commands:find-command :tree-01/toggle-hidden))
         (clear-filter-cmd (mnas-sdl3-gui/commands:find-command :tree-01/clear-filter))
         (show-hidden (and *tree-01-show-hidden*
                           (mnas-sdl3-gui/widgets:check-box-checked *tree-01-show-hidden*)))
         (filter-text (and *tree-01-filter-entry*
                           (mnas-sdl3-gui/widgets:entry-text *tree-01-filter-entry*)))
         (filter-non-empty-p (and filter-text
                                  (> (length (string-trim '(#\Space #\Tab #\Newline #\Return)
                                                           filter-text))
                                     0))))
    (when toggle-hidden-cmd
      (mnas-sdl3-gui/commands:set-command-checked toggle-hidden-cmd show-hidden))
    (when clear-filter-cmd
      (mnas-sdl3-gui/commands:set-command-visible clear-filter-cmd filter-non-empty-p))))

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
                                                  (tree-01-command :tree-01/load))))
        (refresh-button (make-instance 'mnas-sdl3-gui/widgets:button
                                       :x 770 :y 48 :width 90 :height 30
                                       :text "Refresh"
                                       :on-click (lambda (widget)
                                                   (declare (ignore widget))
                                                   (tree-01-command :tree-01/load))))
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
                                                 (tree-01-command :tree-01/load))))
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
    (tree-01-sync-command-state)
    *tree-01-widgets*))

(sdl3:def-app-init tree-01-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Filesystem Tree Demo" "1.0"
                         "com.mna.sdl3.gui.tree-01.demo")
  (when (not (sdl3:init :video))
    (format t "~A~%" (sdl3:get-error))
    (return-from tree-01-init :failure))
  (setf *tree-01-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Filesystem Tree Demo" 960 620 0)
    (if (not ok)
        (progn
          (format t "~A~%" (sdl3:get-error))
          (return-from tree-01-init :failure))
        (progn
          (setf *tree-01-window* window
                *tree-01-renderer* renderer
                *tree-01-window-id* (sdl3:get-window-id window)
                *tree-01-open* t)
          (mnas-sdl3-gui/window-manager:register-window
           *tree-01-layer-manager*
           *tree-01-window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *tree-01-layer-manager*
           *tree-01-window-id*)
          (tree-01-register-commands)
          (tree-01-register-shortcuts)
          (setf *tree-01-toolbar* (make-tree-01-toolbar))
          (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *tree-01-toolbar*)
          (mnas-sdl3-gui/widgets:set-widget-style *tree-01-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (mnas-sdl3-gui/widgets:start-widget-text-input window)
          (create-tree-01-widgets)
          (tree-01-sync-command-state)
          (mnas-sdl3-gui/widgets:set-widget-focus *tree-01-widgets* *tree-01-tree*))))
  :continue)

(sdl3:def-app-iterate tree-01-iterate ()
  (unless *tree-01-open*
    (return-from tree-01-iterate :success))
    (sdl3:set-render-draw-color *tree-01-renderer* 242 242 242 255)
    (sdl3:render-clear *tree-01-renderer*)
    (tree-01-sync-command-state)
      (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *tree-01-widgets*)
        do (mnas-sdl3-gui/widgets:render *tree-01-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))
  (mnas-sdl3-gui/toolbar:render-toolbar
   *tree-01-toolbar*
   *tree-01-renderer*
   +tree-01-toolbar-x+
   +tree-01-toolbar-y+)
  (sdl3:render-present *tree-01-renderer*)
  :continue)

(sdl3:def-app-event tree-01-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (tree-01-command :tree-01/quit)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *tree-01-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *tree-01-layer-manager*
                              window-id))))
           (case action
             (:close-root
              (tree-01-command :tree-01/quit)
              (return-from tree-01-event :success))
             (otherwise
              (tree-01-command :tree-01/quit)
              (return-from tree-01-event :success)))))
       :continue)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:handle-widget-mouse-motion
        *tree-01-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) +tree-01-mouse-left+)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *tree-01-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                           *tree-01-layer-manager*
                                           window-id)
                                          window-id)
                                      window-id)))
           (when *tree-01-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *tree-01-layer-manager*
              target-window-id))
           (when (= target-window-id *tree-01-window-id*)
             (if (and (slot-value ev 'sdl3:%down)
                      (and *tree-01-toolbar*
                           (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                            *tree-01-toolbar*
                            (- (round (slot-value ev 'sdl3:%x)) (round +tree-01-toolbar-x+))
                            (- (round (slot-value ev 'sdl3:%y)) (round +tree-01-toolbar-y+)))) )
                 (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                  *tree-01-toolbar*
                  (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                   *tree-01-toolbar*
                   (- (round (slot-value ev 'sdl3:%x)) (round +tree-01-toolbar-x+))
                   (- (round (slot-value ev 'sdl3:%y)) (round +tree-01-toolbar-y+)))
                  (list :window-id target-window-id))
                 (mnas-sdl3-gui/widgets:handle-mouse-button-event *tree-01-widgets* ev)))))
       :continue)
      (sdl3:mouse-wheel-event
       (mnas-sdl3-gui/widgets:handle-widget-mouse-wheel
        *tree-01-widgets*
        (round (slot-value ev 'sdl3:%mouse-x))
        (round (slot-value ev 'sdl3:%mouse-y))
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
          (let* ((event-window-id (slot-value ev 'sdl3:%window-id))
            (target-window-id (if *tree-01-layer-manager*
                   (or (mnas-sdl3-gui/window-manager:keyboard-target-window-id
                   *tree-01-layer-manager*
                   event-window-id)
                  event-window-id)
                   event-window-id)))
            (when *tree-01-layer-manager*
              (mnas-sdl3-gui/window-manager:set-focused-window
          *tree-01-layer-manager*
          target-window-id))
            (unless (mnas-sdl3-gui/commands:dispatch-shortcut
                (slot-value ev 'sdl3:%key)
                :mods (slot-value ev 'sdl3:%mod)
                :context (list :window-id target-window-id))
                    (mnas-sdl3-gui/widgets:handle-widget-key-event
                 *tree-01-widgets*
                 (slot-value ev 'sdl3:%key)
                 nil
                 :mods (slot-value ev 'sdl3:%mod)
                 :on-escape (lambda ()
                  (tree-01-command :tree-01/quit)
                  :success)
                 :on-return (lambda ()
                  (tree-01-command :tree-01/load)
                  :continue)))))
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
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *tree-01-window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun tree-01 (&optional (style :flat))
  "Run filesystem tree demo." 
  (setf *tree-01-window* nil
        *tree-01-renderer* nil
        *tree-01-window-id* 0
        *tree-01-layer-manager* nil
        *tree-01-toolbar* nil
        *tree-01-open* t
        *tree-01-style* style
        *tree-01-widgets* nil
        *tree-01-status* "Ready"
        *tree-01-root-entry* nil
        *tree-01-filter-entry* nil
        *tree-01-sort-combo* nil
        *tree-01-show-hidden* nil
        *tree-01-tree* nil
        *tree-01-status-label* nil)
  (sdl3:enter-app-main-callbacks
   'tree-01-init
   'tree-01-iterate
   'tree-01-event
   'tree-01-quit))

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/tree)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/tree-01)
;;;; (tree-01)

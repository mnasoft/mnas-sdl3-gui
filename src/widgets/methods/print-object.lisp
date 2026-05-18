;;;; ./src/widgets/methods/print-object.lisp

(in-package :mnas-sdl3-gui/widgets)

(defun %print-widget-core (obj stream)
  (format stream "x=~A y=~A w=~A h=~A enabled=~A focused=~A visible=~A value=~S"
          (widget-x obj)
          (widget-y obj)
          (widget-width obj)
          (widget-height obj)
          (widget-enabled obj)
          (widget-focused obj)
          (widget-visible obj)
          (widget-value obj)))

(defmethod print-object ((obj widget) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)))

(defmethod print-object ((obj label) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " text=~S" (label-text obj))))

(defmethod print-object ((obj button) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " text=~S pressed=~A armed=~A"
            (button-text obj)
            (button-pressed-p obj)
            (button-armed-p obj))))

(defmethod print-object ((obj toggle) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " label=~S state=~A group=~S"
            (toggle-label obj)
            (toggle-state obj)
            (toggle-group obj))))

(defmethod print-object ((obj check-box) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " label=~S checked=~A"
            (check-box-label obj)
            (check-box-checked obj))))

(defmethod print-object ((obj entry) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream "text=~S cursor=~A scroll=~A sel=~A..~A max=~A"
            (entry-text obj)
            (entry-cursor obj)
            (entry-scroll-offset obj)
            (entry-selection-start obj)
            (entry-selection-end obj)
            (entry-max-length obj))))

(defmethod print-object ((obj tree-node) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "id=~S text=~S kind=~S path=~S loaded=~A mtime=~S children=~A expanded=~A"
            (tree-node-id obj)
            (tree-node-text obj)
            (tree-node-kind obj)
            (tree-node-path obj)
            (tree-node-children-loaded-p obj)
            (tree-node-modified-time obj)
            (length (tree-node-children obj))
            (tree-node-expanded-p obj))))

(defmethod print-object ((obj tree-view) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " roots=~A selected=~S root-path=~S hidden=~A filter=~S sort=~S max-depth=~S row-height=~A indent=~A"
            (length (tree-view-roots obj))
            (tree-view-selected-node obj)
            (tree-view-root-path obj)
            (tree-view-show-hidden-p obj)
            (tree-view-filter-extensions obj)
            (tree-view-sort-mode obj)
            (tree-view-max-depth obj)
            (tree-view-row-height obj)
            (tree-view-indent-width obj))))

(defmethod print-object ((obj password-entry) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream "text=~S cursor=~A scroll=~A sel=~A..~A max=~A"
            "***"
            (entry-cursor obj)
            (entry-scroll-offset obj)
            (entry-selection-start obj)
            (entry-selection-end obj)
            (entry-max-length obj))))

(defmethod print-object ((obj list-box) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " items=~A selected=~A scroll=~A drag=~A item-height=~A"
            (length (list-box-items obj))
            (list-box-selected-index obj)
            (list-box-scroll-offset obj)
            (list-box-scrollbar-dragging-p obj)
            (list-box-item-height obj))))

(defmethod print-object ((obj combo-box) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " items=~A selected=~A expanded=~A scroll=~A max-visible=~A"
            (length (list-box-items obj))
            (list-box-selected-index obj)
            (combo-box-expanded-p obj)
            (list-box-scroll-offset obj)
            (combo-box-max-visible-items obj))))

(defmethod print-object ((obj widget-style) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "name=~A" (widget-style-name obj))))

(defmethod print-object ((obj flat-widget-style) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "name=~A" (widget-style-name obj))))

(defmethod print-object ((obj windows-widget-style) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "name=~A" (widget-style-name obj))))

(defmethod print-object ((obj motif-widget-style) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (format stream "name=~A" (widget-style-name obj))))
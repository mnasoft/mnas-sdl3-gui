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

(defmethod print-object ((obj edit-box) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream "text=~S cursor=~A scroll=~A sel=~A..~A max=~A"
            (edit-box-text obj)
            (edit-box-cursor obj)
            (edit-box-scroll-offset obj)
            (edit-box-selection-start obj)
            (edit-box-selection-end obj)
            (edit-box-max-length obj))))

(defmethod print-object ((obj list-box) stream)
  (print-unreadable-object (obj stream :type t :identity t)
    (%print-widget-core obj stream)
    (format stream " items=~A selected=~A item-height=~A"
            (length (list-box-items obj))
            (list-box-selected-index obj)
            (list-box-item-height obj))))

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
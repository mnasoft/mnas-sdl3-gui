;;;; ./src/widgets/methods/children.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Default children accessor and mutator. Keep delegating to the existing
;; `<widget-container>-children` slot accessor for backward compatibility until slot
;; migration completes.

(defmethod children :around ((widget <widget>))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod children ((widget <widget>))
  (<widget-container>-children widget))

(defmethod children ((widget <widget-container>))
  (<widget-container>-children widget))

(defmethod (setf children) (newlist (widget <widget>))
  (setf (<widget-container>-children widget) newlist)
  newlist)

(defmethod (setf children) (newlist (widget <widget-container>))
  (setf (<widget-container>-children widget) newlist)
  newlist)

;; If toolbar stores buttons in a legacy `buttons` slot, keep both in sync.
(defmethod children ((tb <toolbar>))
  (let ((kids (<widget-container>-children tb)))
    (if (and (null kids)
             (slot-boundp tb 'buttons)
             (not (null (slot-value tb 'buttons))))
          ;; Legacy: expose buttons as children
          (slot-value tb 'buttons)
          kids))
        )

(defmethod (setf children) (newlist (tb <toolbar>))
  ;; update both <widget-container>-children and legacy buttons slot for compatibility
  (setf (<widget-container>-children tb) newlist)
  (when (slot-boundp tb 'buttons)
    (setf (slot-value tb 'buttons) newlist))
  newlist)

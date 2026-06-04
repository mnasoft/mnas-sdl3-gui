;;;; ./src/widgets/methods/children.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Default children accessor and mutator. Keep delegating to the existing
;; `widget-children` slot accessor for backward compatibility until slot
;; migration completes.

(defmethod children :around ((widget widget))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod children ((widget widget))
  (widget-children widget))

(defmethod children ((widget widget-container))
  (widget-children widget))

(defmethod (setf children) (newlist (widget widget))
  (setf (widget-children widget) newlist)
  newlist)

(defmethod (setf children) (newlist (widget widget-container))
  (setf (widget-children widget) newlist)
  newlist)

;; If toolbar stores buttons in a legacy `buttons` slot, keep both in sync.
(defmethod children ((tb mnas-sdl3-gui/widgets:toolbar))
  (let ((kids (widget-children tb)))
    (if (and (null kids)
             (slot-boundp tb 'buttons)
             (not (null (slot-value tb 'buttons))))
          ;; Legacy: expose buttons as children
          (slot-value tb 'buttons)
          kids))
        )

(defmethod (setf children) (newlist (tb mnas-sdl3-gui/widgets:toolbar))
  ;; update both widget-children and legacy buttons slot for compatibility
  (setf (widget-children tb) newlist)
  (when (slot-boundp tb 'buttons)
    (setf (slot-value tb 'buttons) newlist))
  newlist)

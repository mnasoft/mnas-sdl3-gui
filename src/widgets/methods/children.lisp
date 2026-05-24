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

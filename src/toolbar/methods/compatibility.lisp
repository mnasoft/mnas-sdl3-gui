;;;; ./src/toolbar/methods/compatibility.lisp

(in-package :mnas-sdl3-gui/toolbar)

;; Compatibility shim: allow callers to use the old `toolbar-buttons` accessor
;; on widgetized `mnas-sdl3-gui/widgets:toolbar` instances.
;;; Use the widgets package accessors to avoid referencing slots across packages.
(defmethod (setf toolbar-buttons) (newlist (tb mnas-sdl3-gui/widgets:toolbar))
  (declare (type list newlist))
  ;; update widget children via widget package accessor
  (setf (mnas-sdl3-gui/widgets:children tb) newlist)
  ;; also try to update widgets-package toolbar-buttons accessor if present
  (ignore-errors (setf (mnas-sdl3-gui/widgets:toolbar-buttons tb) newlist))
  newlist)

(defmethod toolbar-buttons ((tb mnas-sdl3-gui/widgets:toolbar))
  ;; Prefer widget children; fall back to widgets-package toolbar-buttons if children empty
  (let ((kids (mnas-sdl3-gui/widgets:children tb)))
    (if (and (null kids))
        (ignore-errors (mnas-sdl3-gui/widgets:toolbar-buttons tb))
        kids)))

;;;; ./src/widgets/methods/enabled-p.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Default `enabled-p` predicate delegating to existing `widget-enabled` slot
;; accessor for backward compatibility during migration.

(defmethod enabled-p ((widget widget))
  (widget-enabled widget))

(defmethod enabled-p ((widget widget-container))
  (widget-enabled widget))

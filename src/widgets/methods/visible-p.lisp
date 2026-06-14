;;;; ./src/widgets/methods/visible-p.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Default `visible-p` predicate delegating to existing `<widget>-visible` slot
;; accessor to keep backward compatibility while switching callsites to the
;; generic API.

(defmethod visible-p ((obj <widget>))
  (<widget>-visible obj))

(defmethod visible-p ((obj <widget-container>))
  (<widget>-visible obj))

;;;; ./src/widgets/<toggle>-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; <toggle>-group helpers

(defparameter *toggle-groups* (make-hash-table :test #'equal)
  "Registry of grouped <toggle>s keyed by group designator.")

(defun clear-toggle-group-registry ()
  "Remove all registered <toggle> groups."
  (clrhash *toggle-groups*))


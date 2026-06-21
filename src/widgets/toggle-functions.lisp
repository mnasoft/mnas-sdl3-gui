;;;; ./src/widgets/<toggle>-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; <toggle>-group helpers

(defparameter *<toggle>-groups* (make-hash-table :test #'equal)
  "Registry of grouped <toggle>s keyed by group designator.")

(defun clear-toggle-group-registry ()
  "Remove all registered <toggle> groups."
  (clrhash *<toggle>-groups*))

(defun register-<toggle>-group-member (widget)
  "Register WIDGET in the <toggle> group registry when it belongs to a group."
  (let ((group (<toggle>-group widget)))
    (when group
      (pushnew widget (gethash group *<toggle>-groups*) :test #'eq))))

(defun select-<toggle>-in-group (widget)
  "Select WIDGET and clear all other <toggle>s from the same group."
  (let ((group (<toggle>-group widget)))
    (setf (<toggle>-state widget) t)
    (update-<widget>-value widget t)
    (when group
      (dolist (member (gethash group *<toggle>-groups*))
        (unless (eq member widget)
          (when (<toggle>-state member)
            (setf (<toggle>-state member) nil)
            (update-<widget>-value member nil)))))))

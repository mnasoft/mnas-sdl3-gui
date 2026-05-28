;;;; ./src/app/functions.lisp

(in-package :mnas-sdl3-gui/app)

;; Application-level quit hooks
(defvar *app-quit-hooks* nil
  "List of functions called when the application quits. Each function is called with one
optional argument: the quit RESULT passed by the app framework.")

(defun add-quit-hook (fn)
  "Register FN to be called when the application quits. Returns FN.
FN should be a function accepting zero or one argument." 
  (when (and fn (functionp fn))
    (pushnew fn *app-quit-hooks* :test #'eq))
  fn)

(defun remove-quit-hook (fn)
  "Remove FN from registered quit hooks." 
  (setf *app-quit-hooks* (remove fn *app-quit-hooks* :test #'eq))
  nil)

(defun clear-quit-hooks ()
  "Clear all registered quit hooks." 
  (setf *app-quit-hooks* '())
  nil)

(defun run-quit-hooks (&optional result)
  "Run all registered app quit hooks with optional RESULT.
Hooks are run inside handler-case to avoid aborting the quit sequence.
After hooks run, attempt to clear widget window-id registry and then clear hooks." 
  (dolist (fn (reverse *app-quit-hooks*))
    (handler-case
        (funcall fn result)
      (error (e) (format t "[app] quit-hook error: ~A~%" e))))
  (let ((pkg (find-package :mnas-sdl3-gui/widgets)))
    (when pkg
      (let ((fn (intern "CLEAR-WINDOW-WIDGET-REGISTRY" pkg)))
        (when (fboundp fn)
          (ignore-errors (funcall (symbol-function fn)))))))
  (clear-quit-hooks)
  t)

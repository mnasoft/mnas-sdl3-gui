;;;; ./src/commands/shortcuts.lisp

(in-package :mnas-sdl3-gui/commands)

(defparameter *shortcut-registry* (make-hash-table :test #'equal)
  "Registry mapping (scope key mods) to command ids.")

(defun normalize-shortcut-mods (mods)
  "Normalize MODS to :ANY, NIL, or a stable list form." 
  (cond
    ((eq mods :any) :any)
    ((null mods) nil)
    ((listp mods)
     (sort (copy-list mods) #'string< :key #'prin1-to-string))
    (t mods)))

(defun shortcut-key (scope key mods)
  "Build registry key triple for shortcut mapping." 
  (list (or scope :global)
        key
        (normalize-shortcut-mods mods)))

(defun clear-shortcut-registry (&optional scope)
  "Clear all shortcuts, or only shortcuts for SCOPE." 
  (if (null scope)
      (clrhash *shortcut-registry*)
      (maphash (lambda (k v)
                 (declare (ignore v))
                 (when (eql (first k) scope)
                   (remhash k *shortcut-registry*)))
               *shortcut-registry*))
  t)

(defun register-shortcut (command-id key &key (scope :global) (mods :any) replace)
  "Register KEY shortcut for COMMAND-ID in SCOPE.
If REPLACE is NIL and mapping exists, signal an error." 
  (let* ((k (shortcut-key scope key mods))
         (existing (gethash k *shortcut-registry*)))
    (when (and existing (not replace))
      (error "Shortcut ~S already registered for ~S." k existing))
    (setf (gethash k *shortcut-registry*) command-id)
    command-id))

(defun find-shortcut-command (key &key (scope :global) mods)
  "Find command id mapped to KEY for SCOPE and MODS with fallbacks." 
  (let* ((mods* (normalize-shortcut-mods mods))
         (candidates (remove-duplicates
                      (list (shortcut-key scope key mods*)
                            (shortcut-key scope key :any)
                            (shortcut-key :global key mods*)
                            (shortcut-key :global key :any))
                      :test #'equal)))
    (loop for k in candidates
          for cmd = (gethash k *shortcut-registry*)
          when cmd do (return cmd)
          finally (return nil))))

(defun dispatch-shortcut (key &key (scope :global) mods context)
  "Dispatch KEY in SCOPE through command dispatcher.
Returns non-NIL when a mapped command was executed." 
  (let ((command-id (find-shortcut-command key :scope scope :mods mods)))
    (when command-id
      (execute-command command-id :context context))))

;;;; ./src/commands/shortcuts.lisp

(in-package :mnas-sdl3-gui/commands)

(defparameter *shortcut-registry* (make-hash-table :test #'equal)
  "Registry mapping (key mods) to command ids.")

(defun normalize-shortcut-key (key)
  "Normalize KEY to a stable keyword form for shortcut lookup."
  (cond
    ((null key) nil)
    ((keywordp key)
     (intern (string-downcase (string key)) :keyword))
    ((symbolp key)
     (intern (string-downcase (symbol-name key)) :keyword))
    ((characterp key)
     (intern (string-downcase (string key)) :keyword))
    ((stringp key)
     (intern (string-downcase key) :keyword))
    (t key)))

(defun normalize-shortcut-mods (mods)
  "Normalize MODS to :ANY, NIL, or a stable list form." 
  (cond
    ((eq mods :any) :any)
    ((null mods) nil)
    ((listp mods)
     (sort (copy-list mods) #'string< :key #'prin1-to-string))
    (t mods)))

(defun shortcut-key (key mods)
  "Build registry key pair for shortcut mapping." 
  (list (normalize-shortcut-key key) (normalize-shortcut-mods mods)))

(defun clear-shortcut-registry ()
  "Clear all shortcuts." 
  (clrhash *shortcut-registry*)
  t)

(defun register-shortcut (command-id key &key (mods :any) replace)
  "Register KEY shortcut for COMMAND-ID globally.
If REPLACE is NIL and mapping exists, signal an error." 
  (let* ((k (shortcut-key key mods))
         (existing (gethash k *shortcut-registry*)))
    (when (and existing (not replace))
      (error "Shortcut ~S already registered for ~S." k existing))
    (setf (gethash k *shortcut-registry*) command-id)
    command-id))

(defun find-shortcut-command (key &key mods)
  "Find command id mapped to KEY and MODS with fallback to :any." 
  (let* ((key* (normalize-shortcut-key key))
         (mods* (normalize-shortcut-mods mods))
         (candidates (remove-duplicates
                      (list (shortcut-key key* mods*)
                            (shortcut-key key* :any))
                      :test #'equal)))
    (loop for k in candidates
          for cmd = (gethash k *shortcut-registry*)
          when cmd do (return cmd)
          finally (return nil))))

(defun dispatch-shortcut (key &key mods context)
  "Dispatch KEY through command dispatcher.
Returns non-NIL when a mapped command was executed." 
  (let ((command-id (find-shortcut-command (normalize-shortcut-key key) :mods mods)))
    (when command-id
      (execute-command command-id :context context))))

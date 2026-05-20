;;;; ./src/commands/functions.lisp

(in-package :mnas-sdl3-gui/commands)

(defclass command ()
  ((id :initarg :id :accessor command-id
       :documentation "Unique command id, usually keyword or symbol.")
   (title :initarg :title :initform "" :accessor command-title
          :documentation "Human-readable command title.")
   (group :initarg :group :initform nil :accessor command-group
          :documentation "Optional command group/category.")
   (enabled :initarg :enabled :initform t :accessor command-enabled
            :documentation "Static enabled switch for command.")
   (visible :initarg :visible :initform t :accessor command-visible
            :documentation "Whether command is visible in presenters.")
   (checked :initarg :checked :initform nil :accessor command-checked
            :documentation "Toggle/radio checked state.")
   (shortcut :initarg :shortcut :initform nil :accessor command-shortcut
             :documentation "Optional shortcut descriptor.")
   (execute :initarg :execute :initform nil :accessor command-execute
            :documentation "Function of one argument CONTEXT that performs command action.")
   (can-execute :initarg :can-execute :initform nil :accessor command-can-execute
                :documentation "Optional predicate of one argument CONTEXT.")
   )
  (:documentation "Unified command model entity used by menu/toolbar/popup presenters."))

(defparameter *command-registry* (make-hash-table :test #'equal)
  "Global registry mapping command ids to COMMAND objects.")

(defun normalize-command-id (id)
  "Normalize command id to a stable hash key." 
  (etypecase id
    (keyword id)
    (symbol (intern (string-upcase (symbol-name id)) :keyword))
    (string (intern (string-upcase id) :keyword))))

(defun make-command (id title &key group enabled visible checked shortcut execute can-execute)
  "Construct a COMMAND object with common keyword options." 
  (make-instance 'command
                 :id id
                 :title title
                 :group group
                 :enabled (if (null enabled) t enabled)
                 :visible (if (null visible) t visible)
                 :checked checked
                 :shortcut shortcut
                 :execute execute
                 :can-execute can-execute))

(defun clear-command-registry ()
  "Remove all commands from registry." 
  (clrhash *command-registry*))

(defun register-command (cmd &key replace)
  "Register CMD in command registry.
When REPLACE is NIL and id already exists, signal an error." 
  (let* ((id (normalize-command-id (command-id cmd)))
         (existing (gethash id *command-registry*)))
    (when (and existing (not replace))
      (error "Command ~S already registered." id))
    (setf (gethash id *command-registry*) cmd)
    cmd))

(defun find-command (id)
  "Find command by ID or NIL." 
  (gethash (normalize-command-id id) *command-registry*))

(defun list-commands ()
  "Return all registered commands as a list." 
  (let (result)
    (maphash (lambda (id cmd)
               (declare (ignore id))
               (push cmd result))
             *command-registry*)
    (nreverse result)))

(defun command-enabled-p (cmd &optional context)
  "Return T when CMD can be executed in CONTEXT." 
  (and (command-enabled cmd)
       (let ((predicate (command-can-execute cmd)))
         (if predicate
             (funcall predicate context)
             t))))

(defun execute-command (id-or-command &key context)
  "Execute command and return true value on success.
ID-OR-COMMAND may be a command id or a COMMAND object." 
  (let* ((cmd (if (typep id-or-command 'command)
                  id-or-command
                  (find-command id-or-command)))
         (runner (and cmd (command-execute cmd))))
    (when (and cmd runner (command-enabled-p cmd context))
      (funcall runner context))))

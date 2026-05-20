;;;; ./src/commands/package.lisp

(defpackage :mnas-sdl3-gui/commands
  (:nicknames :gui/commands)
  (:use #:cl)
  (:export
   #:command
   #:command-id
   #:command-title
   #:command-group
   #:command-enabled
   #:command-visible
   #:command-checked
   #:command-shortcut
   #:command-execute
   #:command-can-execute
   #:*command-registry*
   #:make-command
   #:clear-command-registry
   #:register-command
   #:find-command
   #:list-commands
   #:command-enabled-p
   #:execute-command))

(in-package :mnas-sdl3-gui/commands)

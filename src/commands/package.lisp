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
  #:*command-change-hooks*
  #:register-command-change-hook
  #:run-command-change-hooks
  #:set-command-enabled
  #:set-command-visible
  #:set-command-checked
  #:execute-command
  #:*shortcut-registry*
  #:clear-shortcut-registry
  #:register-shortcut
  #:find-shortcut-command
  #:dispatch-shortcut))

(in-package :mnas-sdl3-gui/commands)

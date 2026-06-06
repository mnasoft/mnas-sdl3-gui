;;;; ./src/commands/package.lisp

(defpackage :mnas-sdl3-gui/commands
  (:nicknames :gui/commands)
  (:use #:cl)
  (:export #:command
           #:command-id
           #:command-title
           #:command-group
           #:command-enabled
           #:command-visible
           #:command-checked
           #:command-shortcut
           #:command-execute
           #:command-can-execute
           )
  (:export #:*command-registry*
           )
  (:export #:clear-command-registry
           #:register-command
           #:find-command
           #:list-commands
           #:command-enabled-p
           #:make-command
           )
  (:export #:*shortcut-registry*
           )
  (:export #:clear-shortcut-registry
           #:register-shortcut
           #:find-shortcut-command
           #:dispatch-shortcut
           )
  (:export #:*command-change-hooks*
           #:register-command-change-hook
           #:run-command-change-hooks
           )
  (:export #:set-command-enabled
           #:set-command-visible
           #:set-command-checked
           #:execute-command
           ))

(in-package :mnas-sdl3-gui/commands)

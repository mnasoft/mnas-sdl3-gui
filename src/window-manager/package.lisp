;;;; ./src/window-manager/package.lisp

(defpackage :mnas-sdl3-gui/window-manager
  (:nicknames :gui/window-manager)
  (:use #:cl)
  (:export
   #:managed-window
   #:window-layer-manager
   #:managed-window-id
   #:managed-window-role
   #:managed-window-parent-id
   #:managed-window-open-p
   #:managed-window-z-index
   #:managed-window-payload
  #:manager-modal-stack
   #:make-window-layer-manager
   #:clear-window-layer-manager
   #:register-window
   #:unregister-window
   #:find-window
   #:window-open-p
   #:open-window
   #:close-window
   #:window-children
  #:transient-role-p
  #:active-modal-id
  #:active-modal-window
  #:close-tooltips
  #:open-modal-window
  #:close-modal-window
  #:event-target-window-id
   #:close-transients-for-parent
   #:top-open-window-ids
   #:close-action))

(in-package :mnas-sdl3-gui/window-manager)

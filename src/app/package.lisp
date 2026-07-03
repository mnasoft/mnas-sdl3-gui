;;;; ./src/app/package.lisp

(defpackage #:mnas-sdl3-gui/app
  (:use #:cl)
  (:export #:<app>
           #:<app>-title
           #:<app>-width
           #:<app>-height
           #:<app>-style
           #:<app>-window
           #:<app>-window-id
           #:<app>-renderer
           #:<app>-layer-manager
           #:<app>-toolbar
           #:<app>-open-p
           #:<app>-status
           #:<app>-widgets
           #:<app>-result
           #:initialize-application
           #:render-application
           #:handle-application-event
           #:finalize-application
           #:add-quit-hook
           #:remove-quit-hook
           #:run-quit-hooks
           #:clear-quit-hooks))

(in-package #:mnas-sdl3-gui/app)

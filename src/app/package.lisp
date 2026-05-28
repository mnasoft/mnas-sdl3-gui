;;;; ./src/app/package.lisp

(defpackage #:mnas-sdl3-gui/app
  (:use #:cl)
  (:export
   #:add-quit-hook
   #:remove-quit-hook
   #:run-quit-hooks
   #:clear-quit-hooks))

(in-package #:mnas-sdl3-gui/app)

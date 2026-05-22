;;;; ./demos/package.lisp

(defpackage :mnas-sdl3-gui/demos
  (:use #:cl))

(in-package :mnas-sdl3-gui/demos)

;; Load subpackages lazily; demos may define their own package files.

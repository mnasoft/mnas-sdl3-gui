;;;; ./src/mnas-sdl3-gui.lisp

(defpackage #:mnas-sdl3-gui
  (:use #:cl)
  (:export #:project-name
           #:hello))

(in-package #:mnas-sdl3-gui)

(defun project-name ()
  "Return the ASDF system name."
  "mnas-sdl3-gui")

(defun hello ()
  "Return a smoke-check message."
  "Hello from mnas-sdl3-gui")

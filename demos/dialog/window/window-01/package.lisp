;;;; ./demos/dialog/window/window-01/package.lisp

(defpackage :mnas-sdl3-gui/demos/dialog/window-01
  (:use #:cl)
  (:export #:main
           #:window-01
           #:fullscreen
           #:opengl
           #:occluded
           #:hidden
           #:borderless
           #:resizable
           #:minimized
           #:maximized
           #:mouse-grabbed
           #:input-focus
           #:mouse-focus
           #:external
           #:modal
           #:high-pixel-density
           #:mouse-capture
           #:mouse-relative-mode
           #:always-on-top
           #:utility
           #:tooltip
           #:popup-menu
           #:keyboard-grabbed
           #:vulkan
           #:metal
           #:transparent
           #:not-focusable
           #:all-flags
           #:modal-stack-runtime
           #:open-modal-1
           #:open-modal-2
           #:close-top-modal
           #:register-commands
           #:register-shortcuts))

(in-package :mnas-sdl3-gui/demos/dialog/window-01)

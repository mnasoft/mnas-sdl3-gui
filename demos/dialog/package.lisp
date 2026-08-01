;;;; ./demos/dialog/package.lisp

(defpackage :mnas-sdl3-gui/demos/dialog
  (:use #:cl)
  (:export #:do-entry-dialog-demo
           #:do-check-box-demo
           #:do-pack-layout-demo
           #:do-two-list-boxes-demo
           #:do-combo-box-demo
           #:do-editable-combo-box-demo
           #:do-tree-demo))

(in-package :mnas-sdl3-gui/demos/dialog)

;;;; (ql:quickload :mnas-sdl3-gui/demos)

;;;; (do-entry-dialog-demo)
;;;; (do-check-box-demo)
;;;; (do-pack-layout-demo)
;;;; (do-two-list-boxes-demo)
;;;; (do-combo-box-demo)

(defun do-entry-dialog-demo (&optional (style :flat))
  "Run the entry demo dialog from the entry-01 package."
  (mnas-sdl3-gui/demos/dialog/entry-01:entry-01 style))

(defun do-check-box-demo (&optional (style :windows))
  "Run the check-box demo dialog."
  (mnas-sdl3-gui/demos/dialog/check-box-01:check-box-01 style))

(defun do-pack-layout-demo (&optional (style :windows))
  "Run the pack-layout demo dialog."
  (mnas-sdl3-gui/demos/dialog/pack-01:pack-01 style))

(defun do-two-list-boxes-demo (&optional (style :windows))
  "Run the two-list-boxes demo dialog."
  (mnas-sdl3-gui/demos/dialog/list-box-01:list-box-01 style))

(defun do-combo-box-demo (&optional (style :windows))
  "Run the primary combo-box demo dialog."
  (mnas-sdl3-gui/demos/dialog/combo-box-01:combo-box-01 style))

(defun do-editable-combo-box-demo (&optional (style :flat))
  "Run the editable combo-box demo dialog."
  (mnas-sdl3-gui/demos/dialog/combo-box-02:combo-box-02 style))

(defun do-tree-demo (&optional (style :flat))
  "Run the filesystem tree demo dialog."
  (mnas-sdl3-gui/demos/dialog/tree-01:tree-01 style))


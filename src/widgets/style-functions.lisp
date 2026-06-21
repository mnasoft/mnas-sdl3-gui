;;;; ./src/widgets/style-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Rendering style helpers

(defparameter *widget-style* (make-instance '<flat-widget-style>)
  "Current widget rendering style.")

(defun widget-style-name (style)
  "Return keyword designator for STYLE instance."
  (typecase style
    (<windows-widget-style> :windows)
    (<motif-widget-style> :motif)
    (<flat-widget-style> :flat)
    (t :flat)))

(defun make-widget-style (style-designator)
  "Create widget style object from keyword or return existing instance."
  (typecase style-designator
    (<widget-style> style-designator)
    ((eql :windows) (make-instance '<windows-widget-style>))
    ((eql :motif) (make-instance '<motif-widget-style>))
    ((or (eql :flat) null) (make-instance '<flat-widget-style>))
    (t (error "Unknown widget style: ~a" style-designator))))

(defun set-widget-style (style-designator)
  "Set current widget rendering style. Returns the style instance."
  (setf *widget-style* (make-widget-style style-designator)))

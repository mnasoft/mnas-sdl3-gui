;;;; ./src/widgets/classes-grid.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Grid container

(defclass grid-child-constraint ()
  ((row
    :initarg :row :initform 0 :accessor grid-child-row)
   (col
    :initarg :col :initform 0 :accessor grid-child-col)
   (row-span
    :initarg :row-span :initform 1 :accessor grid-child-row-span)
   (col-span
    :initarg :col-span :initform 1 :accessor grid-child-col-span)
   (halign
    :initarg :halign :initform :fill :accessor grid-child-halign)
   (valign
    :initarg :valign :initform :fill :accessor grid-child-valign)
   (weight-x
    :initarg :weight-x :initform 0 :accessor grid-child-weight-x)
   (weight-y
    :initarg :weight-y :initform 0 :accessor grid-child-weight-y)))

(defclass grid-container (<widget-container>)
  ((rows
    :initarg :rows :initform 1 :accessor grid-rows
    :documentation "Number of rows in the grid")
   (cols
    :initarg :cols :initform 1 :accessor grid-cols
    :documentation "Number of columns in the grid")
   (child-constraints
    :initarg :child-constraints :initform nil :accessor grid-child-constraints
    :documentation "Alist of (child . grid-child-constraint)")
   (row-spacing
    :initarg :row-spacing :initform 4 :accessor grid-row-spacing)
   (col-spacing
    :initarg :col-spacing :initform 4 :accessor grid-col-spacing)
   (padding
    :initarg :padding :initform 4 :accessor grid-padding))
  (:documentation "Grid layout container with row/column spans and weights."))

(defun make-grid (&key (rows 1) (cols 1) (children nil) (row-spacing 4) (col-spacing 4) (padding 4))
  "Create a new `grid-container'. CHILDREN can be provided as a list; constraints are added via `grid-add-child'."
  (make-instance 'grid-container :rows rows :cols cols :children children
                 :row-spacing row-spacing :col-spacing col-spacing :padding padding))

(defun grid-add-child (grid child &key (row 0) (col 0) (row-span 1) (col-span 1)
                                 (halign :fill) (valign :fill) (weight-x 0) (weight-y 0))
  "Add CHILD to GRID with cell constraints. Returns CHILD."
  (push child (children grid))
  (let ((c (make-instance 'grid-child-constraint :row row :col col :row-span row-span :col-span col-span
                          :halign halign :valign valign :weight-x weight-x :weight-y weight-y)))
    (setf (grid-child-constraints grid)
        (acons child c (grid-child-constraints grid)))
    child))


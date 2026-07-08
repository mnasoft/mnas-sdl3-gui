;;;; ./src/widgets/methods/normalize-item.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Compatibility helpers for list-box items operate directly on the
;; inherited children container state.

;;;; normalize-list-box-item -> normalize-item
#+nil 
(defun normalize-list-box-item (item)
  "Convert ITEM into a <list-box-item> object when needed."
  (cond
    ((typep item '<list-box-item>) item)
    ((typep item '<widget>) item)
    (t (make-instance
        '<list-box-item>
        :text (format nil "~a" item)))))

(defmethod normalize-item ((item t))
  (make-instance
        '<list-box-item>
        :text (format nil "~a" item)))

(defmethod normalize-item ((item <widget>))
    item)

(defmethod normalize-item ((item <list-box-item>))
  item)

;;;; normalize-list-box-items -> normalize-item
#+nil
(defun normalize-list-box-items (items)  
  (mapcar #'normalize-list-box-item items))

(defmethod normalize-item ((items cons))
  "Normalize a list of list-box items into <list-box-item> objects."
  (mapcar #'normalize-item items))

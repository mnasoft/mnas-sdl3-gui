;;;; ./demos/dialog/list-box/list-box-01/list-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(defparameter *window* nil)
(defparameter *window-id* 0)
(defparameter *toolbar* nil)
(defparameter *open* t)
(defparameter *result* nil)
(defparameter *style* :windows)
(defparameter *widgets* nil)
(defparameter *left* nil)
(defparameter *right* nil)
(defparameter *ok* nil)
(defparameter *cancel* nil)
(defparameter +list-box-01-window-height+ 352)
(defparameter +list-box-01-toolbar-height+ 32)

(defun list-box-01-command (id &rest context-plist)
  "Execute command ID with CONTEXT-PLIST." 
  (mnas-sdl3-gui/commands:execute-command id :context context-plist))

(defun list-box-01-register-commands ()
  "Register commands for list-box-01 demo." 
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/quit
    "Quit list-box demo"
    :group :list-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result* nil
                     *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/ok
    "Confirm list selection"
    :group :list-box-01
    :shortcut :enter
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result*
                     (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *left*)
                                      (mnas-sdl3-gui/widgets:list-box-items *left*))
                           :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *right*)
                                       (mnas-sdl3-gui/widgets:list-box-items *right*)))
                     *open* nil)
               t))
   :replace t)
  (mnas-sdl3-gui/commands:register-command
   (mnas-sdl3-gui/commands:make-command
    :list-box-01/cancel
    "Cancel list selection"
    :group :list-box-01
    :shortcut :escape
    :execute (lambda (context)
               (declare (ignore context))
               (setf *result* nil
                     *open* nil)
               t))
   :replace t))

(defun list-box-01-register-shortcuts ()
  "Register keyboard shortcuts for list-box-01 demo." 
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/quit :escape :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/ok :enter :replace t)
  (mnas-sdl3-gui/commands:register-shortcut :list-box-01/cancel :escape :replace t)
  t)

(defun list-box-01-create-toolbar ()
  "Create toolbar for list-box-01 demo." 
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:toolbar
                                :layout :horizontal
                                :height +list-box-01-toolbar-height+
                                :window *window*)))
    (setf (mnas-sdl3-gui/widgets:widget-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:toolbar-button
            :command-id :list-box-01/ok
            :label "OK"
            :width 56
            :window *window*)
           (make-instance
            'mnas-sdl3-gui/widgets:toolbar-button
            :command-id :list-box-01/cancel
            :label "Cancel"
            :width 72
            :window *window*)
           (make-instance
            'mnas-sdl3-gui/widgets:toolbar-button
            :command-id :list-box-01/quit
            :label "Quit"
            :width 64
            :window *window*)))
    toolbar))

(defun list-box-01-sync-command-state ()
  "Sync command state for list-box-01 toolbar." 
  (let* ((ok-cmd (mnas-sdl3-gui/commands:find-command :list-box-01/ok))
         (left-index
           (and
            *left*
            (mnas-sdl3-gui/widgets:list-box-selected-index *left*)))
         (right-index
           (and
            *right*
            (mnas-sdl3-gui/widgets:list-box-selected-index *right*))))
    (when ok-cmd
      (mnas-sdl3-gui/commands:set-command-enabled
       ok-cmd
       (and (integerp left-index)
            (<= 0 left-index (1- (length (mnas-sdl3-gui/widgets:list-box-items *left*))))
            (integerp right-index)
            (<= 0 right-index (1- (length (mnas-sdl3-gui/widgets:list-box-items *right*)))))))))

(defun list-box-01-items (count prefix)
  "Create COUNT demo strings prefixed by PREFIX."
  (loop for index from 1 to count
        collect (format nil "~A ~D" prefix index)))

(defun create-list-box-01-demo-widgets ()
  "Create widgets for the list-box-01 demo."
  (let ((title (make-instance
                'mnas-sdl3-gui/widgets:label
                :x 20
                :y 18
                :width 600
                :height 24
                :text "Two List-Boxes Demo"))
        (subtitle (make-instance
                   'mnas-sdl3-gui/widgets:label
                   :x 20
                   :y 42
                   :width 600
                   :height 22
                   :text "Слева 50 элементов, справа 4 элемента")))
    (setf *left*
          (make-instance
           'mnas-sdl3-gui/widgets:list-box
           :x 20 :y 74 :width 290 :height 170
           :items (list-box-01-items 50 "Элемент")
           :selected-index 0
           :item-height 24
           :window *window*)
          *right*
          (make-instance
           'mnas-sdl3-gui/widgets:list-box
           :x 330 :y 74 :width 290 :height 170
           :items (list-box-01-items 4 "Пункт")
           :selected-index 0
           :item-height 24
           :window *window*)
          *ok*
          (make-instance
           'mnas-sdl3-gui/widgets:button
           :x 350 :y 264 :width 120 :height 34
           :text "Ок"
           :on-click (lambda (widget)
                       (declare (ignore widget))
                       (setf *result*
                             (list :left (nth (mnas-sdl3-gui/widgets:list-box-selected-index *left*)
                                              (mnas-sdl3-gui/widgets:list-box-items *left*))
                                   :right (nth (mnas-sdl3-gui/widgets:list-box-selected-index *right*)
                                               (mnas-sdl3-gui/widgets:list-box-items *right*)))
                             *open* nil)))
          *cancel*
          (make-instance 'mnas-sdl3-gui/widgets:button
                         :x 490 :y 264 :width 130 :height 34
                         :text "Cancel"
                         :on-click (lambda (widget)
                                     (declare (ignore widget))
                                     (setf *result* nil
                                           *open* nil)))
          *widgets*
          (list title subtitle
                *left*
                *right*
                *ok*
                *cancel*))
    *widgets*))





;;;; ./demos/dialog/list-box/list-box-01/list-box-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/list-box-01)

(defun list-box-01-create-toolbar ()
  "Create toolbar for list-box-01 demo." 
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:<toolbar>
                                :layout :horizontal
                                :height +toolbar-height+
                                :window *window*)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :list-box-01/ok
            :label "OK"
            :width 56
            :window *window*)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :list-box-01/cancel
            :label "Cancel"
            :width 72
            :window *window*)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
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
                'mnas-sdl3-gui/widgets:<label>
                :x 20
                :y 18
                :width 600
                :height 24
                :text "Two List-Boxes Demo"))
        (subtitle (make-instance
                   'mnas-sdl3-gui/widgets:<label>
                   :x 20
                   :y 42
                   :width 600
                   :height 22
                   :text "Слева 50 элементов, справа 4 элемента")))
    (setf *left*
          (make-instance
           'mnas-sdl3-gui/widgets:<list-box>
           :x 20 :y 74 :width 290 :height 170
           :items (list-box-01-items 50 "Элемент")
           :selected-index 0
           :item-height 24
           :window *window*)
          *right*
          (make-instance
           'mnas-sdl3-gui/widgets:<list-box>
           :x 330 :y 74 :width 290 :height 170
           :items (list-box-01-items 4 "Пункт")
           :selected-index 0
           :item-height 24
           :window *window*)
          *ok*
          (make-instance
           'mnas-sdl3-gui/widgets:<button>
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
          (make-instance 'mnas-sdl3-gui/widgets:<button>
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





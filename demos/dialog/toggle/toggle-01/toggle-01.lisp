;;;; ./demos/dialog/toggle/toggle-01/toggle-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/toggle-01)

(defparameter *toggle-01-window* nil)
(defparameter *toggle-01-renderer* nil)
(defparameter *toggle-01-open* t)
(defparameter *toggle-01-style* :windows)
(defparameter *toggle-01-widgets* nil)
(defparameter *toggle-01-status* "Выберите переключатель в любой группе.")

(defun selected-toggle-label (group)
  "Return label of the selected toggle in GROUP, or NIL."
  (let ((toggle
          (find-if (lambda (widget)
                     (and (typep widget 'mnas-sdl3-gui/widgets:toggle)
                          (eql (mnas-sdl3-gui/widgets:toggle-group widget) group)
                          (mnas-sdl3-gui/widgets:toggle-state widget)))
                   *toggle-01-widgets*)))
    (when toggle
      (mnas-sdl3-gui/widgets:toggle-label toggle))))

(defun refresh-toggle-01-status ()
  "Update the status line from the currently selected toggles."
  (let ((left (or (selected-toggle-label :group-1) "—"))
        (right (or (selected-toggle-label :group-2) "—")))
    (setf *toggle-01-status*
          (format nil "Группа 1: ~a   Группа 2: ~a" left right))))

(defun make-group-toggle (x y label group selected-p)
  "Create one radio-style toggle for the grouped demo."
  (let ((toggle (make-instance 'mnas-sdl3-gui/widgets:toggle
                               :x x :y y :width 180 :height 28
                               :label label
                               :group group
                               :state selected-p
                               :focused nil)))
    (setf (mnas-sdl3-gui/widgets:widget-value toggle) selected-p)
    (setf (mnas-sdl3-gui/widgets:widget-on-change toggle)
          (lambda (widget value)
            (declare (ignore widget))
            (when value
              (refresh-toggle-01-status))))
    toggle))

(defun create-toggle-01-widgets ()
  "Create demo widgets for two grouped toggle columns."
  (mnas-sdl3-gui/widgets:clear-toggle-group-registry)
  (setf *toggle-01-widgets*
        (list
         (make-instance 'mnas-sdl3-gui/widgets:label
                        :x 20 :y 16 :width 420 :height 28
                        :text "Toggle groups demo")
         (make-instance 'mnas-sdl3-gui/widgets:label
                        :x 40 :y 56 :width 180 :height 22
                        :text "Группа 1")
         (make-instance 'mnas-sdl3-gui/widgets:label
                        :x 250 :y 56 :width 180 :height 22
                        :text "Группа 2")
         (make-group-toggle 40 90 "Вариант 1" :group-1 t)
         (make-group-toggle 40 124 "Вариант 2" :group-1 nil)
         (make-group-toggle 40 158 "Вариант 3" :group-1 nil)
         (make-group-toggle 40 192 "Вариант 4" :group-1 nil)
         (make-group-toggle 250 90 "Опция 1" :group-2 t)
         (make-group-toggle 250 124 "Опция 2" :group-2 nil)
         (make-group-toggle 250 158 "Опция 3" :group-2 nil)
         (make-group-toggle 250 192 "Опция 4" :group-2 nil)))
  (refresh-toggle-01-status))

(sdl3:def-app-init toggle-01-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Toggle Group Demo" "1.0"
                         "com.mna.sdl3.gui.toggle-01.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from toggle-01-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Toggle Groups" 470 280 0)
    (if (not ok)
        (progn
          (format t "~a~%" (sdl3:get-error))
          (return-from toggle-01-demo-init :failure))
        (progn
          (setf *toggle-01-window* window
                *toggle-01-renderer* renderer
                *toggle-01-open* t)
          (mnas-sdl3-gui/widgets:set-widget-style *toggle-01-style*)
          (mnas-sdl3-gui/widgets:init-ttf-font)
          (create-toggle-01-widgets)
          (mnas-sdl3-gui/widgets:move-widget-focus *toggle-01-widgets*))))
  :continue)

(sdl3:def-app-iterate toggle-01-demo-iterate ()
  (unless *toggle-01-open*
    (return-from toggle-01-demo-iterate :success))

  (sdl3:set-render-draw-color *toggle-01-renderer* 240 240 240 255)
  (sdl3:render-clear *toggle-01-renderer*)

  (mnas-sdl3-gui/widgets:render-widgets *toggle-01-renderer* *toggle-01-widgets*)

  (mnas-sdl3-gui/widgets:render-text *toggle-01-renderer*
                                     *toggle-01-status*
                                     20.0 238.0 '(40 40 40 255))

  (mnas-sdl3-gui/widgets:render-text *toggle-01-renderer*
                                     "Click one toggle in each group to switch selection."
                                     20.0 258.0 '(90 90 90 255))

  (sdl3:render-present *toggle-01-renderer*)
  :continue)

(sdl3:def-app-event toggle-01-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *toggle-01-open* nil)
       :success)
      (sdl3:mouse-motion-event
       (mnas-sdl3-gui/widgets:dispatch-widget-mouse-motion
        *toggle-01-widgets*
        (round (slot-value ev 'sdl3:%x))
        (round (slot-value ev 'sdl3:%y)))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let ((mx (round (slot-value ev 'sdl3:%x)))
               (my (round (slot-value ev 'sdl3:%y))))
           (if (slot-value ev 'sdl3:%down)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-down *toggle-01-widgets* mx my)
               (mnas-sdl3-gui/widgets:dispatch-widget-mouse-up *toggle-01-widgets* mx my))))
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat)))
         (mnas-sdl3-gui/widgets:dispatch-widget-keyboard-event
          *toggle-01-widgets*
          (slot-value ev 'sdl3:%key)
          :mods (slot-value ev 'sdl3:%mod)
          :on-escape (lambda ()
                       (setf *toggle-01-open* nil)
                       :success)))
       :continue)
      (t :continue))))

(sdl3:def-app-quit toggle-01-demo-quit (result)
  (declare (ignore result))
  (when *toggle-01-window*
    (sdl3:destroy-renderer *toggle-01-renderer*))
  (when *toggle-01-window*
    (sdl3:destroy-window *toggle-01-window*))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun toggle-01 (&optional (style :windows))
  "Run a grouped toggle demo."
  (setf *toggle-01-style* style)
  (sdl3:enter-app-main-callbacks
   'toggle-01-demo-init
   'toggle-01-demo-iterate
   'toggle-01-demo-event
   'toggle-01-demo-quit)
  :done)

;;;; (toggle-01)

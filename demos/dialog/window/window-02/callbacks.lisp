;;;; ./demos/dialog/window/window-02/callbacks.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-02)

(defun window-02-null-pointer-p (ptr)
  "Check whether PTR is a CFFI null pointer."
  (or (null ptr)
      (cffi:null-pointer-p ptr)))

(defun make-window-02-toolbar ()
  "Create toolbar that mirrors window-02 command model state."
  (let ((toolbar (make-instance 'mnas-sdl3-gui/widgets:<toolbar> :layout :horizontal :height 40)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button> :command-id :label "Popup" :width 70 :type :toggle)
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button> :command-id :label "Pin" :width 56 :type :toggle)
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button> :command-id :label "Reset" :width 62)
           (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button> :command-id :label "Quit" :width 52)))
    toolbar))

(defun window-02-sync-command-state ()
  "Sync dynamic enabled/visible/checked states for toolbar and shortcuts."
  (let ((popup-cmd (mnas-sdl3-gui/commands:find-command :window-02/toggle-popup))
        (pin-cmd (mnas-sdl3-gui/commands:find-command :window-02/toggle-pin))
        (select-cmd (mnas-sdl3-gui/commands:find-command :window-02/select-popup-item))
        (reset-cmd (mnas-sdl3-gui/commands:find-command :window-02/reset-selection)))
    (when popup-cmd
      (mnas-sdl3-gui/commands:set-command-checked popup-cmd *popup-visible*))
    (when pin-cmd
      (mnas-sdl3-gui/commands:set-command-checked pin-cmd *pin-popup*))
    (when select-cmd
      (mnas-sdl3-gui/commands:set-command-enabled select-cmd *popup-visible*))
    (when reset-cmd
      (mnas-sdl3-gui/commands:set-command-visible reset-cmd
                                                  (not (string= *selected-item* "No item selected"))))))

(defun window-02-popup-height ()
  (+ (* (length *popup-items*) +popup-item-height+)
     (* 2 +popup-padding+)))

(defun window-02-item-index-at (mouse-y)
  (let* ((local-y (- mouse-y +popup-padding+))
         (index (floor local-y +popup-item-height+)))
    (when (and (>= local-y 0)
               (< index (length *popup-items*)))
      index)))

(defun window-02-hide-popup ()
  (setf *popup-visible* nil
        *hover-index* nil)
  (when *popup-window*
    (sdl3:hide-window *popup-window*))
  (when *layer-manager*
    (mnas-sdl3-gui/window-manager:close-window
     *layer-manager*
     *popup-id*
     :close-children t)
    (mnas-sdl3-gui/window-manager:set-focused-window
     *layer-manager*
     *main-id*)))

(defun window-02-show-popup-at (local-x local-y)
  (when *main-window*
    (multiple-value-bind (ok wx wy)
        (sdl3:get-window-position *main-window*)
      (when ok
        (let ((global-x (+ wx local-x))
              (global-y (+ wy local-y)))
          (sdl3:set-window-position *popup-window* global-x global-y)
          (sdl3:show-window *popup-window*)
          (sdl3:raise-window *popup-window*)
          (when *layer-manager*
            (mnas-sdl3-gui/window-manager:open-window
             *layer-manager*
             *popup-id*))
          (setf *popup-visible* t
                *hover-index* nil))))))

(defun window-02-render-main ()
  (sdl3:set-render-draw-color *main-renderer* 30 35 40 255)
  (sdl3:render-clear *main-renderer*)
  (mnas-sdl3-gui/widgets:render-text *main-renderer*
                                     "Popup Menu Window Demo"
                                     28.0 26.0 '(232 232 232 255))
  (mnas-sdl3-gui/widgets:render-text *main-renderer*
                                     "Right click anywhere to open an actual :popup-menu window."
                                     28.0 64.0 '(190 190 190 255))
  (mnas-sdl3-gui/widgets:render-text *main-renderer*
                                     "Left click a popup item to select it. Escape closes popup or exits demo."
                                     28.0 94.0 '(170 170 170 255))
  (mnas-sdl3-gui/widgets:render-text *main-renderer*
                                     (format nil "Selected item: ~A" *selected-item*)
                                     28.0 148.0 '(246 214 102 255))
  (mnas-sdl3-gui/widgets:render-text *main-renderer*
                                     (if *popup-visible*
                                         "Popup state: visible"
                                         "Popup state: hidden")
                                     28.0 178.0 '(150 205 230 255))
  (mnas-sdl3-gui/widgets:render-text *main-renderer*
                                     (if *pin-popup*
                                         "Pin mode: on (click outside does not close popup)"
                                         "Pin mode: off")
                                     28.0 204.0 '(164 196 216 255))
  (mnas-sdl3-gui/widgets:render-toolbar
   *toolbar*
   *main-renderer*
   +toolbar-x+
   +toolbar-y+)
  (sdl3:render-present *main-renderer*))

(defun window-02-render-popup ()
  (when *popup-visible*
    (sdl3:set-render-draw-color *popup-renderer* 245 245 245 255)
    (sdl3:render-clear *popup-renderer*)

    (sdl3:set-render-draw-color *popup-renderer* 34 34 34 255)
    (sdl3:render-rect *popup-renderer*
                      (make-instance 'sdl3:frect
                                     :%x 0.5
                                     :%y 0.5
                                     :%w (float (- +popup-width+ 1) 1.0)
                                     :%h (float (- (window-02-popup-height) 1) 1.0)))

    (loop for item in *popup-items*
          for index from 0
          for row-y = (+ +popup-padding+
                         (* index +popup-item-height+))
          do (progn
               (when (and *hover-index*
                          (= index *hover-index*))
                 (sdl3:set-render-draw-color *popup-renderer* 69 132 227 255)
                 (sdl3:render-fill-rect *popup-renderer*
                                        (make-instance 'sdl3:frect
                                                       :%x 5.0
                                                       :%y (float row-y 1.0)
                                                       :%w (float (- +popup-width+ 10) 1.0)
                                                       :%h (float +popup-item-height+ 1.0))))
               (mnas-sdl3-gui/widgets:render-text *popup-renderer*
                                                  item
                                                  16.0
                                                  (float (+ row-y 10) 1.0)
                                                  (if (and *hover-index*
                                                           (= index *hover-index*))
                                                      '(255 255 255 255)
                                                      '(20 20 20 255)))))

    (sdl3:render-present *popup-renderer*)))

(defun window-02-handle-window-event (window-id)
  (let ((action (and *layer-manager*
                     (mnas-sdl3-gui/window-manager:close-action
                      *layer-manager*
                      window-id))))
    (case action
      (:close-root
       (window-02-command :window-02/quit)
       t)
      (:close-transient
       (when (= window-id *popup-id*)
         (window-02-hide-popup))
       t)
      (otherwise
       (cond
         ((= window-id *main-id*)
          (window-02-command :window-02/quit)
          t)
         ((= window-id *popup-id*)
          (window-02-hide-popup)
          t)
         (t nil)))))

(defun window-02-handle-mouse-motion (window-id y)
  (let* ((target-id (if *layer-manager*
                        (mnas-sdl3-gui/window-manager:event-target-window-id
                         *layer-manager*
                         window-id)
                        window-id)))
    (when (and *popup-visible*
               target-id
               (= target-id *popup-id*))
      (setf *hover-index*
            (window-02-item-index-at
             (round y))))))

(defun window-02-handle-mouse-event (window-id x y button down)
  (when *layer-manager*
    (setf window-id
          (or (mnas-sdl3-gui/window-manager:event-target-window-id
               *layer-manager*
               window-id)
              window-id)))
  (cond
    ((and down
          (= button +mouse-left+)
          (= window-id *main-id*)
          (>= x (round +toolbar-x+))
          (<= x (+ (round +toolbar-x+) (round +toolbar-width+)))
          (>= y (round +toolbar-y+))
          (<= y (+ (round +toolbar-y+) (round +toolbar-height+))))
     (let ((toolbar-button
            (mnas-sdl3-gui/widgets:toolbar-buttons-at-position
             *toolbar*
             (- x (round +toolbar-x+))
             (- y (round +toolbar-y+)))))
       (when toolbar-button
         (mnas-sdl3-gui/widgets:toolbar-button-clicked
          *toolbar*
          toolbar-button
          (list :window-id window-id :x x :y y)))))
    ((and down
          (= button +mouse-right+)
          (= window-id *main-id*))
     (window-02-command :window-02/toggle-popup :x x :y y))
    ((and down
          (= button +mouse-left+)
          (= window-id *popup-id*)
          *popup-visible*)
     (let ((index (window-02-item-index-at y)))
       (window-02-command :window-02/select-popup-item :index index)))
    ((and down
          (= button +mouse-left+)
          (= window-id *main-id*)
          *popup-visible*
          (not *pin-popup*))
     (window-02-command :window-02/toggle-popup))))

(defun window-02-handle-keyboard-event (window-id key mods)
  (when *layer-manager*
    (mnas-sdl3-gui/window-manager:set-focused-window
     *layer-manager*
     window-id))
  (when (mnas-sdl3-gui/commands:dispatch-shortcut
         key
         :mods mods
         :context (list :window-id window-id))
    (unless *open*
      t))))

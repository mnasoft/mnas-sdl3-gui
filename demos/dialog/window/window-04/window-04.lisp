;;;; ./demos/dialog/window/window-04/window-04.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-04)

(defun window-04-clamp-opacity (value)
  (min 1.0 (max 0.15 value)))

(defun window-04-apply-opacity ()
  (when *window*
    (setf *opacity* (window-04-clamp-opacity *opacity*))
    (sdl3:set-window-opacity *window* *opacity*)))

(defun make-window-04-toolbar (window)
  "Create toolbar for the transparent-window demo."
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :window window
           :layout :horizontal :height 40)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :window-04/decrease-opacity
            :label "-"
            :width 34)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :window-04/increase-opacity
            :label "+" :width 34)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :window-04/reset-opacity
            :label "Reset"
            :width 62)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :window-04/toggle-frost
            :label "Frost"
            :width 62
            :type :toggle)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :window-04/quit
            :label "Quit" :width 52)))
    toolbar))

(defun window-04-sync-command-state ()
  "Sync dynamic visible/checked command state for toolbar rendering."
  (let ((reset-cmd (mnas-sdl3-gui/commands:find-command :window-04/reset-opacity))
        (frost-cmd (mnas-sdl3-gui/commands:find-command :window-04/toggle-frost)))
    (when reset-cmd
      (mnas-sdl3-gui/commands:set-command-visible reset-cmd
                                                  (> (abs (- *opacity* +default-opacity+)) 0.001)))
    (when frost-cmd
      (mnas-sdl3-gui/commands:set-command-checked frost-cmd *frost*))))

(defun window-04-render-content ()
  "Render the transparent window demo content and toolbar."
  (sdl3:set-render-draw-color *renderer* 0 0 0 0)
  (sdl3:render-clear *renderer*)

  (window-04-sync-command-state)

  (let* ((panel-alpha (max 40 (min 255 (round (* 255 *opacity*)))))
         (border-alpha (max 40 (min 255 (round (* 220 *opacity*)))))
         (text-alpha (max 60 (min 255 (round (* 255 *opacity*)))))
         (panel-r (if *frost* 24 44))
         (panel-g (if *frost* 30 46))
         (panel-b (if *frost* 40 56))
         (highlight-a (if *frost* 70 24))
         (border-r (if *frost* 90 140))
         (border-g (if *frost* 160 180))
         (border-b (if *frost* 245 220)))
    (sdl3:set-render-draw-color
     *renderer*
     panel-r panel-g panel-b panel-alpha)
    (sdl3:render-fill-rect
     *renderer*
     (make-instance 'sdl3:frect :%x 28.0 :%y 72.0 :%w 624.0 :%h 266.0))
    (sdl3:set-render-draw-color *renderer* 120 180 255 highlight-a)
    (sdl3:render-fill-rect
     *renderer*
     (make-instance 'sdl3:frect :%x 28.0 :%y 72.0 :%w 624.0 :%h 16.0))
    (sdl3:set-render-draw-color *renderer* border-r border-g border-b border-alpha)
    (sdl3:render-rect
     *renderer*
     (make-instance 'sdl3:frect :%x 28.0 :%y 72.0 :%w 624.0 :%h 266.0))

    (let* ((square-x 352.0)
           (square-y 118.0)
           (square-size 180.0)
           (square-bg-r (if *frost* 138 232))
           (square-bg-g (if *frost* 176 128))
           (square-bg-b (if *frost* 255 188))
           (square-bg-a (if *frost* 54 112))
           (square-line-a (if *frost* 72 140)))
      (sdl3:set-render-draw-color *renderer* square-bg-r square-bg-g square-bg-b square-bg-a)
      (sdl3:render-fill-rect
       *renderer*
       (make-instance 'sdl3:frect :%x square-x :%y square-y :%w square-size :%h square-size))
      (sdl3:set-render-draw-color *renderer* 255 255 255 square-line-a)
      (if *frost*
          (progn
            (dotimes (i 5)
              (sdl3:render-fill-rect
               *renderer*
               (make-instance 'sdl3:frect :%x (+ square-x 24 (* i 24)) :%y (+ square-y 24) :%w 16 :%h 132)))
            (sdl3:render-rect
             *renderer*
             (make-instance 'sdl3:frect :%x square-x :%y square-y :%w square-size :%h square-size)))
          (progn
            (sdl3:set-render-draw-color *renderer* 255 224 132 180)
            (sdl3:render-fill-rect
             *renderer*
             (make-instance 'sdl3:frect :%x (+ square-x 34) :%y (+ square-y 32) :%w 112 :%h 112))
            (sdl3:set-render-draw-color *renderer* 255 255 255 120)
            (sdl3:render-fill-rect
             *renderer*
             (make-instance 'sdl3:frect :%x (+ square-x 72) :%y (+ square-y 24) :%w 20 :%h 140))
            (sdl3:render-fill-rect
             *renderer*
             (make-instance 'sdl3:frect :%x (+ square-x 24) :%y (+ square-y 72) :%w 140 :%h 20)))))

    (mnas-sdl3-gui/widgets:render-toolbar
     *toolbar*
     *renderer*
     +toolbar-x+
     +toolbar-y+)

    (mnas-sdl3-gui/widgets:render-text
     *renderer*
     "Transparent Window Demo (:transparent)"
     48.0 98.0 (list 230 240 255 text-alpha))
    (mnas-sdl3-gui/widgets:render-text
     *renderer*
     "Toolbar/full-state: + - Reset Frost Quit"
     48.0 126.0 (list 182 206 245 text-alpha))
    (mnas-sdl3-gui/widgets:render-text
     *renderer*
     (format nil "Frost: ~a" (if *frost* "ON (glass)" "OFF (solid)"))
     48.0 212.0 (list 255 224 132 text-alpha))
    (mnas-sdl3-gui/widgets:render-text
     *renderer*
     (format nil "Window opacity: ~,2f" *opacity*)
     48.0 154.0 (list 255 224 132 text-alpha))
    (mnas-sdl3-gui/widgets:render-text
     *renderer*
     "Behind this panel desktop should remain visible."
     48.0 184.0 (list 196 210 220 text-alpha)))

  (sdl3:render-present *renderer*))

(defun window-04-handle-toolbar-click (target-window-id x y)
  (when (= target-window-id *window-id*)
    (let ((button (mnas-sdl3-gui/widgets:toolbar-buttons-at-position
                   *toolbar*
                   (- x (round +toolbar-x+))
                   (- y (round +toolbar-y+)))))
      (when button
        (mnas-sdl3-gui/widgets:toolbar-button-clicked
         *toolbar*
         button
         (list :window-id target-window-id))))))

(defun window-04-handle-window-event (window-id)
  (let ((action (and *layer-manager*
                     (mnas-sdl3-gui/window-manager:close-action
                      *layer-manager*
                      window-id))))
    (case action
      (:close-root
       (window-04-command :window-04/quit)
       t)
      (otherwise
       (window-04-command :window-04/quit)
       t))))

(defun window-04-handle-mouse-event (window-id x y)
  (when *layer-manager*
    (mnas-sdl3-gui/window-manager:set-focused-window
     *layer-manager*
     window-id))
  (window-04-handle-toolbar-click window-id x y))

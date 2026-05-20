;;;; ./src/toolbar/presenter/functions.lisp

(in-package :mnas-sdl3-gui/toolbar)

(defun toolbar-layout-horizontal (toolbar)
  "Recalculate button positions in horizontal layout."
  (let ((x-pos (toolbar-padding toolbar))
        (y-pos (toolbar-padding toolbar)))
    (dolist (button (toolbar-buttons toolbar))
      (setf (button-x button) x-pos)
      (setf (button-y button) y-pos)
      (incf x-pos (+ (button-width button) (toolbar-padding toolbar))))
    ;; Update toolbar width
    (setf (toolbar-width toolbar)
          (if (toolbar-buttons toolbar)
              (+ x-pos (toolbar-padding toolbar))
              0))))

(defun toolbar-layout-vertical (toolbar)
  "Recalculate button positions in vertical layout."
  (let ((x-pos (toolbar-padding toolbar))
        (y-pos (toolbar-padding toolbar)))
    (dolist (button (toolbar-buttons toolbar))
      (setf (button-x button) x-pos)
      (setf (button-y button) y-pos)
      (incf y-pos (+ (button-height button) (toolbar-padding toolbar))))
    ;; Update toolbar height
    (setf (toolbar-height toolbar)
          (if (toolbar-buttons toolbar)
              (+ y-pos (toolbar-padding toolbar))
              40))))

(defun render-toolbar (toolbar renderer offset-x offset-y)
  "Render toolbar on RENDERER at position (OFFSET-X, OFFSET-Y)."
  (when (null toolbar)
    (return-from render-toolbar))
  
  ;; Recalculate layout if needed
  (ecase (toolbar-layout toolbar)
    (:horizontal (toolbar-layout-horizontal toolbar))
    (:vertical (toolbar-layout-vertical toolbar)))
  
  ;; Render background
  (let ((bg (toolbar-background toolbar)))
    (apply #'sdl3:set-render-draw-color renderer bg)
    (sdl3:render-fill-rect renderer
                           (make-instance 'sdl3:frect
                                          :%x (float offset-x 1.0)
                                          :%y (float offset-y 1.0)
                                          :%w (float (toolbar-width toolbar) 1.0)
                                          :%h (float (toolbar-height toolbar) 1.0))))
  
  ;; Render each button
  (dolist (button (toolbar-buttons toolbar))
    (render-toolbar-button button renderer 
                          (+ offset-x (button-x button))
                          (+ offset-y (button-y button)))))

(defun render-toolbar-button (button renderer x y)
  "Render a single toolbar button."
  (let* ((cmd-id (button-command-id button))
         (cmd (mnas-sdl3-gui/commands:find-command cmd-id))
         (enabled (and cmd (mnas-sdl3-gui/commands:command-enabled-p cmd)))
         (checked (and cmd (mnas-sdl3-gui/commands:command-checked cmd)))
         (bg-color (cond
                     ((not enabled) '(200 200 200 255))
                     (checked '(100 150 220 255))
                     (t '(220 220 220 255))))
         (text-color (cond
                       ((not enabled) '(150 150 150 255))
                       (t '(0 0 0 255)))))
    
    ;; Draw button background
    (apply #'sdl3:set-render-draw-color renderer bg-color)
    (sdl3:render-fill-rect renderer
                           (make-instance 'sdl3:frect
                                          :%x (float x 1.0)
                                          :%y (float y 1.0)
                                          :%w (float (button-width button) 1.0)
                                          :%h (float (button-height button) 1.0)))
    
    ;; Draw button border
    (sdl3:set-render-draw-color renderer 100 100 100 255)
    (sdl3:render-rect renderer
                      (make-instance 'sdl3:frect
                                     :%x (float x 1.0)
                                     :%y (float y 1.0)
                                     :%w (float (button-width button) 1.0)
                                     :%h (float (button-height button) 1.0)))
    
    ;; Draw button label and indicator
    (when (> (length (button-label button)) 0)
      (mnas-sdl3-gui/widgets:render-text renderer
                                         (button-label button)
                                         (+ x 6)
                                         (+ y 8)
                                         text-color))
    
    ;; For toggle/radio, show indicator
    (when (member (button-type button) '(:toggle :radio))
      (when checked
        (sdl3:set-render-draw-color renderer 0 100 200 255)
        (sdl3:render-fill-rect renderer
                               (make-instance 'sdl3:frect
                                              :%x (float (+ x 4) 1.0)
                                              :%y (float (+ y 4) 1.0)
                                              :%w 4.0
                                              :%h 4.0))))))

(defun toolbar-buttons-at-position (toolbar x y)
  "Return button at position (X, Y) or NIL."
  (dolist (button (toolbar-buttons toolbar))
    (when (and (>= x (button-x button))
               (<  x (+ (button-x button) (button-width button)))
               (>= y (button-y button))
               (<  y (+ (button-y button) (button-height button))))
      (return button))))

(defun toolbar-button-clicked (button context)
  "Execute command for BUTTON. Toggle state if :toggle or :radio type."
  (let ((cmd-id (button-command-id button)))
    (when (mnas-sdl3-gui/commands:command-enabled-p 
           (mnas-sdl3-gui/commands:find-command cmd-id))
      ;; Handle toggle state
      (when (eq (button-type button) :toggle)
        (let ((cmd (mnas-sdl3-gui/commands:find-command cmd-id)))
          (when cmd
            (let ((current (mnas-sdl3-gui/commands:command-checked cmd)))
              (setf (mnas-sdl3-gui/commands:command-checked cmd)
                    (not current))))))
      ;; Execute command
      (mnas-sdl3-gui/commands:execute-command cmd-id :context context))))

(defun toolbar-from-command-group (group-name &key (type :push))
  "Create toolbar from commands in specified group."
  (let ((toolbar (make-toolbar)))
    (maphash (lambda (id cmd)
               (declare (ignore id))
               (when (eq (mnas-sdl3-gui/commands:command-group cmd) group-name)
                 (push (make-button-spec (mnas-sdl3-gui/commands:command-id cmd)
                                        :type type
                                        :label (mnas-sdl3-gui/commands:command-title cmd)
                                        :hotkey (or (mnas-sdl3-gui/commands:command-shortcut cmd) ""))
                       (toolbar-buttons toolbar))))
             mnas-sdl3-gui/commands:*command-registry*)
    (setf (toolbar-buttons toolbar) (nreverse (toolbar-buttons toolbar)))
    toolbar))

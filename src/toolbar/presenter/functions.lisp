;;;; ./src/toolbar/presenter/functions.lisp

(in-package :mnas-sdl3-gui/toolbar)

(defun toolbar-button-visible-p (button)
  "Return T when BUTTON should be visible according to command state." 
  (let ((cmd (mnas-sdl3-gui/commands:find-command (button-command-id button))))
    (if cmd
        (mnas-sdl3-gui/commands:command-visible cmd)
        t)))

(defun toolbar-visible-buttons (toolbar)
  "Return buttons that are currently visible." 
  (remove-if-not #'toolbar-button-visible-p (toolbar-buttons toolbar)))

(defun toolbar-layout-horizontal (toolbar)
  "Recalculate button positions in horizontal layout."
  (let ((x-pos (toolbar-padding toolbar))
        (y-pos (toolbar-padding toolbar))
        (max-button-height 0))
    (dolist (button (toolbar-visible-buttons toolbar))
      (setf (button-x button) x-pos)
      (setf (button-y button) y-pos)
      (incf x-pos (+ (button-width button) (toolbar-padding toolbar)))
      (setf max-button-height (max max-button-height (button-height button))))
    ;; Update toolbar width and height
    (setf (toolbar-width toolbar)
          (if (toolbar-visible-buttons toolbar)
              (+ x-pos (toolbar-padding toolbar))
              0)
          (toolbar-height toolbar)
          (if (toolbar-visible-buttons toolbar)
              (+ max-button-height
                 (* 2 (toolbar-padding toolbar)))
              0))))

(defun toolbar-layout-vertical (toolbar)
  "Recalculate button positions in vertical layout."
  (let ((x-pos (toolbar-padding toolbar))
        (y-pos (toolbar-padding toolbar)))
    (dolist (button (toolbar-visible-buttons toolbar))
      (setf (button-x button) x-pos)
      (setf (button-y button) y-pos)
      (incf y-pos (+ (button-height button) (toolbar-padding toolbar))))
    ;; Update toolbar height
    (setf (toolbar-height toolbar)
          (if (toolbar-visible-buttons toolbar)
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
  (dolist (button (toolbar-visible-buttons toolbar))
    (render-toolbar-button button renderer 
                          (+ offset-x (button-x button))
                          (+ offset-y (button-y button)))))

(defun toolbar-text-pixel-size (text)
  "Return TEXT width and height in pixels for toolbar rendering." 
  (handler-case
      (multiple-value-bind (width height)
          (sdl3-ttf:ttf-get-string-size mnas-sdl3-gui/widgets:*ttf-font* text)
        (values width height))
    (error ()
      (values (* (length text) 8) 16))))

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
    
    ;; Draw button label centered in button
    (when (> (length (button-label button)) 0)
      (multiple-value-bind (text-w text-h)
          (toolbar-text-pixel-size (button-label button))
        (let ((text-x (+ x (max 0 (floor (/ (- (button-width button) text-w) 2)))))
              (text-y (+ y (max 0 (floor (/ (- (button-height button) text-h) 2))))))
          (mnas-sdl3-gui/widgets:render-text renderer
                                             (button-label button)
                                             text-x
                                             text-y
                                             text-color))))
    
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
  (dolist (button (toolbar-visible-buttons toolbar))
    (when (and (>= x (button-x button))
               (<  x (+ (button-x button) (button-width button)))
               (>= y (button-y button))
               (<  y (+ (button-y button) (button-height button))))
      (return button))))

(defun toolbar-button-enabled-p (button)
  "Return T when button command can execute." 
  (let ((cmd (mnas-sdl3-gui/commands:find-command (button-command-id button))))
    (and cmd (mnas-sdl3-gui/commands:command-enabled-p cmd))))

(defun toolbar-clear-radio-group (toolbar group-id except-command-id)
  "Clear checked state for all radio commands in GROUP-ID except EXCEPT-COMMAND-ID." 
  (when group-id
    (dolist (candidate (toolbar-buttons toolbar))
      (when (and (eq (button-type candidate) :radio)
                 (equal (button-group candidate) group-id)
                 (not (equal (button-command-id candidate) except-command-id)))
        (let ((cmd (mnas-sdl3-gui/commands:find-command (button-command-id candidate))))
          (when cmd
            (setf (mnas-sdl3-gui/commands:command-checked cmd) nil)))))))

(defun toolbar-button-clicked (toolbar button context)
  "Execute command for BUTTON with push/toggle/radio behavior." 
  (let ((cmd-id (button-command-id button)))
    (when (and (toolbar-button-visible-p button)
               (toolbar-button-enabled-p button))
      (let ((cmd (mnas-sdl3-gui/commands:find-command cmd-id)))
        (when cmd
          (case (button-type button)
            (:toggle
             (setf (mnas-sdl3-gui/commands:command-checked cmd)
                   (not (mnas-sdl3-gui/commands:command-checked cmd))))
            (:radio
             (toolbar-clear-radio-group toolbar (button-group button) cmd-id)
             (setf (mnas-sdl3-gui/commands:command-checked cmd) t))
            (otherwise nil))))
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

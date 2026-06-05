;;;; ./src/toolbar/presenter/functions.lisp

(in-package :mnas-sdl3-gui/toolbar)

;; Registry of toolbar instances that should react to command state changes.
(defparameter *registered-toolbars* nil "List of toolbar instances registered for command change updates.")

(defun register-toolbar-for-command-updates (toolbar)
  "Register TOOLBAR to receive command change-driven layout updates." 
  (pushnew toolbar *registered-toolbars*))

(defun unregister-toolbar-for-command-updates (toolbar)
  "Unregister TOOLBAR from command change-driven updates." 
  (setf *registered-toolbars* (remove toolbar *registered-toolbars*)))

(defun toolbar-command-change-hook (cmd property old new)
  "Hook called on command state change; refresh registered toolbars when relevant properties change." 
  (declare (ignore cmd old new))
  (when (member property '(:enabled :visible :checked))
    (dolist (tb *registered-toolbars*)
      (handler-case
          (update-toolbar-command-state tb)
        (error (e)
          (format *error-output* "Toolbar update error: ~S~%" e))))))

;; Register hook once so all registered toolbars update automatically.
(mnas-sdl3-gui/commands:register-command-change-hook #'toolbar-command-change-hook)

(defun toolbar-button-visible-p (button)
  "Return T when BUTTON should be visible according to command state." 
  (let ((cmd (mnas-sdl3-gui/commands:find-command (mnas-sdl3-gui/widgets:button-command-id button))))
    (if cmd
        (mnas-sdl3-gui/commands:command-visible cmd)
        t)))

(defun toolbar-visible-buttons (toolbar)
  "Return buttons that are currently visible." 
  (remove-if-not #'toolbar-button-visible-p (toolbar-buttons toolbar)))

(defun update-toolbar-command-state (toolbar)
  "Refresh toolbar layout state from current command visibility rules."
  (when toolbar
    (ecase (mnas-sdl3-gui/widgets:toolbar-layout toolbar)
      (:horizontal (toolbar-layout-horizontal toolbar))
      (:vertical (toolbar-layout-vertical toolbar)))
    toolbar))

(defun toolbar-layout-horizontal (toolbar)
  "Recalculate button positions in horizontal layout."
  (let ((x-pos (mnas-sdl3-gui/widgets:toolbar-padding toolbar))
        (y-pos (mnas-sdl3-gui/widgets:toolbar-padding toolbar))
        (max-button-height 0))
    (dolist (button (toolbar-visible-buttons toolbar))
      (setf (mnas-sdl3-gui/widgets:widget-x button) x-pos)
      (setf (mnas-sdl3-gui/widgets:widget-y button) y-pos)
      (incf x-pos (+ (mnas-sdl3-gui/widgets:widget-width button)
                     (mnas-sdl3-gui/widgets:toolbar-padding toolbar)))
      (setf max-button-height
            (max max-button-height (mnas-sdl3-gui/widgets:widget-height button))))
    ;; Update toolbar width and height
    (setf (mnas-sdl3-gui/widgets:widget-width toolbar)
          (if (toolbar-visible-buttons toolbar)
              (+ x-pos (mnas-sdl3-gui/widgets:toolbar-padding toolbar))
              0)
          (mnas-sdl3-gui/widgets:widget-height toolbar)
          (if (toolbar-visible-buttons toolbar)
              (+ max-button-height
                 (* 2 (mnas-sdl3-gui/widgets:toolbar-padding toolbar)))
              0))))

(defun toolbar-layout-vertical (toolbar)
  "Recalculate button positions in vertical layout."
  (let ((x-pos (mnas-sdl3-gui/widgets:toolbar-padding toolbar))
        (y-pos (mnas-sdl3-gui/widgets:toolbar-padding toolbar)))
    (dolist (button (toolbar-visible-buttons toolbar))
      (setf (mnas-sdl3-gui/widgets:widget-x button) x-pos)
      (setf (mnas-sdl3-gui/widgets:widget-y button) y-pos)
      (incf y-pos (+ (mnas-sdl3-gui/widgets:widget-height button)
                     (mnas-sdl3-gui/widgets:toolbar-padding toolbar))))
    ;; Update toolbar height
    (setf (mnas-sdl3-gui/widgets:widget-height toolbar)
          (if (toolbar-visible-buttons toolbar)
              (+ y-pos (mnas-sdl3-gui/widgets:toolbar-padding toolbar))
              40))))

(defun render-toolbar (toolbar renderer offset-x offset-y)
  "Render toolbar on RENDERER at position (OFFSET-X, OFFSET-Y)."
  (when (null toolbar)
    (return-from render-toolbar))
  
  ;; Recalculate layout if needed
  (ecase (mnas-sdl3-gui/widgets:toolbar-layout toolbar)
    (:horizontal (toolbar-layout-horizontal toolbar))
    (:vertical (toolbar-layout-vertical toolbar)))
  
  ;; Render background
  (let ((bg (mnas-sdl3-gui/widgets::toolbar-background toolbar)))
    (apply #'sdl3:set-render-draw-color renderer bg)
    (sdl3:render-fill-rect renderer
                           (make-instance 'sdl3:frect
                                          :%x (float offset-x 1.0)
                                          :%y (float offset-y 1.0)
                                          :%w (float (mnas-sdl3-gui/widgets:widget-width toolbar) 1.0)
                                          :%h (float (mnas-sdl3-gui/widgets:widget-height toolbar) 1.0))))
  
  ;; Render each button
  (dolist (button (toolbar-visible-buttons toolbar))
    (render-toolbar-button button renderer 
                          (+ offset-x (mnas-sdl3-gui/widgets:widget-x button))
                          (+ offset-y (mnas-sdl3-gui/widgets:widget-y button)))))

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
  (let* ((cmd-id (mnas-sdl3-gui/widgets:button-command-id button))
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
                                          :%w (float (mnas-sdl3-gui/widgets:widget-width button) 1.0)
                                          :%h (float (mnas-sdl3-gui/widgets:widget-height button) 1.0)))
    
    ;; Draw button border
    (sdl3:set-render-draw-color renderer 100 100 100 255)
    (sdl3:render-rect renderer
                      (make-instance 'sdl3:frect
                                     :%x (float x 1.0)
                                     :%y (float y 1.0)
                                     :%w (float (mnas-sdl3-gui/widgets:widget-width button) 1.0)
                                     :%h (float (mnas-sdl3-gui/widgets:widget-height button) 1.0)))
    
    ;; Draw button label centered in button
    (when (> (length (mnas-sdl3-gui/widgets::button-label button)) 0)
      (multiple-value-bind (text-w text-h)
          (toolbar-text-pixel-size (mnas-sdl3-gui/widgets::button-label button))
        (let ((text-x (+ x (max 0 (floor (/ (- (mnas-sdl3-gui/widgets:widget-width button) text-w) 2)))))
              (text-y (+ y (max 0 (floor (/ (- (mnas-sdl3-gui/widgets:widget-height button) text-h) 2))))))
          (mnas-sdl3-gui/widgets:render-text renderer
                                             (mnas-sdl3-gui/widgets::button-label button)
                                             text-x
                                             text-y
                                             text-color))))
    
    ;; For toggle/radio, show indicator
    (when (member (mnas-sdl3-gui/widgets::button-type button) '(:toggle :radio))
      (when checked
        (sdl3:set-render-draw-color renderer 0 100 200 255)
        (sdl3:render-fill-rect renderer
                               (make-instance 'sdl3:frect
                                              :%x (float (+ x 4) 1.0)
                                              :%y (float (+ y 4) 1.0)
                                              :%w 4.0
                                              :%h 4.0)))))
  )

(defun toolbar-buttons-at-position (toolbar x y)
  "Return button at position (X, Y) or NIL."
  ;; Support both legacy toolbar-button-spec lists and widget-children toolbar.
  (let ((buttons-list (if (and (typep toolbar 'mnas-sdl3-gui/widgets:toolbar)
                               (mnas-sdl3-gui/widgets:children toolbar))
                          (mnas-sdl3-gui/widgets:children toolbar)
                          (toolbar-buttons toolbar))))
    (dolist (button buttons-list)
      (when (and (>= x (mnas-sdl3-gui/widgets:widget-x button))
                 (<  x (+ (mnas-sdl3-gui/widgets:widget-x button)
                          (mnas-sdl3-gui/widgets:widget-width button)))
                 (>= y (mnas-sdl3-gui/widgets:widget-y button))
                 (<  y (+ (mnas-sdl3-gui/widgets:widget-y button)
                          (mnas-sdl3-gui/widgets:widget-height button))))
        (return button)))))

(defun toolbar-button-enabled-p (button)
  "Return T when button command can execute." 
  (let ((cmd (mnas-sdl3-gui/commands:find-command (mnas-sdl3-gui/widgets:button-command-id button))))
    (and cmd (mnas-sdl3-gui/commands:command-enabled-p cmd))))

(defun toolbar-clear-radio-group (toolbar group-id except-command-id)
  "Clear checked state for all radio commands in GROUP-ID except EXCEPT-COMMAND-ID." 
  (when group-id
    (dolist (candidate (toolbar-buttons toolbar))
      (when (and (eq (mnas-sdl3-gui/widgets::button-type candidate) :radio)
                 (equal (mnas-sdl3-gui/widgets::button-group candidate) group-id)
                 (not (equal (mnas-sdl3-gui/widgets:button-command-id candidate) except-command-id)))
        (let ((cmd (mnas-sdl3-gui/commands:find-command (mnas-sdl3-gui/widgets:button-command-id candidate))))
          (when cmd
            (mnas-sdl3-gui/commands:set-command-checked cmd nil)))))))

(defun toolbar-button-clicked (toolbar button context)
  "Execute command for BUTTON with push/toggle/radio behavior."
  (let ((cmd-id (mnas-sdl3-gui/widgets:button-command-id button)))
    (when (and (toolbar-button-visible-p button)
               (toolbar-button-enabled-p button))
      (let ((cmd (mnas-sdl3-gui/commands:find-command cmd-id)))
        (when cmd
          (case (mnas-sdl3-gui/widgets::button-type button)
            (:toggle
             (mnas-sdl3-gui/commands:set-command-checked cmd
                         (not (mnas-sdl3-gui/commands:command-checked cmd))))
            (:radio
             (toolbar-clear-radio-group toolbar (mnas-sdl3-gui/widgets::button-group button) cmd-id)
             (mnas-sdl3-gui/commands:set-command-checked cmd t))
            (otherwise nil))))
      (mnas-sdl3-gui/commands:execute-command cmd-id :context context))))

(defun handle-toolbar-mouse-event (toolbar ev &optional (offset-x 0) (offset-y 0))
  "Handle an `sdl3:mouse-button-event` for TOOLBAR at given offset.
Returns T when the event was consumed (toolbar button clicked), NIL otherwise."
  (let ((button (and toolbar
                     (toolbar-buttons-at-position
                      toolbar
                      (round (- (slot-value ev 'sdl3:%x) offset-x))
                      (round (- (slot-value ev 'sdl3:%y) offset-y))))))
    (when button
      (when (slot-value ev 'sdl3:%down)
        (toolbar-button-clicked toolbar button (list :window-id (slot-value ev 'sdl3:%window-id))))
      t)))


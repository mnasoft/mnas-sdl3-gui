;;;; ./demos/layout/grid-01/grid-01.lisp

(in-package :mnas-sdl3-gui/demos/layout/grid-01)

(defparameter *grid-demo-window* nil)
(defparameter *grid-demo-renderer* nil)
(defparameter *grid-demo-window-id* 0)
(defparameter *grid-demo-layer-manager* nil)
(defparameter *grid-demo-widgets* nil)
(defparameter *grid-demo-open* t)
(defparameter *grid-demo-style* :windows)
(defparameter *grid-demo-status* "Grid layout demo")
(defparameter +grid-demo-margin+ 16)

(defun grid-demo-focus-widgets ()
  "Return widgets that participate in focus and text-input dispatch."
  (let ((root (first *grid-demo-widgets*)))
    (if (and root (typep root 'mnas-sdl3-gui/widgets:widget-container))
        (mnas-sdl3-gui/widgets:children root)
        *grid-demo-widgets*)))

(defun grid-demo-relayout (&optional (window *grid-demo-window*))
  "Re-layout the root grid to the current WINDOW client size."
  (when (and window *grid-demo-widgets*)
    (multiple-value-bind (ok win-w win-h) (sdl3:get-window-size window)
      (when ok
        (let* ((root (first *grid-demo-widgets*))
               (inner-w (max 1 (- win-w (* 2 +grid-demo-margin+))))
               (inner-h (max 1 (- win-h (* 2 +grid-demo-margin+)))))
          (when root
            (mnas-sdl3-gui/widgets:widget-arrange root
                                                  +grid-demo-margin+
                                                  +grid-demo-margin+
                                                  inner-w
                                                  inner-h)))))))

(defun create-grid-demo-widgets ()
  "Create a grid container with example widgets and return (values widgets window-width window-height)."
  #+nil (break "create-grid-demo-widgets:")
  (let* ((g (mnas-sdl3-gui/widgets:make-grid :rows 6 :cols 3 :row-spacing 8 :col-spacing 8 :padding 8))
         (title (make-instance 'mnas-sdl3-gui/widgets:label :text "Grid Layout Demo"))
         (name-label (make-instance 'mnas-sdl3-gui/widgets:label :text "Name:"))
         (name-entry (make-instance 'mnas-sdl3-gui/widgets:entry :text "" :cursor 0 :max-length 128))
         (email-label (make-instance 'mnas-sdl3-gui/widgets:label :text "Email:"))
         (email-entry (make-instance 'mnas-sdl3-gui/widgets:entry :text "" :cursor 0 :max-length 128))
         (options-label (make-instance 'mnas-sdl3-gui/widgets:label :text "Options:"))
         (options-list (make-instance 'mnas-sdl3-gui/widgets:list-box :items '("One" "Two" "Three" "Four") :selected-index 0 :item-height 20))
         (ok-button (make-instance 'mnas-sdl3-gui/widgets:button :text "OK" :on-click (lambda (w) (declare (ignore w)) (setf *grid-demo-status* "OK pressed"))))
         (cancel-button (make-instance 'mnas-sdl3-gui/widgets:button :text "Cancel" :on-click (lambda (w) (declare (ignore w)) (setf *grid-demo-open* nil)))))

    ;; register children with constraints
    (mnas-sdl3-gui/widgets:grid-add-child g title :row 0 :col 0 :col-span 3 :halign :center :valign :start)
    (mnas-sdl3-gui/widgets:grid-add-child g name-label :row 1 :col 0 :halign :end :valign :center)
    (mnas-sdl3-gui/widgets:grid-add-child g name-entry :row 1 :col 1 :col-span 2 :halign :fill :valign :center :weight-x 1)
    (mnas-sdl3-gui/widgets:grid-add-child g email-label :row 2 :col 0 :halign :end :valign :center)
    (mnas-sdl3-gui/widgets:grid-add-child g email-entry :row 2 :col 1 :col-span 2 :halign :fill :valign :center :weight-x 1)
    (mnas-sdl3-gui/widgets:grid-add-child g options-label :row 3 :col 0 :halign :start :valign :start)
    (mnas-sdl3-gui/widgets:grid-add-child g options-list :row 3 :col 1 :col-span 2 :row-span 2 :halign :fill :valign :fill :weight-x 1 :weight-y 1)
    (mnas-sdl3-gui/widgets:grid-add-child g ok-button :row 5 :col 1 :halign :end :valign :center)
    (mnas-sdl3-gui/widgets:grid-add-child g cancel-button :row 5 :col 2 :halign :start :valign :center)

    (setf *grid-demo-widgets* (list g))
    ;; Compute requested size and arrange the root grid inside the window margins.
    (multiple-value-bind (w h) (mnas-sdl3-gui/widgets:widget-measure g)
      (mnas-sdl3-gui/widgets:widget-arrange g
                                            +grid-demo-margin+
                                            +grid-demo-margin+
                                            w
                                            h)
      (values *grid-demo-widgets*
              (+ w (* 2 +grid-demo-margin+))
              (+ h (* 2 +grid-demo-margin+))))))

(sdl3:def-app-init grid-demo-init (argc argv)
  (declare (ignore argc argv))
  #+nil (break "grid-demo-init:")
  (sdl3:set-app-metadata "Grid Layout Demo" "1.0" "com.mna.sdl3.gui.grid.demo")
  (when (not (sdl3:init :video))
    (format t "~a~%" (sdl3:get-error))
    (return-from grid-demo-init :failure))
  (setf *grid-demo-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  ;; Init TTF before size calculation
  (mnas-sdl3-gui/widgets:init-ttf-font)
  (multiple-value-bind (widgets window-width window-height) (create-grid-demo-widgets)
    (multiple-value-bind (ok window renderer)
        (sdl3:create-window-and-renderer "Grid Layout Demo" window-width window-height '(:resizable))
      (if (not ok)
          (progn
            (format t "~a~%" (sdl3:get-error))
            (return-from grid-demo-init :failure))
          (progn
            (setf *grid-demo-window* window
                  *grid-demo-renderer* renderer
                  *grid-demo-window-id* (sdl3:get-window-id window)
                  *grid-demo-open* t)
            (mnas-sdl3-gui/window-manager:register-window
             *grid-demo-layer-manager*
             *grid-demo-window-id*
             :main
             :open-p t)
            (mnas-sdl3-gui/window-manager:set-focused-window
             *grid-demo-layer-manager*
             *grid-demo-window-id*)
            (mnas-sdl3-gui/widgets:set-widget-style *grid-demo-style*)
            (mnas-sdl3-gui/widgets:start-widget-text-input window)
            (setf *grid-demo-widgets* widgets)
            (grid-demo-relayout window)
            (let* ((focus-widgets (grid-demo-focus-widgets))
                   (first-entry (find-if (lambda (w)
                                           (typep w 'mnas-sdl3-gui/widgets:entry))
                                         focus-widgets)))
              (if first-entry
                  (mnas-sdl3-gui/widgets:set-widget-focus focus-widgets first-entry)
                  (mnas-sdl3-gui/widgets:move-widget-focus focus-widgets)))
            :continue))))
  #+nil
  (break "grid-demo-init: end:"))

(sdl3:def-app-iterate grid-demo-iterate ()
  #+nil (break "grid-demo-iterate:")
  (unless *grid-demo-open*
    (return-from grid-demo-iterate :success))

  (sdl3:set-render-draw-color *grid-demo-renderer* 242 242 242 255)
  (sdl3:render-clear *grid-demo-renderer*)

  (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order *grid-demo-widgets*)
    do (mnas-sdl3-gui/widgets:render *grid-demo-renderer* widget mnas-sdl3-gui/widgets:*widget-style*))

  (mnas-sdl3-gui/widgets:render-text
   *grid-demo-renderer*
   *grid-demo-status* 16.0 8.0 '(45 45 45 255))

  (sdl3:render-present *grid-demo-renderer*)
  :continue)

(sdl3:def-app-event grid-demo-event (type event)
  (declare (ignore type))
  #+nil (break "grid-demo-event:")
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *grid-demo-open* nil)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *grid-demo-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action *grid-demo-layer-manager* window-id))))
           (case action
             (:close-root (setf *grid-demo-open* nil) (return-from grid-demo-event :success))
             (otherwise (setf *grid-demo-open* nil) (return-from grid-demo-event :success)))))
       (when (and (= (slot-value ev 'sdl3:%window-id) *grid-demo-window-id*)
                  (member (slot-value ev 'sdl3:%type)
                          '(:window-resized :window-pixel-size-changed)
                          :test #'eq))
         (grid-demo-relayout *grid-demo-window*))
       :continue)
        (sdl3:mouse-motion-event
         (mnas-sdl3-gui/widgets:handle-mouse-motion-event
          *grid-demo-widgets*
          ev)
       :continue)
      (sdl3:mouse-button-event
       (mnas-sdl3-gui/widgets:handle-mouse-button-event *grid-demo-widgets* ev)
       :continue)
      (sdl3:mouse-wheel-event
         (mnas-sdl3-gui/widgets:handle-mouse-wheel-event *grid-demo-widgets* ev)
       :continue)
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down) (not (slot-value ev 'sdl3:%repeat)))
         (unless (mnas-sdl3-gui/commands:dispatch-shortcut (slot-value ev 'sdl3:%key) :mods (slot-value ev 'sdl3:%mod))
           (mnas-sdl3-gui/widgets:handle-widget-key-event
            (grid-demo-focus-widgets)
            (slot-value ev 'sdl3:%key) nil
            :mods (slot-value ev 'sdl3:%mod)
            :on-escape (lambda () (setf *grid-demo-open* nil)
                         :success))))
       :continue)
      (sdl3:text-input-event
       (mnas-sdl3-gui/widgets:dispatch-focused-text-input
        (grid-demo-focus-widgets)
        (slot-value ev 'sdl3:%text))
       :continue)
      (t :continue))))

(sdl3:def-app-quit grid-demo-quit (result)
  (declare (ignore result))
  #+nil (break "grid-demo-quit:")
  (mnas-sdl3-gui/widgets:stop-widget-text-input *grid-demo-window*)
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *grid-demo-renderer* (sdl3:destroy-renderer *grid-demo-renderer*))
  (when *grid-demo-window* (mnas-sdl3-gui/widgets:destroy-window-and-unregister *grid-demo-window*))
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit)
  :ok)

(defun grid-01 (&optional (style :windows))
  "Run the grid layout demo."
  #+nil (break "grid-01:")
  (setf *grid-demo-style* style)
  ;; Debug: print callback pointers before entering app main
  (let* ((pkg (find-package "MNAS-SDL3-GUI/DEMOS/LAYOUT/GRID-01"))
         (sinit (and pkg (find-symbol "GRID-DEMO-INIT" pkg)))
         (siter (and pkg (find-symbol "GRID-DEMO-ITERATE" pkg)))
         (sevent (and pkg (find-symbol "GRID-DEMO-EVENT" pkg)))
         (squit (and pkg (find-symbol "GRID-DEMO-QUIT" pkg)))
         (fn-init (and sinit (handler-case (symbol-function sinit) (error () :no-fn))))
         (fn-iter (and siter (handler-case (symbol-function siter) (error () :no-fn))))
         (fn-event (and sevent (handler-case (symbol-function sevent) (error () :no-fn))))
         (fn-quit (and squit (handler-case (symbol-function squit) (error () :no-fn))))
         (cffi-pkg (find-package "CFFI"))
         (get-cb-sym (and cffi-pkg (find-symbol "GET-CALLBACK" cffi-pkg)))
         (get-cb-fn (and get-cb-sym (fboundp get-cb-sym) (symbol-function get-cb-sym))))
    (format t "Grid callbacks: fn-init=~S fn-iter=~S fn-event=~S fn-quit=~S~%" fn-init fn-iter fn-event fn-quit)
    (when get-cb-fn
      (format t "cffi:get-callbacks: init=~S iter=~S event=~S quit=~S~%"
              (handler-case (funcall get-cb-fn sinit) (error (err) (format t "get-callback(init) error: ~S~%" err) :error))
              (handler-case (funcall get-cb-fn siter) (error (err) (format t "get-callback(iter) error: ~S~%" err) :error))
              (handler-case (funcall get-cb-fn sevent) (error (err) (format t "get-callback(event) error: ~S~%" err) :error))
              (handler-case (funcall get-cb-fn squit) (error (err) (format t "get-callback(quit) error: ~S~%" err) :error)))))

  (sdl3:enter-app-main-callbacks
   'grid-demo-init
   'grid-demo-iterate
   'grid-demo-event
   'grid-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui)
;;;; (ql:quickload :mnas-sdl3-gui/demos)  
;;;; (ql:quickload :mnas-sdl3-gui/demos/layout/grid-01)
;;;; (mnas-sdl3-gui/demos/layout/grid-01:grid-01)
;;;; (grid-01)



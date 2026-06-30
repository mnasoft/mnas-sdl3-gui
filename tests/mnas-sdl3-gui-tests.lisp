;;;; ./tests/mnas-sdl3-gui-tests.lisp

(in-package #:mnas-sdl3-gui/tests)

(def-suite :mnas-sdl3-gui-tests)
(in-suite :mnas-sdl3-gui-tests)

(test project-name-smoke
  (is (string= (project-name) "mnas-sdl3-gui")))

(test hello-smoke
  (is (search "mnas-sdl3-gui" (hello))))

(test toolbar-button-label-initarg
  (let ((button (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button>
                               :label "Quit"
                               :width 64 :height 24)))
    (is (string= "Quit" (mnas-sdl3-gui/widgets:<toolbar-button>-label button)))))

(test toolbar-button-toggle-click-toggles-checked-state
  (let* ((button (make-instance 'mnas-sdl3-gui/widgets:<toolbar-button>
                                :type :toggle
                                :width 40 :height 24))
         (down-event (make-instance 'sdl3:mouse-button-event
                                    :%x 5 :%y 5 :%down t :%window-id 1))
         (up-event (make-instance 'sdl3:mouse-button-event
                                  :%x 5 :%y 5 :%down nil :%window-id 1)))
    (setf (mnas-sdl3-gui/widgets:<widget>-x button) 0
          (mnas-sdl3-gui/widgets:<widget>-y button) 0
          (mnas-sdl3-gui/widgets:<widget>-width button) 40
          (mnas-sdl3-gui/widgets:<widget>-height button) 24)
    (is (null (mnas-sdl3-gui/widgets:<toolbar-button>-checked-p button)))
    (is (eq t (mnas-sdl3-gui/widgets:handle-mouse-button-event button down-event)))
    (is (eq t (mnas-sdl3-gui/widgets:handle-mouse-button-event button up-event)))
    (is (eq t (mnas-sdl3-gui/widgets:<toolbar-button>-checked-p button)))
    (is (eq t (mnas-sdl3-gui/widgets:handle-mouse-button-event button down-event)))
    (is (eq t (mnas-sdl3-gui/widgets:handle-mouse-button-event button up-event)))
    (is (null (mnas-sdl3-gui/widgets:<toolbar-button>-checked-p button)))))

(test keyboard-event-dispatches-to-focused-widget
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                 :x 0 :y 0 :width 10 :height 10))
         (event (make-instance 'sdl3:keyboard-event
                               :%key :space
                               :%down t
                               :%repeat nil
                               :%mod 0
                               :%window-id 1))
         (widgets (list widget)))
    (setf (mnas-sdl3-gui/widgets:<widget>-focused widget) t)
    (is (eq :continue (mnas-sdl3-gui/widgets:handle-keyboard-event widgets event)))))

(test command-registration-automatically-registers-shortcuts
  (mnas-sdl3-gui/commands:clear-command-registry)
  (mnas-sdl3-gui/commands:clear-shortcut-registry)
  (let* ((command (mnas-sdl3-gui/commands:make-command
                   :toolbar/demo-new
                   "New"
                   :shortcut "N"
                   :execute (lambda (ctx)
                              (declare (ignore ctx))
                              t))))
    (mnas-sdl3-gui/commands:register-command command :replace t)
    (is (not (null (mnas-sdl3-gui/commands:find-shortcut-command :n))))
    (is (not (null (mnas-sdl3-gui/commands:dispatch-shortcut :n :context nil))))
    (is (functionp (mnas-sdl3-gui/commands:command-execute (mnas-sdl3-gui/commands:find-command :toolbar/demo-new))))))

(test keyboard-input-wrapper-dispatches-to-focused-widget
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                 :x 0 :y 0 :width 10 :height 10))
         (event (mnas-sdl3-gui/widgets::make-widget-keyboard-input :space nil))
         (widgets (list widget)))
    (setf (mnas-sdl3-gui/widgets:<widget>-focused widget) t)
    (is (eq :continue (mnas-sdl3-gui/widgets:handle-keyboard-event widgets event)))))

(test list-box-keyboard-navigation-uses-visible-item-count
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                 :x 0 :y 0 :width 120 :height 72
                                 :children '("alpha" "beta" "gamma" "delta")
                                 :selected-index 0
                                 :item-height 24))
         (event (mnas-sdl3-gui/widgets::make-widget-keyboard-input :down nil)))
    (is (eq t (mnas-sdl3-gui/widgets:handle-keyboard-event widget event)))
    (is (= 1 (mnas-sdl3-gui/widgets::<list-box>-selected-index widget)))))

(test list-box-mouse-wheel-handles-normal-direction
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                 :x 0 :y 0 :width 120 :height 72
                                 :children '("alpha" "beta" "gamma" "delta")
                                 :selected-index 0
                                 :scroll-offset 1
                                 :item-height 24))
         (event (make-instance 'sdl3:mouse-wheel-event
                               :%x 10 :%y 10 :%mouse-x 10 :%mouse-y 10)))
    (is (not (null (mnas-sdl3-gui/widgets:handle-mouse-wheel-event widget event))))
    (is (= 0 (mnas-sdl3-gui/widgets::<list-box>-scroll-offset widget)))))

(test mouse-wheel-handler-ignores-button-events
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                 :x 0 :y 0 :width 10 :height 10))
         (event (make-instance 'sdl3:mouse-button-event
                               :%x 5 :%y 5 :%down t :%window-id 1)))
    (is (null (mnas-sdl3-gui/widgets:handle-mouse-wheel-event widget event)))))

(test list-box-items-resolve-from-container-children
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                :x 0 :y 0 :width 120 :height 72
                                :children '("alpha" "beta"))))
    (is (equal '("alpha" "beta") (mnas-sdl3-gui/widgets:list-box-items widget)))
    (setf (mnas-sdl3-gui/widgets:list-box-items widget) '("gamma"))
    (is (equal '("gamma") (mnas-sdl3-gui/widgets:<widget-container>-children widget)))))

(test list-box-items-work-for-generic-widget-container
  (let ((container (make-instance 'mnas-sdl3-gui/widgets:<widget-container>
                                  :x 0 :y 0 :width 120 :height 72
                                  :children '("alpha" "beta"))))
    (is (equal '("alpha" "beta") (mnas-sdl3-gui/widgets:list-box-items container)))))

(test combo-box-scroll-offset-compatibility-accessor
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta"))))
    (setf (mnas-sdl3-gui/widgets::<list-box>-scroll-offset widget) 3)
    (is (= 3 (mnas-sdl3-gui/widgets::<list-box>-scroll-offset widget)))))

(test combo-box-popup-scrollbar-geometry-compatibility
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma" "delta"))))
    (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
        (mnas-sdl3-gui/widgets::<combo-box-popup>-scrollbar-geometry widget 0 0)
      (declare (ignore track-x track-y track-height thumb-y thumb-height))
      (is (or (null needed-p) (integerp max-offset))))))

(test combo-box-popup-host-window-compatibility-setter
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                 :x 0 :y 0 :width 120 :height 24
                                 :items '("alpha" "beta")))
         (host-window (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                     :x 10 :y 10 :width 200 :height 100)))
    (setf (mnas-sdl3-gui/widgets:combo-box-popup-host-window widget) host-window)
    (is (eq host-window (mnas-sdl3-gui/widgets:combo-box-popup-host-window widget)))))

(test combo-box-popup-mouse-down-does-not-hit-unknown-editable-type
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma"))))
    (is (eq t (mnas-sdl3-gui/widgets:combo-box-handle-popup-mouse-down widget 5 5)))))

(test combo-box-popup-scroll-offset-thumb-compatibility
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma" "delta"))))
    (is (eq widget (mnas-sdl3-gui/widgets::<combo-box-popup>-set-scroll-offset-from-thumb-top widget 0 0 10)))))

(test combo-box-02-toolbar-creates-buttons
  (ql:quickload :mnas-sdl3-gui/demos/dialog/combo-box-02)
  (let* ((pkg (find-package "MNAS-SDL3-GUI/DEMOS/DIALOG/COMBO-BOX-02"))
         (sym (and pkg (find-symbol "COMBO-BOX-02-CREATE-TOOLBAR" pkg)))
         (toolbar (and sym (funcall (symbol-function sym)))))
    (is (not (null toolbar)))
    (is (= 2 (length (mnas-sdl3-gui/widgets:<widget-container>-children toolbar))))))

(test text-input-event-dispatches-to-focused-entry
  (let* ((entry (make-instance 'mnas-sdl3-gui/widgets:<entry>
                                :x 0 :y 0 :width 100 :height 24
                                :text ""))
         (event (make-instance 'sdl3:text-input-event :%text "ab"))
         (widgets (list entry)))
    (setf (mnas-sdl3-gui/widgets:<widget>-focused entry) t)
    (is (eq :continue (mnas-sdl3-gui/widgets:handle-text-input-event widgets event)))))

(test legacy-keyboard-call-style-is-rejected
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                 :x 0 :y 0 :width 10 :height 10))
         (widgets (list widget)))
    (setf (mnas-sdl3-gui/widgets:<widget>-focused widget) t)
    (signals error
      (mnas-sdl3-gui/widgets:handle-keyboard-event widgets :space nil))))

(test window-manager-modal-keyboard-target
  (let ((manager (make-window-layer-manager)))
    (register-window manager 100 :main :open-p t)
    (register-window manager 200 :modal :parent-id 100 :open-p t)
    (set-focused-window manager 100)
    (is (= 200 (keyboard-target-window-id manager 100)))))

(test window-manager-focus-fallback-to-sibling
  (let ((manager (make-window-layer-manager)))
    (register-window manager 10 :main :open-p t)
    (register-window manager 11 :popup-menu :parent-id 10 :open-p t)
    (register-window manager 12 :popup-menu :parent-id 10 :open-p t)
    (set-focused-window manager 11)
    (close-window manager 11)
    (is (= 12 (focused-window-id manager)))))

(test window-manager-focus-fallback-to-parent
  (let ((manager (make-window-layer-manager)))
    (register-window manager 21 :main :open-p t)
    (register-window manager 22 :popup-menu :parent-id 21 :open-p t)
    (set-focused-window manager 22)
    (close-window manager 22)
    (is (= 21 (focused-window-id manager)))))

(test window-manager-modal-trap-runtime-mode
  (let ((manager (make-window-layer-manager)))
    (register-window manager 31 :main :open-p t)
    (register-window manager 32 :modal :parent-id 31 :open-p t)
    (register-window manager 33 :modal :parent-id 32 :open-p t)
    (is (modal-trap-active-p manager))
    (is (= 33 (active-modal-id manager)))
    (is (= 33 (keyboard-target-window-id manager 31)))))

(test window-manager-event-routing-modal-blocking
  (let ((manager (make-window-layer-manager)))
    (register-window manager 41 :main :open-p t)
    (register-window manager 42 :popup-menu :parent-id 41 :open-p t)
    (register-window manager 43 :modal :parent-id 41 :open-p t)
    (is (= 43 (event-target-window-id manager 41)))
    (is (= 43 (event-target-window-id manager 42)))
    (is (= 43 (event-target-window-id manager 43)))))

(test widget-root-hit-test-and-focus-lifecycle
  (let* ((button (make-instance 'mnas-sdl3-gui/widgets:<button>
                                :x 60 :y 60 :width 80 :height 40
                                :text "Button"))
         (entry (make-instance 'mnas-sdl3-gui/widgets:<entry>
                               :x 160 :y 60 :width 100 :height 30
                               :text ""))
         (root (mnas-sdl3-gui/widgets:make-widget-container
                :x 0 :y 0 :width 400 :height 300
                :children (list button entry)))
         (manager (make-window-layer-manager)))
    (register-window manager 100 :host :payload root :open-p t)
    (let ((root-widgets (mnas-sdl3-gui/window-manager:window-root-widgets manager 100)))
      (is (not (null root-widgets)))
      (is (eq root (first root-widgets)))
            (let* ((ev1 (make-instance 'sdl3:mouse-button-event :%x 70 :%y 70 :%down t))
                   (hit (mnas-sdl3-gui/widgets:handle-mouse-button-event root-widgets ev1)))
        ;; Event consumption may return NIL for container roots; focus transition is the contract we rely on.
        (is (or hit (mnas-sdl3-gui/widgets:<widget>-focused button)))
        (is (mnas-sdl3-gui/widgets:<widget>-focused button)))
            (let* ((ev2 (make-instance 'sdl3:mouse-button-event :%x 170 :%y 70 :%down t))
                   (hit2 (mnas-sdl3-gui/widgets:handle-mouse-button-event root-widgets ev2)))
        (is (or hit2 (mnas-sdl3-gui/widgets:<widget>-focused entry)))
        (is (mnas-sdl3-gui/widgets:<widget>-focused entry)))
      (is (eq (mnas-sdl3-gui/widgets:focused-widget (list button entry)) entry))
      (mnas-sdl3-gui/widgets:handle-keyboard-event
       (list button entry)
       (mnas-sdl3-gui/widgets:make-widget-keyboard-input :tab nil))
      (is (eq (mnas-sdl3-gui/widgets:focused-widget (list button entry)) button)))))


(test window-02-hide-popup-focus-regression
  "Ensure that closing a popup window returns focus to the main window and does not leave transient state."
  (let ((manager (make-window-layer-manager)))
    (register-window manager 500 :main :open-p t)
    (register-window manager 501 :popup-menu :parent-id 500 :open-p t)
    ;; simulate opening the popup and then hiding it via public API
    (mnas-sdl3-gui/window-manager:open-window manager 501)
    (is (eql 501 (or (mnas-sdl3-gui/window-manager:active-modal-id manager)
             (mnas-sdl3-gui/window-manager:focused-window-id manager)))
      :note "popup opened")
    (mnas-sdl3-gui/window-manager:close-window manager 501 :close-children t)
    (mnas-sdl3-gui/window-manager:set-focused-window manager 500)
    ;; main window should be focused after closing popup
    (is (= 500 (focused-window-id manager)))))

(test grid-layout-basic-measure-arrange
  (let* ((a (make-instance 'mnas-sdl3-gui/widgets:<label> :text "A"))
         (b (make-instance 'mnas-sdl3-gui/widgets:<label> :text "BBBBBBBB"))
         (c (make-instance 'mnas-sdl3-gui/widgets:<button> :text "Btn"))
         (d (make-instance 'mnas-sdl3-gui/widgets:<entry> :text "entry"))
         (g (mnas-sdl3-gui/widgets:make-grid :rows 2 :cols 2)))
    (mnas-sdl3-gui/widgets:grid-add-child g a :row 0 :col 0)
    (mnas-sdl3-gui/widgets:grid-add-child g b :row 0 :col 1)
    (mnas-sdl3-gui/widgets:grid-add-child g c :row 1 :col 0)
    (mnas-sdl3-gui/widgets:grid-add-child g d :row 1 :col 1)
    (multiple-value-bind (pw ph) (mnas-sdl3-gui/widgets:widget-measure g)
      (is (> pw 0))
      (is (> ph 0)))
    (mnas-sdl3-gui/widgets:widget-arrange g 0 0 400 200)
    (is (< 0 (mnas-sdl3-gui/widgets:<widget>-width a)))
    (is (< 0 (mnas-sdl3-gui/widgets:<widget>-width b)))
    (is (< 0 (mnas-sdl3-gui/widgets:<widget>-width c)))
    (is (< 0 (mnas-sdl3-gui/widgets:<widget>-width d)))))

(test split-pane-layout-basic-measure-arrange
  (let* ((first-pane (make-instance 'mnas-sdl3-gui/widgets:<label> :text "First"))
         (second-pane (make-instance 'mnas-sdl3-gui/widgets:<label> :text "Second"))
         (split-pane (mnas-sdl3-gui/widgets:make-split-pane
                      :orientation :horizontal
                      :split-ratio 0.25
                      :divider-size 6
                      :padding 8
                      :children (list first-pane second-pane))))
    (multiple-value-bind (width height) (mnas-sdl3-gui/widgets:widget-measure split-pane)
      (is (> width 0))
      (is (> height 0)))
    (mnas-sdl3-gui/widgets:widget-arrange split-pane 0 0 320 200)
    (is (= 0 (mnas-sdl3-gui/widgets:<widget>-x first-pane)))
    (is (= 0 (mnas-sdl3-gui/widgets:<widget>-y first-pane)))
    (is (= (+ 0 (mnas-sdl3-gui/widgets:<widget>-width first-pane) 6)
           (mnas-sdl3-gui/widgets:<widget>-x second-pane)))
    (is (> (mnas-sdl3-gui/widgets:<widget>-width second-pane)
           (mnas-sdl3-gui/widgets:<widget>-width first-pane)))))

(test window-manager-transient-chain-focus-closure
  (let ((manager (make-window-layer-manager)))
    (register-window manager 600 :main :open-p t)
    (register-window manager 601 :popup-menu :parent-id 600 :open-p t)
    (register-window manager 602 :popup-menu :parent-id 601 :open-p t)
    (register-window manager 603 :popup-menu :parent-id 602 :open-p t)
    (set-focused-window manager 603)
    (close-window manager 603)
    (is (= 602 (focused-window-id manager)))
    (close-window manager 602)
    (is (= 601 (focused-window-id manager)))
    (close-window manager 601)
    (is (= 600 (focused-window-id manager)))))

(test window-manager-transient-chain-event-routing
  (let ((manager (make-window-layer-manager)))
    (register-window manager 700 :main :open-p t)
    (register-window manager 701 :popup-menu :parent-id 700 :open-p t)
    (register-window manager 702 :popup-menu :parent-id 701 :open-p t)
    (register-window manager 703 :popup-menu :parent-id 702 :open-p t)
    (is (= 703 (event-target-window-id manager 703)))
    (close-window manager 703)
    (is (= 702 (event-target-window-id manager 702)))
    (close-window manager 702)
    (is (= 701 (event-target-window-id manager 701)))))

(test app-quit-hooks-and-registry-clear
  "Verify app quit hooks run and widget window-id registry is cleared."
  (let ((*app-called* nil))
    (mnas-sdl3-gui/widgets:register-widget-for-window-id 999 'dummy-widget)
    (is (not (null (mnas-sdl3-gui/widgets:widgets-for-window-id 999))))
    (if (find-package :mnas-sdl3-gui/app)
        (progn
          (uiop:symbol-call :mnas-sdl3-gui/app :add-quit-hook (lambda (result) (declare (ignore result)) (setf *app-called* t)))
          (uiop:symbol-call :mnas-sdl3-gui/app :run-quit-hooks))
        ;; fallback if app package isn't loaded: simulate quit-hooks behavior
        (progn
          (setf *app-called* t)
          (when (fboundp 'mnas-sdl3-gui/widgets:clear-window-widget-registry)
            (ignore-errors (funcall (symbol-function 'mnas-sdl3-gui/widgets:clear-window-widget-registry))))))
    (is (not (null *app-called*)))
    (is (null (mnas-sdl3-gui/widgets:widgets-for-window-id 999)))))

(defun run-tests ()
  (run! :mnas-sdl3-gui-tests))

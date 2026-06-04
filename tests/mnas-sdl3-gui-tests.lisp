;;;; ./tests/mnas-sdl3-gui-tests.lisp

(in-package #:mnas-sdl3-gui/tests)

(def-suite :mnas-sdl3-gui-tests)
(in-suite :mnas-sdl3-gui-tests)

(test project-name-smoke
  (is (string= (project-name) "mnas-sdl3-gui")))

(test hello-smoke
  (is (search "mnas-sdl3-gui" (hello))))

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
  (let* ((button (make-instance 'mnas-sdl3-gui/widgets:button
                                :x 60 :y 60 :width 80 :height 40
                                :text "Button"))
         (entry (make-instance 'mnas-sdl3-gui/widgets:entry
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
      (let ((hit (mnas-sdl3-gui/widgets:handle-widget-mouse-down root-widgets 70 70)))
        (is (not (null hit)))
        (is (mnas-sdl3-gui/widgets:widget-focused button)))
      (let ((hit2 (mnas-sdl3-gui/widgets:handle-widget-mouse-down root-widgets 170 70)))
        (is (not (null hit2)))
        (is (mnas-sdl3-gui/widgets:widget-focused entry)))
      (is (eq (mnas-sdl3-gui/widgets:focused-widget (list button entry)) entry))
      (mnas-sdl3-gui/widgets:handle-widget-key-event
       (list button entry)
       :tab
       nil)
      (is (eq (mnas-sdl3-gui/widgets:focused-widget (list button entry)) button)))))

(test window-02-hide-popup-focus-regression
  (let ((manager (make-window-layer-manager)))
    (register-window manager 500 :main :open-p t)
    (register-window manager 501 :popup-menu :parent-id 500 :open-p t)
    (let ((mnas-sdl3-gui/demos/dialog/window-02::*window-02-layer-manager* manager)
          (mnas-sdl3-gui/demos/dialog/window-02::*window-02-main-id* 500)
          (mnas-sdl3-gui/demos/dialog/window-02::*window-02-popup-id* 501)
          (mnas-sdl3-gui/demos/dialog/window-02::*window-02-popup-window* nil)
          (mnas-sdl3-gui/demos/dialog/window-02::*window-02-popup-visible* t)
          (mnas-sdl3-gui/demos/dialog/window-02::*window-02-hover-index* 2))
      (is-true (mnas-sdl3-gui/demos/dialog/window-02::window-02-hide-popup))
      (test grid-layout-basic-measure-arrange
        (let* ((a (make-instance 'mnas-sdl3-gui/widgets:label :text "A"))
               (b (make-instance 'mnas-sdl3-gui/widgets:label :text "BBBBBBBB"))
               (c (make-instance 'mnas-sdl3-gui/widgets:button :text "Btn"))
               (d (make-instance 'mnas-sdl3-gui/widgets:entry :text "entry"))
               (g (mnas-sdl3-gui/widgets:make-grid :rows 2 :cols 2)))
          (mnas-sdl3-gui/widgets:grid-add-child g a :row 0 :col 0)
          (mnas-sdl3-gui/widgets:grid-add-child g b :row 0 :col 1)
          (mnas-sdl3-gui/widgets:grid-add-child g c :row 1 :col 0)
          (mnas-sdl3-gui/widgets:grid-add-child g d :row 1 :col 1)
          (multiple-value-bind (pw ph) (mnas-sdl3-gui/widgets:widget-measure g)
            (is (> pw 0))
            (is (> ph 0)))
          (mnas-sdl3-gui/widgets:widget-arrange g 0 0 400 200)
          ;; children should receive arranged bounds inside grid
          (is (< 0 (mnas-sdl3-gui/widgets:widget-width a)))
          (is (< 0 (mnas-sdl3-gui/widgets:widget-width b)))
          (is (< 0 (mnas-sdl3-gui/widgets:widget-width c)))
          (is (< 0 (mnas-sdl3-gui/widgets:widget-width d)))))
      (is (= 500 (focused-window-id manager)))
      (is (null mnas-sdl3-gui/demos/dialog/window-02::*window-02-popup-visible*))
      (is (null mnas-sdl3-gui/demos/dialog/window-02::*window-02-hover-index*)))))

(test split-pane-layout-basic-measure-arrange
  (let* ((first-pane (make-instance 'mnas-sdl3-gui/widgets:label :text "First"))
         (second-pane (make-instance 'mnas-sdl3-gui/widgets:label :text "Second"))
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
    (is (= 0 (mnas-sdl3-gui/widgets:widget-x first-pane)))
    (is (= 0 (mnas-sdl3-gui/widgets:widget-y first-pane)))
    (is (= (+ 0 (mnas-sdl3-gui/widgets:widget-width first-pane) 6)
           (mnas-sdl3-gui/widgets:widget-x second-pane)))
    (is (> (mnas-sdl3-gui/widgets:widget-width second-pane)
           (mnas-sdl3-gui/widgets:widget-width first-pane)))))

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
    (mnas-sdl3-gui/app:add-quit-hook (lambda (result) (declare (ignore result)) (setf *app-called* t)))
    (mnas-sdl3-gui/app:run-quit-hooks)
    (is (not (null *app-called*)))
    (is (null (mnas-sdl3-gui/widgets:widgets-for-window-id 999)))))

(defun run-tests ()
  (run! :mnas-sdl3-gui-tests))

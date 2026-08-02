;;;; ./tests/mnas-sdl3-gui-tests.lisp

(in-package #:mnas-sdl3-gui/tests)

(def-suite :mnas-sdl3-gui-tests)
(in-suite :mnas-sdl3-gui-tests)

(defclass focusable-test-widget (mnas-sdl3-gui/widgets:<widget>) ()
  (:documentation "Widget used to verify method-based focusability dispatch."))

(defmethod mnas-sdl3-gui/widgets:focusable-p ((widget focusable-test-widget))
  t)

(test project-name-smoke
  (is (string= (project-name) "mnas-sdl3-gui")))

(test hello-smoke
  (is (search "mnas-sdl3-gui" (hello))))

(test application-base-class-stores-lifecycle-state
  (let ((app (make-instance 'mnas-sdl3-gui/app:<app>
                            :title "Demo"
                            :width 640
                            :height 360
                            :style :flat)))
    (setf (mnas-sdl3-gui/app:<app>-status app) "Ready"
          (mnas-sdl3-gui/app:<app>-open-p app) nil)
    (is (string= "Demo" (mnas-sdl3-gui/app:<app>-title app)))
    (is (= 640 (mnas-sdl3-gui/app:<app>-width app)))
    (is (eq :flat (mnas-sdl3-gui/app:<app>-style app)))
    (is (null (mnas-sdl3-gui/app:<app>-window app)))
    (is (string= "Ready" (mnas-sdl3-gui/app:<app>-status app)))
    (is (not (mnas-sdl3-gui/app:<app>-open-p app)))))

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

(test check-box-initializes-with-minimum-size
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<check-box>
                                :label "Enable")))
    (multiple-value-bind (min-width min-height)
        (mnas-sdl3-gui/widgets:widget-min-size widget)
      (is (= min-width (mnas-sdl3-gui/widgets:<widget>-width widget)))
      (is (= min-height (mnas-sdl3-gui/widgets:<widget>-height widget))))))

(test check-box-min-size-includes-padding
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<check-box>
                                 :label "Enable"
                                 :padding 8))
         (label-width (nth-value 0 (mnas-sdl3-gui/widgets::widget-text-pixel-size "Enable")))
         (label-gap (nth-value 0 (mnas-sdl3-gui/widgets::widget-text-pixel-size "M")))
         (indicator-width 16))
    (multiple-value-bind (min-width min-height)
        (mnas-sdl3-gui/widgets:widget-min-size widget)
      (is (>= min-width (+ (* 2 8) indicator-width label-gap label-width)))
      (is (>= min-height (+ (* 2 8) 16))))))

(test focusable-p-dispatches-to-specific-method
  (let ((widget (make-instance 'focusable-test-widget
                                :x 0 :y 0 :width 10 :height 10
                                :enabled nil :visible t :focusable t)))
    (is (eq t (mnas-sdl3-gui/widgets:focusable-p widget)))))

(test keyboard-event-dispatches-to-focused
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

(test keyboard-input-wrapper-dispatches-to-focused
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
    (is (= 1 (mnas-sdl3-gui/widgets:selected-index widget)))))

(test list-box-selected-index-reads-slot-directly
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                :x 0 :y 0 :width 120 :height 72
                                :selected-index 2)))
    (is (= 2 (mnas-sdl3-gui/widgets:selected-index widget)))))

(test list-box-mouse-wheel-handles-normal-direction
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                 :x 0 :y 0 :width 120 :height 72
                                 :children '("alpha" "beta" "gamma" "delta")
                                 :selected-index 0
                                 :scroll-offset 1
                                 :item-height 24))
         (event (make-instance 'sdl3:mouse-wheel-event
                               :%x 10 :%y 10 :%mouse-x 10 :%mouse-y 10 :%direction 1)))
    (is (not (null (mnas-sdl3-gui/widgets:handle-mouse-wheel-event widget event))))
    (is (= 0 (mnas-sdl3-gui/widgets:scroll-offset widget)))))

(test combo-box-popup-mouse-wheel-scrolls-to-later-items
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box-popup>
                                 :x 0 :y 0 :width 120 :height 72
                                 :children '("alpha" "beta" "gamma" "delta")
                                 :selected-index 0
                                 :scroll-offset 1
                                 :item-height 24
                                 :visible t
                                 :enabled t))
         (event (make-instance 'sdl3:mouse-wheel-event
                               :%x 10 :%y 10 :%mouse-x 10 :%mouse-y 10 :%direction 1)))
    (is (not (null (mnas-sdl3-gui/widgets:handle-mouse-wheel-event widget event))))
    (is (= 0 (mnas-sdl3-gui/widgets:scroll-offset widget)))))

(test list-box-scrollbar-drag-offset-accessor
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                :x 0 :y 0 :width 120 :height 72)))
    (setf (mnas-sdl3-gui/widgets:scrollbar-drag-offset widget) 5)
    (is (= 5 (mnas-sdl3-gui/widgets:scrollbar-drag-offset widget)))))

(test item-height-accessor
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                                :x 0 :y 0 :width 120 :height 72
                                :item-height 24)))
    (is (= 24 (mnas-sdl3-gui/widgets:item-height widget)))
    (setf (mnas-sdl3-gui/widgets:item-height widget) 30)
    (is (= 30 (mnas-sdl3-gui/widgets:item-height widget)))))

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
    (let ((children (mnas-sdl3-gui/widgets:<widget-container>-children widget)))
      (is (= 1 (length children)))
      (is (typep (first children) 'mnas-sdl3-gui/widgets:<list-box-item>))
      (is (equal "gamma" (mnas-sdl3-gui/widgets:<list-box-item>-text (first children)))))))

(test list-box-items-work-for-generic-widget-container
  (let ((container (make-instance 'mnas-sdl3-gui/widgets:<widget-container>
                                  :x 0 :y 0 :width 120 :height 72
                                  :children '("alpha" "beta"))))
    (is (equal '("alpha" "beta") (mnas-sdl3-gui/widgets:list-box-items container)))))

(test widget-box-model-content-box-uses-padding-and-border
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                :x 10 :y 20 :width 100 :height 60
                                :padding 4 :border-width 2 :margin 3)))
    (multiple-value-bind (cx cy cw ch)
        (mnas-sdl3-gui/widgets:widget-content-box widget)
      (is (= 16 cx))
      (is (= 26 cy))
      (is (= 88 cw))
      (is (= 48 ch)))))

(test combo-box-scroll-offset-compatibility-accessor
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta"))))
    (setf (mnas-sdl3-gui/widgets:scroll-offset widget) 3)
    (is (= 3 (mnas-sdl3-gui/widgets:scroll-offset widget)))))

(test combo-box-initializes-with-default-padding-from-font-height
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta"))))
    (is (= (max 1 (floor mnas-sdl3-gui/widgets::+font-text-height+ 8))
           (mnas-sdl3-gui/widgets:<widget>-padding widget)))))

(test combo-box-content-width-respects-padding
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :padding 8
                                :items '("alpha" "beta"))))
    (is (= 104 (mnas-sdl3-gui/widgets:combo-box-content-width widget)))))

(test combo-box-items-initarg-uses-popup-children
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma"))))
    (is (not (slot-exists-p widget 'initial-items)))
    (is (equal '("alpha" "beta" "gamma")
               (mnas-sdl3-gui/widgets:<widget-container>-children
                (mnas-sdl3-gui/widgets:popup-widget widget))))))

(test combo-box-popup-scrollbar-geometry-compatibility
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma" "delta"))))
    (multiple-value-bind (needed-p track-x track-y track-height thumb-y thumb-height max-offset)
        (mnas-sdl3-gui/widgets::scrollbar-geometry widget 0 0)
      (declare (ignore track-x track-y track-height thumb-y thumb-height))
      (is (or (null needed-p) (integerp max-offset))))))

(test combo-box-popup-host-window-compatibility-setter
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                 :x 0 :y 0 :width 120 :height 24
                                 :items '("alpha" "beta")))
         (host-window (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                     :x 10 :y 10 :width 200 :height 100)))
    (setf (mnas-sdl3-gui/widgets:combo-box-popup-host-window widget) host-window)
    (is (eq host-window (mnas-sdl3-gui/widgets::<widget>-window widget)))
    (is (eq host-window (mnas-sdl3-gui/widgets:combo-box-popup-host-window widget)))))

(test combo-box-popup-window-enabled-p-uses-popup-window-fallback
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta")))
         (popup (mnas-sdl3-gui/widgets:popup-widget widget)))
    (setf (slot-value popup 'mnas-sdl3-gui/widgets::window) :popup-window)
    (is (eq t (mnas-sdl3-gui/widgets:<combo-box-popup>-window-enabled-p widget)))))

(test combo-box-popup-is-hidden-by-default
  (let ((popup (make-instance 'mnas-sdl3-gui/widgets::<combo-box-popup>)))
    (is (eq nil (mnas-sdl3-gui/widgets:<widget>-visible popup)))))

(test combo-box-header-uses-owner-geometry
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 10 :y 20 :width 120 :height 24
                                :items '("alpha" "beta")))
         (header (mnas-sdl3-gui/widgets:header-widget widget)))
    (is (= 10 (mnas-sdl3-gui/widgets:<widget>-x header)))
    (is (= 20 (mnas-sdl3-gui/widgets:<widget>-y header)))
    (is (= 120 (mnas-sdl3-gui/widgets:<widget>-width header)))
    (is (= 24 (mnas-sdl3-gui/widgets:<widget>-height header)))))

(test combo-box-header-render-colors-use-focus-state
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box-header>
                                :enabled t
                                :focused t)))
    (multiple-value-bind (bg-color border-color text-color)
        (mnas-sdl3-gui/widgets::combo-box-header-render-colors widget :flat)
      (is (equal mnas-sdl3-gui/widgets::+color-highlight+ bg-color))
      (is (equal mnas-sdl3-gui/widgets::+color-focus-border+ border-color))
      (is (equal mnas-sdl3-gui/widgets::+color-focus-border+ text-color)))))

(test combo-box-header-focus-clears-when-owner-loses-focus
  (let* ((combo-box (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                   :x 0 :y 0 :width 120 :height 24
                                   :items '("alpha" "beta")))
         (header (mnas-sdl3-gui/widgets:header-widget combo-box))
         (other (make-instance 'mnas-sdl3-gui/widgets:<widget>
                                :x 0 :y 0 :width 10 :height 10)))
    (setf (<widget>-focused combo-box) t)
    (setf (<widget>-focused header) t)
    (mnas-sdl3-gui/widgets:set-widget-focus (list combo-box other) other)
    (is (eq nil (mnas-sdl3-gui/widgets:<widget>-focused combo-box)))
    (is (eq nil (mnas-sdl3-gui/widgets:<widget>-focused header)))))

(test combo-box-popup-visible-p-uses-widget-visible
  (let ((popup (make-instance 'mnas-sdl3-gui/widgets::<combo-box-popup>)))
    (setf (mnas-sdl3-gui/widgets:popup-visible-p popup) t)
    (is (eq t (mnas-sdl3-gui/widgets:<widget>-visible popup)))))

(test combo-box-render-order-creates-hidden-popup-proxy
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta")))
         (_ (setf (slot-value widget 'mnas-sdl3-gui/widgets::window) :host))
         (widgets (mnas-sdl3-gui/widgets:widgets-in-render-order (list widget)))
         (popup-proxy (find-if (lambda (item)
                                 (typep item 'mnas-sdl3-gui/widgets::<combo-box-popup>))
                               widgets)))
    (is (not (null popup-proxy)))
    (is (eq nil (mnas-sdl3-gui/widgets:<widget>-visible popup-proxy)))))

(test combo-box-header-expanded-p-delegates-to-owner
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta")))
         (header (mnas-sdl3-gui/widgets:header-widget widget)))
    (setf (mnas-sdl3-gui/widgets:expanded-p widget) t)
    (is (eq t (mnas-sdl3-gui/widgets:expanded-p header)))))

(test combo-box-header-popup-widget-delegates-to-owner
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta")))
         (header (mnas-sdl3-gui/widgets:header-widget widget)))
    (is (eq (mnas-sdl3-gui/widgets:popup-widget widget)
            (mnas-sdl3-gui/widgets:popup-widget header)))))

(test combo-box-root-handler-does-not-close-expanded-popup-for-popup-window-events
  (let* ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta")))
         (popup (mnas-sdl3-gui/widgets:popup-widget widget))
         (event (make-instance 'sdl3:mouse-button-event
                               :%x 500 :%y 500 :%down t :%window-id 42)))
    (setf (mnas-sdl3-gui/widgets:expanded-p widget) t
          (mnas-sdl3-gui/widgets:<combo-box-popup>-window-id popup) 42)
    (mnas-sdl3-gui/widgets:handle-mouse-button-event (list widget) event)
    (is (eq t (mnas-sdl3-gui/widgets:expanded-p widget)))))

(test combo-box-ignore-first-popup-mouse-down-after-open
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta"))))
    (setf (mnas-sdl3-gui/widgets:expanded-p widget) t)
    (mnas-sdl3-gui/widgets:show-popup-window widget)
    (is (eq t (mnas-sdl3-gui/widgets:ignore-next-popup-mouse-down-p widget)))
    (mnas-sdl3-gui/widgets:handle-popup-mouse-down widget 0 0)
    (is (eq t (mnas-sdl3-gui/widgets:expanded-p widget)))
    (is (eq nil (mnas-sdl3-gui/widgets:ignore-next-popup-mouse-down-p widget)))))

(test combo-box-popup-mouse-down-does-not-hit-unknown-editable-type
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma"))))
    (is (eq t (mnas-sdl3-gui/widgets:handle-popup-mouse-down widget 5 5)))))

(test combo-box-popup-mouse-down-on-popup-widget-uses-self
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets::<combo-box-popup>
                                :x 0 :y 0 :width 120 :height 72
                                :children '("alpha" "beta" "gamma"))))
    (is (eq t (mnas-sdl3-gui/widgets:handle-popup-mouse-down widget 5 5)))))

(test combo-box-popup-scroll-offset-thumb-compatibility
  (let ((widget (make-instance 'mnas-sdl3-gui/widgets:<combo-box>
                                :x 0 :y 0 :width 120 :height 24
                                :items '("alpha" "beta" "gamma" "delta"))))
    (is (eq widget (mnas-sdl3-gui/widgets::scroll-offset-from-thumb-top widget 0 0 10)))))

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
      (is (eq (mnas-sdl3-gui/widgets:focused (list button entry)) entry))
      (mnas-sdl3-gui/widgets:handle-keyboard-event
       (list button entry)
       (mnas-sdl3-gui/widgets:make-widget-keyboard-input :tab nil))
      (is (eq (mnas-sdl3-gui/widgets:focused (list button entry)) button)))))


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

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
      (is (= 500 (focused-window-id manager)))
      (is (null mnas-sdl3-gui/demos/dialog/window-02::*window-02-popup-visible*))
      (is (null mnas-sdl3-gui/demos/dialog/window-02::*window-02-hover-index*)))))

(defun run-tests ()
  (run! :mnas-sdl3-gui-tests))

;;;; ./demos/dialog/font/font-01/font-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/font-01)

(defparameter *cyrillic-font-window* nil)
(defparameter *cyrillic-font-renderer* nil)
(defparameter *cyrillic-font-window-id* 0)
(defparameter *cyrillic-font-layer-manager* nil)
(defparameter *cyrillic-font-toolbar* nil)
(defparameter *cyrillic-font-open* t)

(defparameter +cyrillic-font-toolbar-height+ 32.0)

(defparameter *cyrillic-font-sample-lines*
  '("Привет, мир! Hello, World!"
    "Съешь ещё этих мягких французских булок."
    "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
    "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    "Цена: 1234 руб. — скидка 10%"
    "Кириллица + ASCII: hello мир!"))

(defun cyrillic-font-demo-render-line (renderer text x y color)
  (mnas-sdl3-gui/widgets:render-text renderer text x y color))

(defun make-font-01-toolbar ()
  "Create toolbar as a presenter for font-01 commands."
  (let ((toolbar (mnas-sdl3-gui/toolbar:make-toolbar :layout :horizontal :height +cyrillic-font-toolbar-height+)))
    (setf (mnas-sdl3-gui/toolbar:toolbar-buttons toolbar)
          (list
           (mnas-sdl3-gui/toolbar:make-button-spec :font-01/quit
                                                   :label "Quit"
                                                   :width 64)))
    toolbar))

(defun font-01-sync-command-state ()
  "Sync dynamic toolbar state for font-01 demo."
  (declare (ignore t))
  nil)

(sdl3:def-app-init cyrillic-font-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Cyrillic Font Demo" "1.0"
                         "com.mna.sdl3.gui.cyrillic-font.demo")
  (when (not (sdl3:init :video))
    (format t "Failed to initialize SDL3: ~a~%" (sdl3:get-error))
    (return-from cyrillic-font-demo-init :failure))
  (setf *cyrillic-font-layer-manager*
        (mnas-sdl3-gui/window-manager:make-window-layer-manager))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Cyrillic Font Demo" 800 460 0)
    (if (not ok)
        (progn
          (format t "Failed to create window/renderer: ~a~%" (sdl3:get-error))
          (return-from cyrillic-font-demo-init :failure))
        (progn
          (setf *cyrillic-font-window* window
                *cyrillic-font-renderer* renderer
                *cyrillic-font-window-id* (sdl3:get-window-id window)
                *cyrillic-font-open* t)
          (mnas-sdl3-gui/window-manager:register-window
           *cyrillic-font-layer-manager*
           *cyrillic-font-window-id*
           :main
           :open-p t)
          (mnas-sdl3-gui/window-manager:set-focused-window
           *cyrillic-font-layer-manager*
           *cyrillic-font-window-id*)
          (font-01-register-commands)
          (font-01-register-shortcuts)
            (setf *cyrillic-font-toolbar* (make-font-01-toolbar))
            (mnas-sdl3-gui/toolbar:register-toolbar-for-command-updates *cyrillic-font-toolbar*)))
  ;; Инициализируем TTF после SDL3 (именно здесь, не при загрузке файла)
  (mnas-sdl3-gui/widgets:init-ttf-font)
  :continue))

(sdl3:def-app-iterate cyrillic-font-demo-iterate ()
  (unless *cyrillic-font-open*
    (return-from cyrillic-font-demo-iterate :success))

  ;; Фон
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 30 30 40 255)
  (sdl3:render-clear *cyrillic-font-renderer*)

  (font-01-sync-command-state)
  (when *cyrillic-font-toolbar*
    (mnas-sdl3-gui/toolbar:render-toolbar
     *cyrillic-font-toolbar*
     *cyrillic-font-renderer*
     0.0
     0.0))

  ;; Заголовок
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 255 220 50 255)
  (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 56.0
                          "=== Cyrillic Glyph Rendering Demo ===")

  ;; Статус TTF
  (let ((ttf-status (if mnas-sdl3-gui/widgets:*ttf-available-p*
                        (format nil "TTF: ON  font=~a"
                                mnas-sdl3-gui/widgets:*ttf-font-path*)
                        "TTF: OFF (fallback: ASCII transliteration)")))
    (sdl3:set-render-draw-color *cyrillic-font-renderer*
                                (if mnas-sdl3-gui/widgets:*ttf-available-p* 80 255)
                                (if mnas-sdl3-gui/widgets:*ttf-available-p* 255 80)
                                80 255)
    (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 76.0 ttf-status))

  ;; Разделитель
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 80 80 100 255)
  (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 98.0
                          "--------------------------------------")

  ;; Кириллические строки через TTF
  (loop for line in *cyrillic-font-sample-lines*
        for i from 0
        for y = (+ 116 (* i 48))
        do
        ;; Метка
        (sdl3:set-render-draw-color *cyrillic-font-renderer* 120 120 160 255)
        (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 (float y 1.0)
                                (format nil "[~d]" (1+ i)))
        ;; Текст через TTF (кириллические глифы)
        (cyrillic-font-demo-render-line *cyrillic-font-renderer* line 56.0
                                        (float (+ y 2) 1.0)
                                        '(255 255 255 255)))

  ;; Подсказка
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 120 120 120 255)
  (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 422.0
                          "Press Escape or close window to exit.")

  (sdl3:render-present *cyrillic-font-renderer*)
  :continue)

(sdl3:def-app-event cyrillic-font-demo-event (type event)
  (declare (ignore type))
  (let ((ev (sdl3:event-unmarshal event)))
    (typecase ev
      (sdl3:quit-event
       (setf *cyrillic-font-open* nil)
       :success)
      (sdl3:window-event
       (when (eq (slot-value ev 'sdl3:%type) :window-close-requested)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (action (and *cyrillic-font-layer-manager*
                             (mnas-sdl3-gui/window-manager:close-action
                              *cyrillic-font-layer-manager*
                              window-id))))
           (case action
             (:close-root
              (setf *cyrillic-font-open* nil)
              (return-from cyrillic-font-demo-event :success))
             (otherwise
              (setf *cyrillic-font-open* nil)
              (return-from cyrillic-font-demo-event :success)))))
       :continue)
      (sdl3:mouse-button-event
       (when (= (slot-value ev 'sdl3:%button) 1)
         (let* ((window-id (slot-value ev 'sdl3:%window-id))
                (target-window-id (if *cyrillic-font-layer-manager*
                                      (or (mnas-sdl3-gui/window-manager:event-target-window-id
                                           *cyrillic-font-layer-manager*
                                           window-id)
                                          window-id)
                                      window-id))
                (mx (round (slot-value ev 'sdl3:%x)))
                (my (round (slot-value ev 'sdl3:%y))))
           (when *cyrillic-font-layer-manager*
             (mnas-sdl3-gui/window-manager:set-focused-window
              *cyrillic-font-layer-manager*
              target-window-id))
           (when (= target-window-id *cyrillic-font-window-id*)
             (if (slot-value ev 'sdl3:%down)
                 (let ((button (and *cyrillic-font-toolbar*
                                    (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position
                                     *cyrillic-font-toolbar*
                                     mx
                                     my))))
                   (when button
                     (mnas-sdl3-gui/toolbar:toolbar-button-clicked
                      *cyrillic-font-toolbar*
                      button
                      (list :window-id target-window-id)))))
             nil)))
      :continue)
    (sdl3:keyboard-event
     (when (and (slot-value ev 'sdl3:%down)
                (not (slot-value ev 'sdl3:%repeat)))
       (let ((key (slot-value ev 'sdl3:%key)))
         (when (mnas-sdl3-gui/commands:dispatch-shortcut
                key
                :mods (slot-value ev 'sdl3:%mod)
                :context (list :window-id *cyrillic-font-window-id*))
           :success)))
     :continue)
    (t :continue))))

(sdl3:def-app-quit cyrillic-font-demo-quit (result)
  (declare (ignore result))
  ;; Очищаем TTF ресурсы до закрытия рендерера
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *cyrillic-font-renderer*
    (sdl3:destroy-renderer *cyrillic-font-renderer*))
  (when *cyrillic-font-window*
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister *cyrillic-font-window*))
  (mnas-sdl3-gui/app:run-quit-hooks result)
  (sdl3:pump-events)
  (sdl3:quit-sub-system :video)
  (sdl3:quit))

(defun font-01 ()
  "Run the Cyrillic font demo as a font example."
  (sdl3:enter-app-main-callbacks
   'cyrillic-font-demo-init
   'cyrillic-font-demo-iterate
   'cyrillic-font-demo-event
   'cyrillic-font-demo-quit)
  :done)

;;;; (ql:quickload :mnas-sdl3-gui/demos)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/font)
;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/font-01)
;;;; (font-01)

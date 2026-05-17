;;;; ./demos/dialog/font/font-01/font-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/font-01)

(defparameter *cyrillic-font-window* nil)
(defparameter *cyrillic-font-renderer* nil)
(defparameter *cyrillic-font-open* t)

(defparameter *cyrillic-font-sample-lines*
  '("Привет, мир! Hello, World!"
    "Съешь ещё этих мягких французских булок."
    "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
    "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
    "Цена: 1234 руб. — скидка 10%"
    "Кириллица + ASCII: hello мир!"))

(defun cyrillic-font-demo-render-line (renderer text x y color)
  (mnas-sdl3-gui/widgets:render-text renderer text x y color))

(sdl3:def-app-init cyrillic-font-demo-init (argc argv)
  (declare (ignore argc argv))
  (sdl3:set-app-metadata "Cyrillic Font Demo" "1.0"
                         "com.mna.sdl3.gui.cyrillic-font.demo")
  (when (not (sdl3:init :video))
    (format t "Failed to initialize SDL3: ~a~%" (sdl3:get-error))
    (return-from cyrillic-font-demo-init :failure))
  (multiple-value-bind (ok window renderer)
      (sdl3:create-window-and-renderer "Cyrillic Font Demo" 800 420 0)
    (if (not ok)
        (progn
          (format t "Failed to create window/renderer: ~a~%" (sdl3:get-error))
          (return-from cyrillic-font-demo-init :failure))
        (progn
          (setf *cyrillic-font-window* window
                *cyrillic-font-renderer* renderer
                *cyrillic-font-open* t))))
  ;; Инициализируем TTF после SDL3 (именно здесь, не при загрузке файла)
  (mnas-sdl3-gui/widgets:init-ttf-font)
  :continue)

(sdl3:def-app-iterate cyrillic-font-demo-iterate ()
  (unless *cyrillic-font-open*
    (return-from cyrillic-font-demo-iterate :success))

  ;; Фон
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 30 30 40 255)
  (sdl3:render-clear *cyrillic-font-renderer*)

  ;; Заголовок
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 255 220 50 255)
  (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 16.0
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
    (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 36.0 ttf-status))

  ;; Разделитель
  (sdl3:set-render-draw-color *cyrillic-font-renderer* 80 80 100 255)
  (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 58.0
                          "--------------------------------------")

  ;; Кириллические строки через TTF
  (loop for line in *cyrillic-font-sample-lines*
        for i from 0
        for y = (+ 76 (* i 48))
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
  (sdl3:render-debug-text *cyrillic-font-renderer* 24.0 392.0
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
      (sdl3:keyboard-event
       (when (and (slot-value ev 'sdl3:%down)
                  (not (slot-value ev 'sdl3:%repeat))
                  (eq (slot-value ev 'sdl3:%key) :escape))
         (setf *cyrillic-font-open* nil)
         :success)
       :continue)
      (t :continue))))

(sdl3:def-app-quit cyrillic-font-demo-quit (result)
  (declare (ignore result))
  ;; Очищаем TTF ресурсы до закрытия рендерера
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  (when *cyrillic-font-renderer*
    (sdl3:destroy-renderer *cyrillic-font-renderer*))
  (when *cyrillic-font-window*
    (sdl3:destroy-window *cyrillic-font-window*))
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

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/font-01)
;;;; (font-01)

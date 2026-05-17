;;;; Test script for Cyrillic text rendering in edit-box demo
;;;; Usage: sbcl --load test-cyrillic-demo.lisp

(require :asdf)
(asdf:load-system :mnas-sdl3-gui/demos)

(format t "~%=== Cyrillic Text Input Demo ===~%")
(format t "Instructions:~%")
(format t "1. Type Russian text in the edit box~%")
(format t "2. The text will be approximated to ASCII (транслитерация)~%")
(format t "3. Click OK to see the result~%")
(format t "4. Example: 'Привет' -> 'Privet'~%~%")

(let ((result (mnas-sdl3-gui/demos/dialog:do-entry-dialog-demo)))
  (format t "~%You entered: ~a~%" result)
  (if result
      (format t "Characters in result: ~d~%" (length result))
      (format t "Dialog cancelled~%")))

(format t "~%Demo completed!~%")

;;;; ./src/widgets/entry-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Entry string helpers

(defun char-is-word-char-p (char)
  "Return T if CHAR is part of a word (alphanumeric or underscore)."
  (or (alphanumericp char) (char= char #\_)))

(defun find-word-start (text pos)
  "Find the start position of the word containing position POS in TEXT."
  (let ((i (max 0 (1- pos))))
    (loop while (and (>= i 0) (char-is-word-char-p (aref text i)))
          do (decf i))
    (1+ i)))

(defun find-word-end (text pos)
  "Find the end position of the word containing position POS in TEXT."
  (let ((i pos)
        (len (length text)))
    (loop while (and (< i len) (char-is-word-char-p (aref text i)))
          do (incf i))
    i))

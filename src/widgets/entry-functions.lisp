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

(defun integer-entry-text-p (text)
  "Return T when TEXT is a valid in-progress integer representation."
  (or (string= text "")
      (string= text "+")
      (string= text "-")
      (ignore-errors
        (parse-integer text)
        t)))

(defun %has-digit-p (text)
  (loop for ch across text thereis (digit-char-p ch)))

(defun %simple-real-mantissa-p (text)
  "Return T if TEXT is a sign/decimal mantissa without exponent marker."
  (let* ((len (length text))
         (start (if (and (> len 0)
                         (or (char= (aref text 0) #\+)
                             (char= (aref text 0) #\-)))
                    1
                    0)))
    (when (< start len)
      (let ((dot-count 0))
        (loop for i from start below len
              for ch = (aref text i)
              always (cond
                       ((digit-char-p ch) t)
                       ((char= ch #\.)
                        (incf dot-count)
                        (<= dot-count 1))
                       (t nil)))))))

(defun %exponent-tail-in-progress-p (text)
  "Return T if TEXT is valid as an in-progress exponent tail." 
  (or (string= text "")
      (string= text "+")
      (string= text "-")
      (let* ((len (length text))
             (start (if (and (> len 0)
                             (or (char= (aref text 0) #\+)
                                 (char= (aref text 0) #\-)))
                        1
                        0)))
        (and (< start len)
             (loop for i from start below len
                   always (digit-char-p (aref text i)))))))

(defun %scientific-real-in-progress-p (text)
  "Return T if TEXT is a valid in-progress scientific notation token." 
  (let* ((marker-pos (position-if (lambda (ch)
                                    (or (char= ch #\e)
                                        (char= ch #\E)))
                                  text)))
    (and marker-pos
         (null (position-if (lambda (ch)
                              (or (char= ch #\e)
                                  (char= ch #\E)))
                            text
                            :start (1+ marker-pos)))
         (let ((mantissa (subseq text 0 marker-pos))
               (exp-tail (subseq text (1+ marker-pos))))
           (and (%simple-real-mantissa-p mantissa)
                (%has-digit-p mantissa)
                (%exponent-tail-in-progress-p exp-tail))))))

(defun real-entry-text-p (text)
  "Return T when TEXT is a valid in-progress real representation."
  (or (string= text "")
      (string= text "+")
      (string= text "-")
      (string= text ".")
      (string= text "+.")
      (string= text "-.")
      (%scientific-real-in-progress-p text)
      (ignore-errors
        (let ((*read-eval* nil))
          (let ((value (read-from-string text)))
            (typep value 'real))))))

;; entry methods moved to src/widgets/methods/entry-show-text.lisp
;; and src/widgets/methods/entry-valid-text-p.lisp

;;;; ./src/widgets/events.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Event Handling

(defparameter *toggle-groups* (make-hash-table :test #'equal)
  "Registry of grouped toggles keyed by group designator.")

(defun clear-toggle-group-registry ()
  "Remove all registered toggle groups."
  (clrhash *toggle-groups*))

(defun register-toggle-group-member (widget)
  "Register WIDGET in the toggle group registry when it belongs to a group."
  (let ((group (toggle-group widget)))
    (when group
      (pushnew widget (gethash group *toggle-groups*) :test #'eq))))

(defun select-toggle-in-group (widget)
  "Select WIDGET and clear all other toggles from the same group."
  (let ((group (toggle-group widget)))
    (setf (toggle-state widget) t)
    (update-widget-value widget t)
    (when group
      (dolist (member (gethash group *toggle-groups*))
        (unless (eq member widget)
          (when (toggle-state member)
            (setf (toggle-state member) nil)
            (update-widget-value member nil)))))))

(defmethod initialize-instance :after ((widget toggle) &key &allow-other-keys)
  (register-toggle-group-member widget))

(defun focusable-widget-p (widget)
  "Return true when WIDGET participates in keyboard focus traversal."
  (and (widget-enabled widget)
       (widget-visible widget)
       (typep widget '(or button toggle check-box edit-box list-box))))

(defun focused-widget (widgets)
  "Return the currently focused widget from WIDGETS, or NIL."
  (find-if #'widget-focused widgets))

(defun set-widget-focus (widgets target)
  "Assign keyboard focus to TARGET and clear it from the other WIDGETS."
  (loop for widget in widgets
        do (setf (widget-focused widget) (eq widget target)))
  target)

(defun move-widget-focus (widgets &key backward)
  "Move focus within WIDGETS. When BACKWARD is non-NIL, move to previous widget."
  (let* ((focusable (remove-if-not #'focusable-widget-p widgets))
         (count (length focusable)))
    (when (plusp count)
      (let* ((current (position-if #'widget-focused focusable))
             (next-index (cond
                           ((null current) (if backward (1- count) 0))
                           (backward (mod (1- current) count))
                           (t (mod (1+ current) count)))))
        (set-widget-focus widgets (nth next-index focusable))))))

(defun activate-widget (widget)
  "Activate WIDGET from keyboard focus. Returns T when handled."
  (when (and widget (widget-enabled widget) (widget-visible widget))
    (typecase widget
      (button
       (setf (button-armed-p widget) t
             (button-pressed-p widget) t)
       (unwind-protect
            (progn
              (when (button-on-click widget)
                (funcall (button-on-click widget) widget))
              t)
         (setf (button-armed-p widget) nil
               (button-pressed-p widget) nil)))
      (toggle
       (select-toggle-in-group widget)
       t)
      (check-box
       (setf (check-box-checked widget) (not (check-box-checked widget)))
       (update-widget-value widget (check-box-checked widget))
       t)
      (t nil))))

(defun handle-widget-mouse-down (widget x y)
  "Handle mouse button press. Returns T if event was consumed."
  (when (and (widget-enabled widget) (widget-visible widget))
    (let ((inside (contains-point-p widget x y)))
      (typecase widget
        (button
         (setf (button-armed-p widget) inside
               (button-pressed-p widget) inside
               (widget-focused widget) inside)
         inside)
        (toggle
         (when inside
            (setf (widget-focused widget) t)
           (select-toggle-in-group widget)
           t))
        (check-box
         (when inside
            (setf (widget-focused widget) t)
           (setf (check-box-checked widget) (not (check-box-checked widget)))
           (update-widget-value widget (check-box-checked widget))
           t))
        (edit-box
         (setf (widget-focused widget) inside)
         inside)
        (list-box
         (when inside
           (let ((rel-y (- y (widget-y widget)))
                 (item-height (list-box-item-height widget)))
             (when (plusp rel-y)
               (let ((new-index (floor rel-y item-height)))
                 (when (< new-index (length (list-box-items widget)))
                   (setf (list-box-selected-index widget) new-index)
                   (update-widget-value widget (nth new-index (list-box-items widget)))))))
           t))
        (t nil)))))

(defun handle-widget-mouse-up (widget x y)
  "Handle mouse button release. Returns T if event was consumed."
  (when (and (widget-enabled widget) (widget-visible widget))
    (typecase widget
      (button
       (let* ((inside (contains-point-p widget x y))
              (armed (button-armed-p widget))
              (activate (and armed inside)))
         (setf (button-pressed-p widget) nil
               (button-armed-p widget) nil)
         (when activate
           (when (button-on-click widget)
             (funcall (button-on-click widget) widget)))
         (or armed inside)))
      (t nil))))

(defun handle-widget-click (widget x y)
  "Compatibility helper: emulate click as mouse-down followed by mouse-up."
  (let ((down (handle-widget-mouse-down widget x y))
        (up (handle-widget-mouse-up widget x y)))
    (or down up)))

(defun handle-widget-mouse-motion (widget x y)
  "Handle mouse motion over a widget."
  (when (widget-visible widget)
    (let ((inside (contains-point-p widget x y)))
      (when (typep widget 'button)
        ;; While button is armed, pressed visuals track pointer location.
        (when (button-armed-p widget)
          (setf (button-pressed-p widget) inside))))))

;;; Edit-Box Selection and Clipboard Utilities

(defun clear-edit-box-selection (widget)
  "Clear the text selection in an edit-box WIDGET."
  (setf (edit-box-selection-start widget) nil
        (edit-box-selection-end widget) nil))

(defun get-edit-box-selected-text (widget)
  "Return the selected text from edit-box WIDGET, or empty string if no selection."
  (let ((start (edit-box-selection-start widget))
        (end (edit-box-selection-end widget)))
    (if (and start end (< start end))
        (subseq (edit-box-text widget) start end)
        "")))

(defun set-edit-box-selection (widget start end)
  "Set the text selection in edit-box WIDGET from START to END positions."
  (let ((text-len (length (edit-box-text widget))))
    (setf (edit-box-selection-start widget) (max 0 (min start text-len))
          (edit-box-selection-end widget) (max 0 (min end text-len)))))

(defun edit-box-inner-width (widget)
  "Return the available pixel width for edit-box text content."
  (max 1 (- (widget-width widget) 8)))

(defun edit-box-text-width-between (widget start end)
  "Return pixel width between START and END character positions in WIDGET."
  (if (>= start end)
      0
      (multiple-value-bind (width height)
          (widget-text-pixel-size (subseq (edit-box-text widget) start end))
        (declare (ignore height))
        width)))

(defun normalize-edit-box-scroll-offset (widget)
  "Clamp and backfill WIDGET scroll offset so visible area shows as much text as possible."
  (let* ((text (edit-box-text widget))
         (text-len (length text))
         (visible-width (edit-box-inner-width widget))
         (start (max 0 (min (edit-box-scroll-offset widget) text-len))))
    (loop while (> start 0)
          for candidate = (1- start)
          while (<= (edit-box-text-width-between widget candidate text-len) visible-width)
          do (decf start))
    (setf (edit-box-scroll-offset widget) start)))

(defun edit-box-ensure-cursor-visible (widget)
  "Adjust WIDGET scroll offset so the cursor remains visible." 
  (let* ((cursor (max 0 (min (edit-box-cursor widget) (length (edit-box-text widget)))))
         (visible-width (edit-box-inner-width widget))
         (start (max 0 (min (edit-box-scroll-offset widget) cursor))))
    (when (< cursor start)
      (setf start cursor))
    (loop while (> (edit-box-text-width-between widget start cursor) visible-width)
          do (incf start))
    (setf (edit-box-scroll-offset widget) start)
    (normalize-edit-box-scroll-offset widget)))

(defun edit-box-scroll-to-start (widget)
  "Scroll WIDGET so the beginning of the text is visible." 
  (setf (edit-box-scroll-offset widget) 0))

(defun edit-box-scroll-to-end (widget)
  "Scroll WIDGET so the end of the text is visible." 
  (let* ((text-len (length (edit-box-text widget)))
         (visible-width (edit-box-inner-width widget))
         (start text-len))
    (loop while (> start 0)
          for candidate = (1- start)
          while (<= (edit-box-text-width-between widget candidate text-len) visible-width)
          do (decf start))
    (setf (edit-box-scroll-offset widget) start)))

(defun edit-box-copy-to-clipboard (widget)
  "Copy selected text from edit-box WIDGET to system clipboard."
  (let ((selected (get-edit-box-selected-text widget)))
    (when (plusp (length selected))
      (sdl3:set-clipboard-text selected))))

(defun edit-box-paste-from-clipboard (widget)
  "Paste text from system clipboard into edit-box WIDGET at cursor position."
  (when (sdl3:has-clipboard-text)
    (handler-case
        (let* ((clipboard-text (sdl3:get-clipboard-text))
               (current-text (edit-box-text widget))
               (cursor (edit-box-cursor widget))
               (max-len (edit-box-max-length widget))
               (combined (concatenate 'string
                                     (subseq current-text 0 cursor)
                                     clipboard-text
                                     (subseq current-text cursor)))
               (truncated (if (> (length combined) max-len)
                             (subseq combined 0 max-len)
                             combined)))
          (setf (edit-box-text widget) truncated)
          (incf (edit-box-cursor widget) (length clipboard-text))
          (clear-edit-box-selection widget)
          (edit-box-ensure-cursor-visible widget)
          (update-widget-value widget truncated))
      (error (e)
        ;; Handle any clipboard access errors gracefully
        (format *error-output* "Clipboard error: ~a~%" e)))))

(defun edit-box-delete-selection (widget)
  "Delete selected text from edit-box WIDGET. Returns T if deletion occurred."
  (let ((start (edit-box-selection-start widget))
        (end (edit-box-selection-end widget)))
    (when (and start end (< start end))
      (let ((text (edit-box-text widget)))
        (setf (edit-box-text widget)
              (concatenate 'string
                           (subseq text 0 start)
                           (subseq text end)))
        (setf (edit-box-cursor widget) start)
        (clear-edit-box-selection widget)
        (edit-box-ensure-cursor-visible widget)
        (update-widget-value widget (edit-box-text widget))
        t))))

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

(defun edit-box-move-to-previous-word (widget)
  "Move cursor to the start of the previous word in edit-box WIDGET."
  (let* ((text (edit-box-text widget))
         (cursor (edit-box-cursor widget))
         (len (length text)))
    (when (> cursor 0)
      ;; Skip any spaces/non-word chars before cursor
      (loop while (> cursor 0)
            do (decf cursor)
            unless (char-is-word-char-p (aref text cursor))
            return nil)
      ;; Skip word chars to find word boundary
      (loop while (> cursor 0)
            do (decf cursor)
            while (char-is-word-char-p (aref text cursor)))
      ;; Move forward one if we went back too far
      (when (and (< cursor len) (not (char-is-word-char-p (aref text cursor))))
        (incf cursor))
      (setf (edit-box-cursor widget) cursor)
      (clear-edit-box-selection widget)
      (edit-box-ensure-cursor-visible widget))))

(defun edit-box-move-to-next-word (widget)
  "Move cursor to the start of the next word in edit-box WIDGET."
  (let* ((text (edit-box-text widget))
         (cursor (edit-box-cursor widget))
         (len (length text)))
    (when (< cursor len)
      ;; Skip any current word chars
      (loop while (< cursor len)
            do (incf cursor)
            while (and (< cursor len) (char-is-word-char-p (aref text (1- cursor)))))
      ;; Skip spaces/non-word chars
      (loop while (< cursor len)
            while (not (char-is-word-char-p (aref text cursor)))
            do (incf cursor))
      (setf (edit-box-cursor widget) cursor)
      (clear-edit-box-selection widget)
      (edit-box-ensure-cursor-visible widget))))

(defun handle-widget-key-press (widget key char)
  "Handle keyboard input for a widget. Returns T if key was handled."
  (when (and (widget-enabled widget) (widget-visible widget))
    (let ((handled
            (typecase widget
              (button
               (when (eq key :space)
                 (activate-widget widget)))
              (toggle
               (when (eq key :space)
                 (activate-widget widget)))
              (check-box
               (when (eq key :space)
                 (activate-widget widget)))
              (edit-box
               (cond
                 ((eq key :backspace)
                  ;; If there's a selection, delete it; otherwise delete character before cursor
                  (unless (edit-box-delete-selection widget)
                    (when (> (edit-box-cursor widget) 0)
                      (let ((text (edit-box-text widget)))
                        (setf (edit-box-text widget)
                              (concatenate 'string
                                           (subseq text 0 (1- (edit-box-cursor widget)))
                                           (subseq text (edit-box-cursor widget))))
                        (decf (edit-box-cursor widget))
                          (edit-box-ensure-cursor-visible widget)
                        (update-widget-value widget (edit-box-text widget)))))
                  t)
                 ((eq key :delete)
                  ;; If there's a selection, delete it; otherwise delete character at cursor
                  (unless (edit-box-delete-selection widget)
                    (when (< (edit-box-cursor widget) (length (edit-box-text widget)))
                      (let ((text (edit-box-text widget)))
                        (setf (edit-box-text widget)
                              (concatenate 'string
                                           (subseq text 0 (edit-box-cursor widget))
                                           (subseq text (1+ (edit-box-cursor widget)))))
                        (edit-box-ensure-cursor-visible widget)
                        (update-widget-value widget (edit-box-text widget)))))
                  t)
                 ((eq key :left)
                  (when (> (edit-box-cursor widget) 0)
                    (decf (edit-box-cursor widget)))
                  (clear-edit-box-selection widget)
                  (edit-box-ensure-cursor-visible widget)
                  t)
                 ((eq key :right)
                  (when (< (edit-box-cursor widget) (length (edit-box-text widget)))
                    (incf (edit-box-cursor widget)))
                  (clear-edit-box-selection widget)
                  (edit-box-ensure-cursor-visible widget)
                  t)
                 ((eq key :home)
                  (setf (edit-box-cursor widget) 0)
                  (clear-edit-box-selection widget)
                  (edit-box-scroll-to-start widget)
                  t)
                 ((eq key :end)
                  (setf (edit-box-cursor widget) (length (edit-box-text widget)))
                  (clear-edit-box-selection widget)
                  (edit-box-scroll-to-end widget)
                  t)
                 ((member key '(:pageup :pagedown))
                  ;; Edit boxes do not use page-wise navigation; consume the key.
                  t)
                 ((characterp char)
                  ;; Delete selection if any, then insert character
                  (edit-box-delete-selection widget)
                  (when (< (length (edit-box-text widget)) (edit-box-max-length widget))
                    (let ((text (edit-box-text widget)))
                      (setf (edit-box-text widget)
                            (concatenate 'string
                                         (subseq text 0 (edit-box-cursor widget))
                                         (string char)
                                         (subseq text (edit-box-cursor widget))))
                      (incf (edit-box-cursor widget))
                      (edit-box-ensure-cursor-visible widget)
                      (update-widget-value widget (edit-box-text widget))))
                  t)
                 (t nil)))
              (list-box
               (cond
                 ((eq key :up)
                  (when (> (list-box-selected-index widget) 0)
                    (decf (list-box-selected-index widget))
                    (update-widget-value widget (nth (list-box-selected-index widget)
                                                     (list-box-items widget))))
                  t)
                 ((eq key :down)
                  (when (< (1+ (list-box-selected-index widget))
                           (length (list-box-items widget)))
                    (incf (list-box-selected-index widget))
                    (update-widget-value widget (nth (list-box-selected-index widget)
                                                     (list-box-items widget))))
                  t)
                 (t nil)))
              (t nil))))
      handled)))

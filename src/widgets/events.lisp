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

(defun focused-edit-box (widgets)
  "Return the currently focused edit-box from WIDGETS, or NIL."
  (find-if (lambda (widget)
             (and (typep widget 'edit-box)
                  (widget-focused widget)))
           widgets))

(defun tab-navigation-backward-p (mods)
  "Return true when MODS indicates backward Tab navigation." 
  (typecase mods
    (list (or (member :alt mods) (member :lalt mods) (member :ralt mods)
              (member :shift mods) (member :lshift mods) (member :rshift mods)))
    (symbol (member mods '(:alt :lalt :ralt :shift :lshift :rshift)))
    (integer (not (zerop (logand mods #x0303))))
    (t nil)))

(defun key-modifier-active-p (mods modifier)
  "Return true when MODS contains MODIFIER such as :ctrl, :shift, or :alt." 
  (flet ((member-of (items)
           (some (lambda (item) (member item items))
                 (list mods))))
    (ecase modifier
      (:ctrl
       (typecase mods
         (list (or (member :ctrl mods) (member :lctrl mods) (member :rctrl mods)))
         (symbol (member mods '(:ctrl :lctrl :rctrl)))
         (integer (not (zerop (logand mods #x00c0))))
         (t nil)))
      (:shift
       (typecase mods
         (list (or (member :shift mods) (member :lshift mods) (member :rshift mods)))
         (symbol (member mods '(:shift :lshift :rshift)))
         (integer (not (zerop (logand mods #x0003))))
         (t nil)))
      (:alt
       (typecase mods
         (list (or (member :alt mods) (member :lalt mods) (member :ralt mods)))
         (symbol (member mods '(:alt :lalt :ralt)))
         (integer (not (zerop (logand mods #x0300))))
         (t nil))))))

(defun start-widget-text-input (window)
  "Enable SDL text input for WINDOW when WINDOW is non-NIL." 
  (when window
    (sdl3:start-text-input window)))

(defun stop-widget-text-input (window)
  "Disable SDL text input for WINDOW when WINDOW is non-NIL." 
  (when window
    (sdl3:stop-text-input window)))

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

(defgeneric activate-widget (widget)
  (:documentation "Activate WIDGET from keyboard focus. Returns T when handled."))

(defmethod activate-widget :around ((widget widget))
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod activate-widget ((widget widget))
  nil)

(defmethod activate-widget ((widget button))
  (setf (button-armed-p widget) t
        (button-pressed-p widget) t)
  (unwind-protect
       (progn
         (when (button-on-click widget)
           (funcall (button-on-click widget) widget))
         t)
    (setf (button-armed-p widget) nil
          (button-pressed-p widget) nil)))

(defmethod activate-widget ((widget toggle))
  (select-toggle-in-group widget)
  t)

(defmethod activate-widget ((widget check-box))
  (setf (check-box-checked widget) (not (check-box-checked widget)))
  (update-widget-value widget (check-box-checked widget))
  t)

(defgeneric handle-widget-mouse-down (widget x y)
  (:documentation "Handle mouse button press. Returns T if event was consumed."))

(defmethod handle-widget-mouse-down :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-mouse-down ((widget widget) x y)
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-down ((widget button) x y)
  (let ((inside (contains-point-p widget x y)))
    (setf (button-armed-p widget) inside
          (button-pressed-p widget) inside
          (widget-focused widget) inside)
    inside))

(defmethod handle-widget-mouse-down ((widget toggle) x y)
  (declare (ignore y))
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      (select-toggle-in-group widget)
      t)))

(defmethod handle-widget-mouse-down ((widget check-box) x y)
  (declare (ignore y))
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (setf (widget-focused widget) t)
      (setf (check-box-checked widget) (not (check-box-checked widget)))
      (update-widget-value widget (check-box-checked widget))
      t)))

(defmethod handle-widget-mouse-down ((widget edit-box) x y)
  (declare (ignore y))
  (let ((inside (contains-point-p widget x y)))
    (setf (widget-focused widget) inside)
    (when inside
      (setf (edit-box-cursor widget) (edit-box-position-from-pixel widget x))
      (clear-edit-box-selection widget)
      (edit-box-ensure-cursor-visible widget))
    inside))

(defmethod handle-widget-mouse-down ((widget list-box) x y)
  (let ((inside (contains-point-p widget x y)))
    (when inside
      (let ((rel-y (- y (widget-y widget)))
            (item-height (list-box-item-height widget)))
        (when (plusp rel-y)
          (let ((new-index (floor rel-y item-height)))
            (when (< new-index (length (list-box-items widget)))
              (setf (list-box-selected-index widget) new-index)
              (update-widget-value widget
                                   (nth new-index (list-box-items widget)))))))
      t)))

(defgeneric handle-widget-mouse-up (widget x y)
  (:documentation "Handle mouse button release. Returns T if event was consumed."))

(defmethod handle-widget-mouse-up :around ((widget widget) x y)
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-mouse-up ((widget widget) x y)
  (declare (ignore x y))
  nil)

(defmethod handle-widget-mouse-up ((widget button) x y)
  (let* ((inside (contains-point-p widget x y))
         (armed (button-armed-p widget))
         (activate (and armed inside)))
    (setf (button-pressed-p widget) nil
          (button-armed-p widget) nil)
    (when activate
      (when (button-on-click widget)
        (funcall (button-on-click widget) widget)))
    (or armed inside)))

(defun dispatch-widget-mouse-down (widgets x y)
  "Dispatch mouse-down to WIDGETS and focus the widget that consumes it."
  (loop for widget in widgets
        when (handle-widget-mouse-down widget x y)
          do (set-widget-focus widgets widget)
             (return widget)
        finally (return nil)))

(defun dispatch-widget-mouse-up (widgets x y)
  "Dispatch mouse-up to WIDGETS and return the widget that consumes it."
  (loop for widget in widgets
        when (handle-widget-mouse-up widget x y)
          return widget
        finally (return nil)))

(defun dispatch-widget-mouse-motion (widgets x y)
  "Dispatch mouse-motion to each widget in WIDGETS." 
  (loop for widget in widgets
        do (handle-widget-mouse-motion widget x y))
  nil)

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

(defun edit-box-selection-anchor (widget)
  "Return the fixed side of the current selection for WIDGET."
  (let ((start (edit-box-selection-start widget))
        (end (edit-box-selection-end widget))
        (cursor (edit-box-cursor widget)))
    (cond
      ((and start end (< start end))
       (if (= cursor start) end start))
      (t cursor))))

(defun edit-box-select-from-anchor (widget anchor)
  "Update selection in WIDGET between ANCHOR and current cursor."
  (let ((cursor (edit-box-cursor widget)))
    (if (= anchor cursor)
        (clear-edit-box-selection widget)
        (set-edit-box-selection widget (min anchor cursor) (max anchor cursor)))))

(defun edit-box-select-previous-char (widget)
  "Extend selection in WIDGET one character to the left."
  (let ((anchor (edit-box-selection-anchor widget)))
    (when (> (edit-box-cursor widget) 0)
      (decf (edit-box-cursor widget))
      (edit-box-ensure-cursor-visible widget)
      (edit-box-select-from-anchor widget anchor)))
  t)

(defun edit-box-select-next-char (widget)
  "Extend selection in WIDGET one character to the right."
  (let ((anchor (edit-box-selection-anchor widget))
        (text-len (length (edit-box-text widget))))
    (when (< (edit-box-cursor widget) text-len)
      (incf (edit-box-cursor widget))
      (edit-box-ensure-cursor-visible widget)
      (edit-box-select-from-anchor widget anchor)))
  t)

(defun edit-box-select-previous-word (widget)
  "Extend selection in WIDGET to the previous word boundary."
  (let ((anchor (edit-box-selection-anchor widget)))
    (edit-box-move-to-previous-word widget)
    (edit-box-select-from-anchor widget anchor))
  t)

(defun edit-box-select-next-word (widget)
  "Extend selection in WIDGET to the next word boundary."
  (let ((anchor (edit-box-selection-anchor widget)))
    (edit-box-move-to-next-word widget)
    (edit-box-select-from-anchor widget anchor))
  t)

(defun edit-box-select-to-start (widget)
  "Extend selection in WIDGET to the start of the text."
  (let ((anchor (edit-box-selection-anchor widget)))
    (setf (edit-box-cursor widget) 0)
    (edit-box-scroll-to-start widget)
    (edit-box-select-from-anchor widget anchor))
  t)

(defun edit-box-select-to-end (widget)
  "Extend selection in WIDGET to the end of the text."
  (let ((anchor (edit-box-selection-anchor widget)))
    (setf (edit-box-cursor widget) (length (edit-box-text widget)))
    (edit-box-scroll-to-end widget)
    (edit-box-select-from-anchor widget anchor))
  t)

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

(defun edit-box-position-from-pixel (widget x)
  "Return character position in WIDGET nearest to pixel coordinate X." 
  (let* ((text-len (length (edit-box-text widget)))
         (visible-start (max 0 (min (edit-box-scroll-offset widget) text-len)))
         (visible-width (edit-box-inner-width widget))
         (relative-x (max 0 (min (- x (widget-x widget) 4) visible-width)))
         (previous-width 0))
    (loop for position from visible-start below text-len
          for next-width = (edit-box-text-width-between widget visible-start (1+ position))
          for midpoint = (+ previous-width (/ (- next-width previous-width) 2))
          do (when (<= relative-x midpoint)
               (return position))
             (setf previous-width next-width)
          finally (return text-len))))

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

(defgeneric handle-widget-key-press (widget key char)
  (:documentation "Handle keyboard input for a widget. Returns T if key was handled."))

(defmethod handle-widget-key-press :around ((widget widget) key char)
  (declare (ignore key char))
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-key-press ((widget widget) key char)
  (declare (ignore key char))
  nil)

(defmethod handle-widget-key-press ((widget button) key char)
  (declare (ignore char))
  (when (eq key :space)
    (activate-widget widget)))

(defmethod handle-widget-key-press ((widget toggle) key char)
  (declare (ignore char))
  (when (eq key :space)
    (activate-widget widget)))

(defmethod handle-widget-key-press ((widget check-box) key char)
  (declare (ignore char))
  (when (eq key :space)
    (activate-widget widget)))

(defmethod handle-widget-key-press ((widget edit-box) key char)
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

(defmethod handle-widget-key-press ((widget list-box) key char)
  (declare (ignore char))
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

(defgeneric handle-widget-key-event (widget key char &key ctrl shift alt)
  (:documentation "Handle keyboard input for WIDGET including modifier-aware bindings."))

(defmethod handle-widget-key-event :around ((widget widget) key char &key ctrl shift alt)
  (declare (ignore key char ctrl shift alt))
  (when (and (widget-enabled widget) (widget-visible widget))
    (call-next-method)))

(defmethod handle-widget-key-event ((widget widget) key char &key ctrl shift alt)
  (declare (ignore ctrl shift alt))
  (handle-widget-key-press widget key char))

(defmethod handle-widget-key-event ((widget edit-box) key char &key ctrl shift alt)
  (declare (ignore alt))
  (cond
    ((and ctrl (eq key :a))
     (set-edit-box-selection widget 0 (length (edit-box-text widget)))
     t)
    ((and ctrl (eq key :c))
     (edit-box-copy-to-clipboard widget)
     t)
    ((and ctrl (eq key :v))
     (edit-box-paste-from-clipboard widget)
     t)
    ((and ctrl (eq key :x))
     (edit-box-copy-to-clipboard widget)
     (edit-box-delete-selection widget)
     t)
    ((and ctrl shift (eq key :left))
     (edit-box-select-previous-word widget))
    ((and ctrl shift (eq key :right))
     (edit-box-select-next-word widget))
    ((and ctrl shift (eq key :home))
     (edit-box-select-to-start widget))
    ((and ctrl shift (eq key :end))
     (edit-box-select-to-end widget))
    ((and ctrl (eq key :left))
     (edit-box-move-to-previous-word widget)
     t)
    ((and ctrl (eq key :right))
     (edit-box-move-to-next-word widget)
     t)
    ((and shift (eq key :left))
     (edit-box-select-previous-char widget))
    ((and shift (eq key :right))
     (edit-box-select-next-char widget))
    (t
     (handle-widget-key-press widget key char))))

(defun dispatch-focused-widget-key-event (widgets key char &key ctrl shift alt)
  "Send KEY/CHAR event to the currently focused widget from WIDGETS." 
  (let ((widget (focused-widget widgets)))
    (when widget
      (handle-widget-key-event widget key char
                               :ctrl ctrl
                               :shift shift
                               :alt alt))))

(defun dispatch-focused-text-input (widgets text)
  "Insert TEXT into the currently focused edit-box from WIDGETS." 
  (let ((widget (focused-edit-box widgets)))
    (when widget
      (loop for char across text
            do (handle-widget-key-event widget nil char)))))

(defun dispatch-widget-keyboard-event (widgets key &key mods on-escape on-return)
  "Handle common demo keyboard dispatch for WIDGETS and return app status keyword." 
  (cond
    ((eq key :escape)
     (if on-escape
         (funcall on-escape)
         :continue))
    ((eq key :tab)
     (move-widget-focus widgets :backward (tab-navigation-backward-p mods))
     :continue)
    ((eq key :return)
     (if on-return
         (funcall on-return)
         :continue))
    ((eq key :space)
     (dispatch-focused-widget-key-event widgets :space nil)
     :continue)
    (t
     (dispatch-focused-widget-key-event
      widgets key nil
      :ctrl (key-modifier-active-p mods :ctrl)
      :shift (key-modifier-active-p mods :shift)
      :alt (key-modifier-active-p mods :alt))
     :continue)))

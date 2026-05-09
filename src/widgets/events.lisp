;;;; ./src/widgets/events.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Event Handling

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
           (setf (toggle-state widget) (not (toggle-state widget)))
           (update-widget-value widget (toggle-state widget))
           t))
        (check-box
         (when inside
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
          (setf (button-pressed-p widget) inside)))
      (unless (eql (widget-focused widget) inside)
        (setf (widget-focused widget) inside)))))

(defun handle-widget-key-press (widget key char)
  "Handle keyboard input for a widget. Returns T if key was handled."
  (when (and (widget-enabled widget) (widget-visible widget))
    (typecase widget
      (edit-box
       (cond
         ((eq key :backspace)
          (when (> (edit-box-cursor widget) 0)
            (let ((text (edit-box-text widget)))
              (setf (edit-box-text widget)
                    (concatenate 'string
                               (subseq text 0 (1- (edit-box-cursor widget)))
                               (subseq text (edit-box-cursor widget))))
              (decf (edit-box-cursor widget))
              (update-widget-value widget (edit-box-text widget))))
          t)
         ((eq key :delete)
          (when (< (edit-box-cursor widget) (length (edit-box-text widget)))
            (let ((text (edit-box-text widget)))
              (setf (edit-box-text widget)
                    (concatenate 'string
                               (subseq text 0 (edit-box-cursor widget))
                               (subseq text (1+ (edit-box-cursor widget)))))
              (update-widget-value widget (edit-box-text widget))))
          t)
         ((eq key :left)
          (when (> (edit-box-cursor widget) 0)
            (decf (edit-box-cursor widget)))
          t)
         ((eq key :right)
          (when (< (edit-box-cursor widget) (length (edit-box-text widget)))
            (incf (edit-box-cursor widget)))
          t)
         ((eq key :home)
          (setf (edit-box-cursor widget) 0)
          t)
         ((eq key :end)
          (setf (edit-box-cursor widget) (length (edit-box-text widget)))
          t)
         ((member key '(:pageup :pagedown))
          ;; Edit boxes do not use page-wise navigation; consume the key.
          t)
         ((characterp char)
          (when (< (length (edit-box-text widget)) (edit-box-max-length widget))
            (let ((text (edit-box-text widget)))
              (setf (edit-box-text widget)
                    (concatenate 'string
                               (subseq text 0 (edit-box-cursor widget))
                               (string char)
                               (subseq text (edit-box-cursor widget))))
              (incf (edit-box-cursor widget))
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
          (when (< (1+ (list-box-selected-index widget)) (length (list-box-items widget)))
            (incf (list-box-selected-index widget))
            (update-widget-value widget (nth (list-box-selected-index widget)
                                             (list-box-items widget))))
          t)
         (t nil)))
      (t nil))))

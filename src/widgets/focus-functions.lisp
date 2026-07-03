;;;; ./src/widgets/focus-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Focus and modifier helpers

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
       (t nil)))))

(defun start-widget-text-input (window)
  "Enable SDL text input for WINDOW when WINDOW is non-NIL."
  (when window
    (sdl3:start-text-input window)))

(defun stop-widget-text-input (window)
  "Disable SDL text input for WINDOW when WINDOW is non-NIL."
  (when window
    (sdl3:stop-text-input window)))

(defun move-widget-focus (widgets &key backward)
  "Move focus within WIDGETS. When BACKWARD is non-NIL, move to previous widget."
  (let* ((focusable (remove-if-not #'focusable-p widgets))
         (count (length focusable)))
    (when (plusp count)
      (let* ((current (position-if #'focused focusable))
             (next-index (cond
                           ((null current) (if backward (1- count) 0))
                           (backward (mod (1- current) count))
                           (t (mod (1+ current) count)))))
        (set-widget-focus widgets (nth next-index focusable))))))

;;;; ./src/widgets/keyboard-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Keyboard dispatch helpers

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
  (let ((focused (focused-widget widgets)))
    (cond
    ((and (typep focused 'combo-box)
          (combo-box-expanded-p focused)
          (member key '(:escape :return)))
     (handle-widget-key-event focused key nil)
     :continue)
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
    :continue))))
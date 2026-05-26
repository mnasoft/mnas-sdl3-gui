;;;; ./src/widgets/methods/handle-widget-key-event.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod handle-widget-key-event ((widgets cons) key char &key mods ctrl shift alt on-escape on-return)
  "Top-level keyboard dispatch for a WIDGETS list. Returns an app status keyword.
This method implements demo-level behavior (escape/tab/return/space) and
forwards other keys to the focused widget." 
  (declare (ignore char ctrl shift alt))
  (let ((focused (focused-widget widgets)))
    (cond
      ((and (typep focused 'combo-box)
            (combo-box-expanded-p focused)
            (member key '(:escape :return)))
       (handle-widget-key-event focused key nil
                                :mods mods :ctrl (key-modifier-active-p mods :ctrl)
                                :shift (key-modifier-active-p mods :shift)
                                :alt (key-modifier-active-p mods :alt))
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

(defmethod handle-widget-key-event :around ((widget widget) key char &key mods ctrl shift alt on-escape on-return)
  (declare (ignore key char mods ctrl shift alt on-escape on-return))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-widget-key-event ((widget widget) key char &key mods ctrl shift alt on-escape on-return)
  (declare (ignore mods ctrl shift alt on-escape on-return))
  (handle-widget-key-press widget key char))

(defmethod handle-widget-key-event ((widget widget-container) key char &key mods ctrl shift alt on-escape on-return)
  (declare (ignore mods ctrl shift alt on-escape on-return))
  (let ((focused-child (find-if #'widget-focused (children widget))))
    (when focused-child
      (handle-widget-key-event focused-child key char
                               :mods mods :ctrl ctrl :shift shift :alt alt
                               :on-escape on-escape :on-return on-return))))

(defmethod handle-widget-key-event ((widget entry) key char &key mods ctrl shift alt on-escape on-return)
  (declare (ignore mods alt on-escape on-return))
  (cond
    ((and ctrl (eq key :a))
     (set-entry-selection widget 0 (length (entry-text widget)))
     t)
    ((and ctrl (eq key :c))
     (entry-copy-to-clipboard widget)
     t)
    ((and ctrl (eq key :v))
     (entry-paste-from-clipboard widget)
     t)
    ((and ctrl (eq key :x))
     (entry-copy-to-clipboard widget)
     (entry-delete-selection widget)
     t)
    ((and ctrl shift (eq key :left))
     (entry-select-previous-word widget))
    ((and ctrl shift (eq key :right))
     (entry-select-next-word widget))
    ((and ctrl shift (eq key :home))
     (entry-select-to-start widget))
    ((and ctrl shift (eq key :end))
     (entry-select-to-end widget))
    ((and ctrl (eq key :left))
     (entry-move-to-previous-word widget)
     t)
    ((and ctrl (eq key :right))
     (entry-move-to-next-word widget)
     t)
    ((and shift (eq key :left))
     (entry-select-previous-char widget))
    ((and shift (eq key :right))
     (entry-select-next-char widget))
    (t
     (handle-widget-key-press widget key char))))

(defmethod handle-widget-key-event ((widget password-entry) key char &key mods ctrl shift alt on-escape on-return)
  (declare (ignore mods on-escape on-return))
  (cond
    ((and ctrl (member key '(:c :x)))
     t)
    (t
     (call-next-method))))
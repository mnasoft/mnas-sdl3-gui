;;;; ./demos/dialog/entry/entry-01/entry-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-01)

(defun key->modifier (key)
  "Return modifier keyword for KEY, or NIL when KEY is not a modifier key."
  (case key
    ((:lctrl :rctrl) :ctrl)
    ((:lshift :rshift) :shift)
    ((:lalt :ralt) :alt)
    (t nil)))

(defun update-modifier-state (ev)
  "Update tracked modifier state from keyboard event EV and return active modifiers."
  (let ((modifier (key->modifier (slot-value ev 'sdl3:%key))))
    (when modifier
      (if (slot-value ev 'sdl3:%down)
          (pushnew modifier *active-modifiers*)
          (setf *active-modifiers*
                (remove modifier *active-modifiers*)))))
  *active-modifiers*)

(defun create-toolbar (window)
  "Create toolbar for entry-01 command presenter."
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :layout :horizontal
           :height 32
           :window window)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :entry-01/ok
            :label "OK"
            :width 64
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :entry-01/cancel
            :label "Cancel"
            :width 90
            :window window)))
    toolbar))

(defun sync-command-state ()
  "Sync dynamic toolbar state for entry-01 demo."
  (declare (ignore t))
  nil)

(defun key-modifiers (ev)
  "Return a list of active keyboard modifiers for EV."
  (declare (ignore ev))
  (copy-list *active-modifiers*))

(defun log-key-event (ev &key char action)
  "Print debug information for keyboard event EV and current entry state."
  (let ((key (slot-value ev 'sdl3:%key))
        (mods (key-modifiers ev))
        (selected (and *input*
                       (mnas-sdl3-gui/widgets:get-<entry>-selected-text *input*))))
    (format t "[DEBUG] action=~A key=~A mods=~S char=~A | ~A | selected='~A'~%"
            action key mods char *input* (or selected ""))))

(defun widgets ()
  "Return focus-traversable widgets in entry dialog."
  (list *input* *ok-button*))


(defun create-widgets (window)
  "Create entry widget and OK button widgets for dialog demo."
  (let* ((text "Привет, мир!")
         (first-space (or (position #\Space text) (length text))))
    (setf *input*
          (make-instance 'mnas-sdl3-gui/widgets:<entry>
                         :x 40 :y 90 :width 320 :height 36
                         :text text
                         :cursor first-space
                         :selection-start 0
                         :selection-end first-space
                         :max-length 128
                         :focused t)))
  (setf *ok-button*
        (make-instance 'mnas-sdl3-gui/widgets:<button>
                       :window window
                       :x 150
                       :y 150
                       :width 100
                       :height 34
                       :text "ОК"
                       :on-click (lambda (widget)
                                   (declare (ignore widget))
                                   (command :entry-01/ok))))
  (values))




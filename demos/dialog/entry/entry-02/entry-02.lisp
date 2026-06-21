;;;; ./demos/dialog/entry/entry-02/entry-02.lisp

(in-package :mnas-sdl3-gui/demos/dialog/entry-02)

(defun create-toolbar (window)
  "Create toolbar for entry-02 demo."
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :layout :horizontal
           :height +toolbar-height+
           :window window)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :entry-02/run
            :label "Run"
            :width 72
            :window window)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :command-id :entry-02/quit
            :label "Quit"
            :width 64
            :window window)))
    toolbar))

(defun sync-command-state ()
  "Sync command state for entry-02 toolbar." 
  (let* ((run-cmd (mnas-sdl3-gui/commands:find-command :entry-02/run))
         (text (and *command*
                    (mnas-sdl3-gui/widgets:<entry>-text *command*))))
    (when run-cmd
      (mnas-sdl3-gui/commands:set-command-enabled run-cmd
                                                  (> (length (string-trim '(#\Space #\Tab #\Newline #\Return) (or text ""))) 0)))))

(defun key->modifier (key)
  "Return modifier keyword for KEY, or NIL when KEY is not a modifier key."
  (case key
    ((:lctrl :rctrl) :ctrl)
    ((:lshift :rshift) :shift)
    ((:lalt :ralt) :alt)
    (t nil)))

(defun update-modifier-state (ev)
  "Update tracked modifier state from keyboard event EV."
  (let ((modifier (key->modifier (slot-value ev 'sdl3:%key))))
    (when modifier
      (if (slot-value ev 'sdl3:%down)
          (pushnew modifier *active-modifiers*)
          (setf *active-modifiers*
                (remove modifier *active-modifiers*)))))
  *active-modifiers*)

(defun key-modifiers (ev)
  "Return a list of active keyboard modifiers for EV."
  (declare (ignore ev))
  (copy-list *active-modifiers*))

(defun widgets ()
  "Return focus-traversable widgets in entry dialog."
  (list *name*
        *password*
        *integer*
        *real*
        *path*
        *command*))

(defun on-change (widget new-text)
  "Update status when ENTRY text changes."
  (declare (ignore new-text))
  (setf *status*
        (format nil "Updated ~a: ~a"
                (if (typep widget 'mnas-sdl3-gui/widgets:<entry>)
                    (cond ((eq widget *name*) "Name")
                          ((eq widget *password*) "Password")
                          ((eq widget *integer*) "Integer")
                          ((eq widget *real*) "Real")
                          ((eq widget *path*) "Path")
                          ((eq widget *command*) "Command")
                          (t "Entry"))
                    "Widget")
                (mnas-sdl3-gui/widgets:<entry>-text widget))))

(defun create-widgets (window)
  "Create several entry widgets demonstrating common input scenarios."
  (let* ((title
           (make-instance
            'mnas-sdl3-gui/widgets:<label>
            :x 40 :y 20 :width 420 :height 28
            :text "Entry Widget Scenarios"))
         (hint
           (make-instance
            'mnas-sdl3-gui/widgets:<label>
            :x 40 :y 48 :width 420 :height 22
            :text "Name, password, integer, real, path, command, and filters."))
         (name
           (make-instance
            'mnas-sdl3-gui/widgets:<entry>
            :x 40 :y 90 :width 320 :height 32
            :text "Alice"
            :max-length 64
            :on-change #'on-change
            :window window))
         (password
           (make-instance
            'mnas-sdl3-gui/widgets:<password-entry>
            :x 40 :y 140 :width 320 :height 32
            :text ""
            :cursor 0
            :max-length 32
            :on-change #'on-change
            :window window))
         (integer
           (make-instance
            'mnas-sdl3-gui/widgets:<integer-entry>
            :x 40 :y 190 :width 320 :height 32
            :text "123"
            :max-length 12
            :on-change #'on-change
            :window window))
         (real
           (make-instance
            'mnas-sdl3-gui/widgets:<real-entry>
            :x 40 :y 240 :width 320 :height 32
            :text "3.14"
            :max-length 20
            :on-change #'on-change
            :window window))
         (path
           (make-instance
            'mnas-sdl3-gui/widgets:<entry>
            :x 40 :y 290 :width 280 :height 32
            :text "/tmp/output"
            :max-length 120
            :on-change #'on-change
            :window window))
         (browse
           (make-instance 'mnas-sdl3-gui/widgets:<button>
                          :x 330 :y 290 :width 100 :height 32
                          :text "Browse..."
                          :on-click (lambda (widget)
                                      (declare (ignore widget))
                                      (setf *status*
                                            (format nil "Browse: ~A"
                                                    (mnas-sdl3-gui/widgets:<entry>-text *path*))))
                          :window window))
         (command
           (make-instance
            'mnas-sdl3-gui/widgets:<entry>
            :x 40 :y 340 :width 320 :height 32
            :text "ls -la"
            :max-length 128
            :on-change #'on-change
            :window window))
         (show-values (make-instance 'mnas-sdl3-gui/widgets:<button>
                                     :window window
                                     :x 40
                                     :y 390
                                     :width 150
                                     :height 32
                                     :text "Show values"
                                     :on-click (lambda (widget)
                                                 (declare (ignore widget))
                                                 (format t "[entry-02] Name=~A Password=~A Integer=~A Real=~A Path=~A Cmd=~A~%"
                                                         (mnas-sdl3-gui/widgets:<entry>-text *name*)
                                                         (mnas-sdl3-gui/widgets:<entry>-text *password*)
                                                         (mnas-sdl3-gui/widgets:<entry>-text *integer*)
                                                         (mnas-sdl3-gui/widgets:<entry>-text *real*)
                                                         (mnas-sdl3-gui/widgets:<entry>-text *path*)
                                                         (mnas-sdl3-gui/widgets:<entry>-text *command*))
                                                 (setf *status*
                                                       (format nil "Name=~A Password=~A Integer=~A Real=~A Path=~A Cmd=~A"
                                                               (mnas-sdl3-gui/widgets:<entry>-text *name*)
                                                               (mnas-sdl3-gui/widgets:<entry>-text *password*)
                                                               (mnas-sdl3-gui/widgets:<entry>-text *integer*)
                                                               (mnas-sdl3-gui/widgets:<entry>-text *real*)
                                                               (mnas-sdl3-gui/widgets:<entry>-text *path*)
                                                               (mnas-sdl3-gui/widgets:<entry>-text *command*))))))
         (status-label (make-instance 'mnas-sdl3-gui/widgets:<label>
                                      :x 40 :y 440 :width 420 :height 22
                                      :text *status*)))
    (setf *name* name
          *password* password
          *integer* integer
          *real* real
          *path* path
          *command* command
          *widgets*
          (list title hint name password integer real path browse command show-values status-label))))



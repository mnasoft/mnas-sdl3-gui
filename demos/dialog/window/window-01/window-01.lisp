;;;; ./demos/dialog/window/window-01/window-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/window-01)


(defun flags-as-list ()
  "Return demo flags as a list for printing and passing to SDL."
  (if (listp *demo-flags*)
      *demo-flags*
      (list *demo-flags*)))

(defun run-demo (title flags)
  "Run window demo with custom title and SDL window flags."
  (setf *demo-title* title
        *demo-flags* flags
        *window* nil
        *renderer* nil
        *window-id* 0
        *layer-manager* nil
        *toolbar* nil
        *modal-1-open* nil
        *modal-2-open* nil
        *show-grid* nil
        *open* t
        *width* +default-width+
        *height* +default-height+)
  (sdl3:enter-app-main-callbacks
   'callback-init
   'callback-iterate
   'callback-event
   'callback-quit)
  :done)

(defmacro define-flag-demo (name flag)
  "Define a small wrapper demo for a single window flag."
  `(defun ,name ()
     ,(format nil "Run a window demo using the ~S flag." flag)
     (run-demo
      ,(format nil "Window Flag Demo: ~S" flag)
      ,flag)))

(defun update-window-size ()
  "Query current window client size and update demo state."
  (when *window*
    (multiple-value-bind (ok width height)
        (sdl3:get-window-size *window*)
      (when ok
        (setf *width* width
              *height* height)))))

(defun make-toolbar (window)
  "Create toolbar for runtime modal/focus demo commands."
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :window window
           :layout :horizontal :height 40)))
    (setf
     (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :window-01/open-modal-1
            :label "Modal-1" :width 72)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :window-01/open-modal-2
            :label "Modal-2" :width 72)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :window-01/close-top-modal
            :label "Close Top" :width 84)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :window-01/reset-size
            :label "Reset"
            :width 62)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :window-01/toggle-grid
            :label "Grid"
            :width 56
            :type :toggle)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :window-01/quit
            :label "Quit"
            :width 52)))
    toolbar))

(defun sync-command-state ()
  "Sync dynamic visible/checked command state for full-state toolbar."
  (let ((reset-cmd (mnas-sdl3-gui/commands:find-command :window-01/reset-size))
        (grid-cmd (mnas-sdl3-gui/commands:find-command :window-01/toggle-grid)))
    (when reset-cmd
      (mnas-sdl3-gui/commands:set-command-visible reset-cmd
                                                  (or (/= *width* +default-width+)
                                                      (/= *height* +default-height+))))
    (when grid-cmd
      (mnas-sdl3-gui/commands:set-command-checked grid-cmd *show-grid*))))

(defun open-modal-1 ()
  "Open first modal layer for runtime focus-trap demo."
  (when (and *layer-manager*
             (not *modal-1-open*))
    (mnas-sdl3-gui/window-manager:register-window
     *layer-manager*
     +modal-1-id+
     :modal
     :parent-id *window-id*
     :open-p t)
    (setf *modal-1-open* t)
    (mnas-sdl3-gui/window-manager:set-focused-window
     *layer-manager*
     +modal-1-id+)
    t))

(defun open-modal-2 ()
  "Open second nested modal layer for runtime focus-trap demo."
  (when (and *layer-manager*
             *modal-1-open*
             (not *modal-2-open*))
    (mnas-sdl3-gui/window-manager:register-window
     *layer-manager*
     +modal-2-id+
     :modal
     :parent-id +modal-1-id+
     :open-p t)
    (setf *modal-2-open* t)
    (mnas-sdl3-gui/window-manager:set-focused-window
     *layer-manager*
     +modal-2-id+)
    t))

(defun close-top-modal ()
  "Close top-most modal layer if any was opened in runtime demo."
  (cond
    (*modal-2-open*
     (mnas-sdl3-gui/window-manager:close-window
      *layer-manager*
      +modal-2-id+)
     (setf *modal-2-open* nil)
     t)
    (*modal-1-open*
     (mnas-sdl3-gui/window-manager:close-window
      *layer-manager*
      +modal-1-id+)
     (setf *modal-1-open* nil
           *modal-2-open* nil)
     t)
    (t nil)))

(defun window-01 ()
  "Run a resizable window demo."
  (run-demo "Resizable Window Demo" :resizable))

;;;; (ql:quickload :mnas-sdl3-gui/demos/dialog/window-01)
;;;; (mnas-sdl3-gui/demos/dialog/window-01:window-01)

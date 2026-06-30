;;;; ./demos/dialog/widget/widget-01.lisp

(in-package :mnas-sdl3-gui/demos/dialog/widget-01)
                              
(defun entry-widget ()
  "Return first entry-like widget from the demo list." 
  (find-if (lambda (widget)
             (typep widget 'mnas-sdl3-gui/widgets:<entry>))
           *widgets*))

(defun apply-style (style)
  "Apply STYLE to current widget set and keep status synchronized." 
  (setf *style* style)
  (mnas-sdl3-gui/widgets:set-widget-style style)
  (setf *status-message* (format nil "Style switched to ~(~A~)." style)))

(defun make-toolbar (window)
  "Create toolbar as a secondary presenter of widget-01 commands." 
  (let ((toolbar
          (make-instance
           'mnas-sdl3-gui/widgets:<toolbar>
           :window window
           :layout :horizontal
           :height 34)))
    (setf (mnas-sdl3-gui/widgets:<widget-container>-children toolbar)
          (list
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :widget-01/style-flat
            :label "Flat" :width 58 :type :radio :group :style)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :widget-01/style-windows
            :label "Windows"
            :width 78
            :type :radio :group :style)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :widget-01/style-motif
            :label "Motif"
            :width 62
            :type :radio
            :group :style)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :widget-01/clear-entry
            :label "Clear"
            :width 56)
           (make-instance
            'mnas-sdl3-gui/widgets:<toolbar-button>
            :window window
            :command-id :widget-01/quit
            :label "Quit"
            :width 52)))
    toolbar))

(defun sync-command-state ()
  "Sync full-state command properties for toolbar rendering." 
  (let ((flat (mnas-sdl3-gui/commands:find-command :widget-01/style-flat))
        (windows (mnas-sdl3-gui/commands:find-command :widget-01/style-windows))
        (motif (mnas-sdl3-gui/commands:find-command :widget-01/style-motif))
        (clear (mnas-sdl3-gui/commands:find-command :widget-01/clear-entry))
        (entry (entry-widget)))
    (when flat
      (mnas-sdl3-gui/commands:set-command-checked flat (eq *style* :flat)))
    (when windows
      (mnas-sdl3-gui/commands:set-command-checked windows (eq *style* :windows)))
    (when motif
      (mnas-sdl3-gui/commands:set-command-checked motif (eq *style* :motif)))
    (when clear
      (mnas-sdl3-gui/commands:set-command-visible
       clear
       (and entry (> (length (mnas-sdl3-gui/widgets:<entry>-text entry)) 0))))))

;;; Create demo widgets

(defun create-demo-widgets ()
  "Create a collection of widgets for the demo."
  (list
    ;; Title label
    (make-instance 'mnas-sdl3-gui/widgets:<label>
                   :x 20 :y 20 :width 350 :height 30
                   :text "Widget Controls Demo")
    
    ;; Simple button
    (make-instance 'mnas-sdl3-gui/widgets:<button>
                   :x 20 :y 70 :width 100 :height 30
                   :text "Click Me"
                   :on-click (lambda (widget)
                              (setf *status-message* "Button clicked!")))
    
    ;; Toggle switch
    (make-instance 'mnas-sdl3-gui/widgets:<toggle>
                   :x 140 :y 70 :width 200 :height 30
                   :label "Enable Feature"
                   :state nil)
    
    ;; First checkbox
    (make-instance 'mnas-sdl3-gui/widgets:<check-box>
                   :x 20 :y 120 :width 150 :height 30
                   :label "Checkbox 1"
                   :checked nil)
    
    ;; Second checkbox
    (make-instance 'mnas-sdl3-gui/widgets:<check-box>
                   :x 20 :y 160 :width 150 :height 30
                   :label "Checkbox 2"
                   :checked t)
    
    ;; Edit box
    (make-instance 'mnas-sdl3-gui/widgets:<entry>
                   :x 20 :y 210 :width 300 :height 35
                   :text "Type here..."
                   :cursor 0
                   :max-length 100)

    ;; Editable combo box with dropdown and item creation
    (make-instance 'mnas-sdl3-gui/widgets:<editable-combo-box>
                   :x 20 :y 260 :width 300 :height 30
                   :main-height 30
                   :items '("Preset A" "Preset B" "Preset C")
                   :selected-index 0
                   :text ""
                   :cursor 0
                   :max-length 100
                   :max-visible-items 5
                   :placeholder "Type new item or select from list")

    ;; List box with items
    (make-instance 'mnas-sdl3-gui/widgets:<list-box>
                   :x 20 :y 310 :width 300 :height 150
                   :items '("Option 1" "Option 2" "Option 3" "Option 4" "Option 5"
              "Option 6" "Option 7" "Option 8")
                   :selected-index 0
                   :item-height 24)))




(defsystem "mnas-sdl3-gui"
  :description "mnas-sdl3-gui Common Lisp system"
  :author "mna"
  :license "GPL-3.0"
  :version "0.1.0"
  :depends-on ("sdl3"
               "sdl3-ttf"
               "mnas-sdl3-gui/events"
               "mnas-sdl3-gui/commands"
               "mnas-sdl3-gui/app"
               "mnas-sdl3-gui/widgets"
               "mnas-sdl3-gui/menu")
  :serial t
  :components ((:file "src/mnas-sdl3-gui")

               
               #+nil (:file "src/toolbar/package")
               #+nil (:file "src/toolbar/methods/compatibility")
               #+nil (:file "src/toolbar/presenter/functions")
               ))

(defsystem "mnas-sdl3-gui/events"
  :description "mnas-sdl3-gui Common Lisp system"
  :serial t
  :components ((:module "src/events"
		:serial t
                :components ((:file "package")
                             (:file "classes")
                             (:file "parameters")
                             (:file "event-tracker")
                             (:file "methods/process-sdl-event/process-sdl-event")
                             (:file "methods/log-event/log-event")
                             ))))

(defsystem "mnas-sdl3-gui/commands"
  :description "mnas-sdl3-gui Common Lisp system"
  :serial t
  :components ((:module "src/commands"
		:serial t
                :components ((:file "package")
                             (:file "functions")
                             (:file "shortcuts")))))

(defsystem "mnas-sdl3-gui/menu"
  :description "mnas-sdl3-gui Common Lisp system"
  :serial t
  :depends-on ("sdl3" "mnas-sdl3-gui/commands")
  :components ((:module "src/menu"
                :serial t
                :components ((:file "model/package")
                             (:file "model/classes")
                             (:file "model/functions")
                             (:file "controller/package")
                             (:file "controller/functions")
                             (:file "renderer/package")
                             (:file "renderer/functions")))))

(defsystem "mnas-sdl3-gui/app"
  :description "mnas-sdl3-gui Common Lisp system"
  :depends-on ("sdl3" "sdl3-ttf")
  :serial t
  :components ((:module "src/app"
		:serial t
                :components ((:file "package")
                             (:file "functions")))))

(defsystem "mnas-sdl3-gui/window-manager"
  :description "mnas-sdl3-gui Common Lisp system"
  :depends-on ("sdl3" "sdl3-ttf")
  :serial t
  :components ((:module "src/window-manager"
		:serial t
                :components ((:file "package")
                             (:file "classes")
                             (:file "functions")))))

(defsystem "mnas-sdl3-gui/widgets"
  :description "mnas-sdl3-gui Common Lisp system"
  :depends-on ("mnas-debug"
               "sdl3"
               "sdl3-ttf"
               "mnas-sdl3-gui/window-manager")
  :serial t
  :components ((:module "src/widgets"
		:serial t
                :components ((:file "package")
                             (:file "classes")
                             (:file "classes-grid")
                             (:file "methods/print-object")
                             (:file "generics")
                             (:file "functions")
                             (:file "combo-box-functions")
                             (:file "layout")
                             (:file "ttf-render")
                             (:file "methods/grid-layout")
                             (:file "methods/split-pane-layout")
                             (:file "sdl3-ttf-render")
                             (:file "style-functions")
                             (:file "rendering-primitives")
                             (:file "toggle-functions")
                             (:file "focus-functions")
                             (:file "entry-functions")
                             (:file "keyboard-functions")))
               (:module "src/widgets/methods"
		:serial t
                :components ((:file "render")
                             (:file "entry-cursor-pixel-offset")
                             (:file "compute-text-segment-pixel-width")
                             (:file "compute-text-offset-to-position")
                             (:file "entry-visible-text-width")
                             (:file "entry-visible-range")
                             (:file "clear-entry-selection")
                             (:file "get-entry-selected-text")
                             (:file "set-entry-selection")
                             (:file "entry-selection-anchor")
                             (:file "entry-select-from-anchor")
                             (:file "entry-select-previous-char")
                             (:file "entry-select-next-char")
                             (:file "entry-select-previous-word")
                             (:file "entry-select-next-word")
                             (:file "entry-select-to-start")
                             (:file "entry-select-to-end")
                             (:file "entry-inner-width")
                             (:file "entry-text-width-between")
                             (:file "entry-show-text")
                             (:file "entry-valid-text-p")
                             (:file "normalize-entry-scroll-offset")
                             (:file "entry-ensure-cursor-visible")
                             (:file "entry-scroll-to-start")
                             (:file "entry-position-from-pixel")
                             (:file "entry-scroll-to-end")
                             (:file "entry-copy-to-clipboard")
                             (:file "entry-paste-from-clipboard")
                             (:file "entry-delete-selection")
                             (:file "entry-move-to-previous-word")
                             (:file "entry-move-to-next-word")
                             
                             (:file "handle-mouse-wheel-event")
                             (:file "initialize-instance")
                             (:file "canvas-2d-methods")
                             (:file "contains-point-p")
                             (:file "visible-p")
                             (:file "enabled-p")
                             (:file "children")
                             (:file "update-widget-value")
                             (:file "widget-min-size")
                             (:file "activate-widget")
                             
                             (:file "handle-mouse-button-event")
                             (:file "handle-keyboard-event")
                             (:file "handle-text-input-event")

                             #+nil (:file "handle-widget-mouse-down")
                             #+nil (:file "handle-widget-mouse-up")
                             
                             (:file "widget-measure")
                             (:file "handle-mouse-motion-event")
                             (:file "handle-mouse-device-event")
                             ))))
               


(defsystem "mnas-sdl3-gui/demos"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/check-box"
               "mnas-sdl3-gui/demos/dialog/combo-box"
               "mnas-sdl3-gui/demos/dialog/entry"
               "mnas-sdl3-gui/demos/dialog/font"
               "mnas-sdl3-gui/demos/dialog/list-box"
               "mnas-sdl3-gui/demos/dialog/pack"
               "mnas-sdl3-gui/demos/layout/grid-01"
               "mnas-sdl3-gui/demos/layout/split-pane-01"
               "mnas-sdl3-gui/demos/dialog/polyhedron"
               "mnas-sdl3-gui/demos/dialog/simple"
               "mnas-sdl3-gui/demos/dialog/toggle"
               "mnas-sdl3-gui/demos/dialog/tree"
               "mnas-sdl3-gui/demos/dialog/widget"
               "mnas-sdl3-gui/demos/dialog/window"
               "mnas-sdl3-gui/demos/dialog/toolbar-demo"
               )
  :serial t
  :components ((:file "demos/package")
               (:file "demos/menu/package")
               (:file "demos/menu/screen-menu-classes")
               (:file "demos/dialog/package")))

(defsystem "mnas-sdl3-gui/demos/canvas"
      :description "Canvas demos for mnas-sdl3-gui"
      :depends-on ("mnas-sdl3-gui")
      :serial t
      :components ((:module "demos/canvas"
                      :serial t
                      :components ((:file "package")
                                   (:file "canvas-01")
                                   (:file "canvas-window-demo")))))

(defsystem "mnas-sdl3-gui/demos/dialog/simple"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/simple-01"))

(defsystem "mnas-sdl3-gui/demos/dialog/simple-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/simple/simple-01"
                :serial t
                :components ((:file "package")
                             (:file "simple-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/check-box"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui"
               "mnas-sdl3-gui/demos/dialog/check-box-01"
               "mnas-sdl3-gui/demos/dialog/combo-box-02"))


(defsystem "mnas-sdl3-gui/demos/dialog/check-box-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/check-box/check-box-01"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "commands")
                             (:file "callbacks")
                             (:file "check-box-01")
                             (:file "main")))))

(defsystem "mnas-sdl3-gui/demos/dialog/combo-box"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/combo-box-01"
               "mnas-sdl3-gui/demos/dialog/combo-box-02"
               "mnas-sdl3-gui/demos/dialog/combo-box-03"
               "mnas-sdl3-gui/demos/dialog/combo-box-04"))

(defsystem "mnas-sdl3-gui/demos/dialog/combo-box-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-01"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "commands")
                             (:file "toolbar")
                             (:file "shortcuts")
                             (:file "combo-box-01")
                             (:file "callbacks")
                             (:file "main")))))

(defsystem "mnas-sdl3-gui/demos/dialog/combo-box-02"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-02"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-02")))))

(defsystem "mnas-sdl3-gui/demos/dialog/combo-box-03"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-03"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-03")))))

(defsystem "mnas-sdl3-gui/demos/dialog/combo-box-04"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-04"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "combo-box-04")
                             (:file "callbacks")
                             (:file "main")
                             ))))

(defsystem "mnas-sdl3-gui/demos/dialog/combo-box-05"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-05"
                :serial t
                :components ((:file "package")
                             (:file "parameters")                             
                             (:file "combo-box-05")
                             (:file "callbacks")                             
                             (:file "main")
                             ))))

(defsystem "mnas-sdl3-gui/demos/dialog/toolbar-demo"
  :description "Toolbar demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/toolbar/toolbar-demo"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "commands")
                             (:file "toolbar-demo")))))


(defsystem "mnas-sdl3-gui/demos/dialog/entry"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/entry-01"
               "mnas-sdl3-gui/demos/dialog/entry-02"))

(defsystem "mnas-sdl3-gui/demos/dialog/entry-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/entry/entry-01"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "commands")
                             (:file "entry-01")
                             (:file "callbacks")
                             (:file "main")))))

(defsystem "mnas-sdl3-gui/demos/dialog/entry-02"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/entry/entry-02"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "commands")
                             (:file "entry-02")
                             (:file "callbacks")
                             (:file "main")))))

(defsystem "mnas-sdl3-gui/demos/dialog/polyhedron"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/polyhedron-01"
               "mnas-sdl3-gui/demos/dialog/polyhedron-02"
               "mnas-sdl3-gui/demos/dialog/polyhedron-03"
               "mnas-sdl3-gui/demos/dialog/polyhedron-04"))


(defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-01"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-02"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-02"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-02")))))

(defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-03"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-03"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-03")))))

(defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-04"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-04"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-04")))))

(defsystem "mnas-sdl3-gui/demos/dialog/tree"
  :description "Filesystem tree demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/tree-01"))

(defsystem "mnas-sdl3-gui/demos/dialog/tree-01"
  :description "Filesystem tree demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/tree/tree-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "tree-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/window"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/window-01"
               "mnas-sdl3-gui/demos/dialog/window-02"))

(defsystem "mnas-sdl3-gui/demos/dialog/window-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui
               #:mnas-sdl3-gui/demos/dialog/window-02
               #:mnas-sdl3-gui/demos/dialog/window-03)
  :serial t
  :components ((:module "demos/dialog/window/window-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "window-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/window-02"
  :description "Popup-menu window demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/window/window-02"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "window-02")))))

(defsystem "mnas-sdl3-gui/demos/dialog/window-03"
  :description "Transparent window demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/window/window-03"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "window-03")))))

(defsystem "mnas-sdl3-gui/demos/dialog/widget"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/widget-01"))

(defsystem "mnas-sdl3-gui/demos/dialog/widget-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/widget/widget-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "widget-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/toggle"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/toggle-01"))

(defsystem "mnas-sdl3-gui/demos/dialog/toggle-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/toggle/toggle-01"
                :serial t
                :components ((:file "package")
                             (:file "parameters")
                             (:file "commands")
                             (:file "callbacks")
                             (:file "toggle-01")
                             (:file "main")))))

(defsystem "mnas-sdl3-gui/demos/dialog/font"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/font-01"))


(defsystem "mnas-sdl3-gui/demos/dialog/font-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/font/font-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "font-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/pack"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/pack-01"))

(defsystem "mnas-sdl3-gui/demos/dialog/pack-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/pack/pack-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "pack-01")))))

(defsystem "mnas-sdl3-gui/demos/dialog/list-box"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/list-box-01"))

(defsystem "mnas-sdl3-gui/demos/dialog/list-box-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/list-box/list-box-01"
                :serial t
                :components ((:file "package")
                             (:file "list-box-01")
                             (:file "callbacks")
                             (:file "main")))))

(defsystem "mnas-sdl3-gui/demos/layout/grid-01"
  :description "Grid layout demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/layout/grid-01"
                :serial t
                :components ((:file "package")
                             (:file "grid-01")))))

(defsystem "mnas-sdl3-gui/demos/layout/split-pane-01"
  :description "Split pane layout demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/layout/split-pane-01"
                :serial t
                :components ((:file "package")
                             (:file "split-pane-01")))))

(defsystem "mnas-sdl3-gui/demos/input-events"
  :description "Split pane layout demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/input-events"
                :serial t
                :components ((:file "package")
                             (:file "input-events-demo")))))

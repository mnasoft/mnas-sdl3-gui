(asdf:defsystem #:mnas-sdl3-gui
  :description "mnas-sdl3-gui Common Lisp system"
  :author "mna"
  :license "GPL-3.0"
  :version "0.1.0"
  :depends-on (#:sdl3 #:sdl3-ttf)
  :serial t
  :components ((:file "src/mnas-sdl3-gui")
               (:file "src/debug")
               (:file "src/commands/package")
               (:file "src/commands/functions")
               (:file "src/commands/shortcuts")
               (:file "src/window-manager/package")
               (:file "src/window-manager/classes")
               (:file "src/window-manager/functions")
               (:file "src/menu/model/package")
               (:file "src/menu/model/classes")
               (:file "src/menu/model/functions")
               (:file "src/menu/controller/package")
               (:file "src/menu/controller/functions")
               (:file "src/menu/renderer/package")
               (:file "src/menu/renderer/functions")
               (:file "src/widgets/package")
               (:file "src/toolbar/package")
               (:file "src/toolbar/classes")
               (:file "src/toolbar/presenter/package")
               (:file "src/toolbar/presenter/functions")
               (:file "src/widgets/classes")
               (:file "src/widgets/classes-grid")
               (:file "src/widgets/methods/print-object")
               (:file "src/widgets/generics")
               (:file "src/widgets/functions")
               (:file "src/widgets/layout")
               (:file "src/widgets/ttf-render")
               (:file "src/widgets/methods/grid-layout")
               (:file "src/widgets/sdl3-ttf-render")
               (:file "src/widgets/style-functions")
               (:file "src/widgets/rendering-primitives")
               (:file "src/widgets/methods/render")
               (:file "src/widgets/toggle-functions")
               (:file "src/widgets/focus-functions")
               (:file "src/widgets/methods/handle-widget-mouse-wheel")
               (:file "src/widgets/mouse-functions")
               (:file "src/widgets/entry-functions")
               (:file "src/widgets/methods/entry-cursor-pixel-offset")
               (:file "src/widgets/methods/compute-text-segment-pixel-width")
               (:file "src/widgets/methods/compute-text-offset-to-position")
               (:file "src/widgets/methods/entry-visible-text-width")
               (:file "src/widgets/methods/entry-visible-range")
               (:file "src/widgets/methods/clear-entry-selection")
               (:file "src/widgets/methods/get-entry-selected-text")
               (:file "src/widgets/methods/set-entry-selection")
               (:file "src/widgets/methods/entry-selection-anchor")
               (:file "src/widgets/methods/entry-select-from-anchor")
               (:file "src/widgets/methods/entry-select-previous-char")
               (:file "src/widgets/methods/entry-select-next-char")
               (:file "src/widgets/methods/entry-select-previous-word")
               (:file "src/widgets/methods/entry-select-next-word")
               (:file "src/widgets/methods/entry-select-to-start")
               (:file "src/widgets/methods/entry-select-to-end")
               (:file "src/widgets/methods/entry-inner-width")
               (:file "src/widgets/methods/entry-text-width-between")
               (:file "src/widgets/methods/entry-show-text")
               (:file "src/widgets/methods/entry-valid-text-p")
               (:file "src/widgets/methods/normalize-entry-scroll-offset")
               (:file "src/widgets/methods/entry-ensure-cursor-visible")
               (:file "src/widgets/methods/entry-scroll-to-start")
               (:file "src/widgets/methods/entry-position-from-pixel")
               (:file "src/widgets/methods/entry-scroll-to-end")
               (:file "src/widgets/methods/entry-copy-to-clipboard")
               (:file "src/widgets/methods/entry-paste-from-clipboard")
               (:file "src/widgets/methods/entry-delete-selection")
               (:file "src/widgets/methods/entry-move-to-previous-word")
               (:file "src/widgets/methods/entry-move-to-next-word")
               (:file "src/widgets/keyboard-functions")
               (:file "src/widgets/methods/initialize-instance")
               (:file "src/widgets/methods/canvas-2d-methods")
               (:file "src/widgets/methods/contains-point-p")
               (:file "src/widgets/methods/visible-p")
               (:file "src/widgets/methods/enabled-p")
               (:file "src/widgets/methods/children")
               (:file "src/widgets/methods/update-widget-value")
               (:file "src/widgets/methods/widget-min-size")
               (:file "src/widgets/methods/activate-widget")
               (:file "src/widgets/methods/handle-widget-mouse-down")
               (:file "src/widgets/methods/handle-widget-mouse-up")
               (:file "src/widgets/methods/handle-widget-mouse-motion")
               (:file "src/widgets/methods/handle-widget-key-press")
               (:file "src/widgets/methods/handle-widget-key-event")))

(asdf:defsystem #:mnas-sdl3-gui/demos
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/check-box"
               "mnas-sdl3-gui/demos/dialog/combo-box"
               "mnas-sdl3-gui/demos/dialog/entry"
               "mnas-sdl3-gui/demos/dialog/font"
               "mnas-sdl3-gui/demos/dialog/list-box"
               "mnas-sdl3-gui/demos/dialog/pack"
               "mnas-sdl3-gui/demos/dialog/polyhedron"
               "mnas-sdl3-gui/demos/dialog/simple"
               "mnas-sdl3-gui/demos/dialog/toggle"
               "mnas-sdl3-gui/demos/dialog/tree"
               "mnas-sdl3-gui/demos/dialog/widget"
               "mnas-sdl3-gui/demos/dialog/window"
               )
  :serial t
  :components ((:file "demos/package")
               (:file "demos/menu/package")
               (:file "demos/menu/screen-menu-classes")
               (:file "demos/dialog/package")))

(asdf:defsystem #:mnas-sdl3-gui/demos/canvas
      :description "Canvas demos for mnas-sdl3-gui"
      :depends-on ("mnas-sdl3-gui")
      :serial t
      :components ((:module "demos/canvas"
                      :serial t
                      :components ((:file "package")
                                   (:file "canvas-01")
                                   (:file "canvas-window-demo")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/simple"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/simple-01"))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/simple-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/simple/simple-01"
                :serial t
                :components ((:file "package")
                             (:file "simple-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/check-box"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui"
               "mnas-sdl3-gui/demos/dialog/check-box-01"
               "mnas-sdl3-gui/demos/dialog/combo-box-02"))


(asdf:defsystem "mnas-sdl3-gui/demos/dialog/check-box-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/check-box/check-box-01"
                :serial t
                :components ((:file "package")
                             (:file "check-box-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/combo-box"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/combo-box-01"
               "mnas-sdl3-gui/demos/dialog/combo-box-02"
               "mnas-sdl3-gui/demos/dialog/combo-box-03"
               "mnas-sdl3-gui/demos/dialog/combo-box-04"))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/combo-box-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-01"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/combo-box-02
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-02"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-02")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/combo-box-03"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-03"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-03")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/combo-box-04"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-04"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-04")))))


(asdf:defsystem "mnas-sdl3-gui/demos/dialog/entry"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/entry-01"
               "mnas-sdl3-gui/demos/dialog/entry-02"))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/entry-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/entry/entry-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "entry-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/entry-02
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/entry/entry-02"
                :serial t
                :components ((:file "package")
                             (:file "entry-02")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/polyhedron"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/polyhedron-01"
               "mnas-sdl3-gui/demos/dialog/polyhedron-02"
               "mnas-sdl3-gui/demos/dialog/polyhedron-03"
               "mnas-sdl3-gui/demos/dialog/polyhedron-04"))


(asdf:defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-01"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-02"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-02"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-02")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-03"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-03"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-03")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/polyhedron-04"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-04"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-04")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/tree"
  :description "Filesystem tree demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/tree-01"))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/tree-01"
  :description "Filesystem tree demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/tree/tree-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "tree-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/window"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/window-01"
               "mnas-sdl3-gui/demos/dialog/window-02"))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/window-01
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

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/window-02
  :description "Popup-menu window demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/window/window-02"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "window-02")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/window-03
  :description "Transparent window demo for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/window/window-03"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "window-03")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/widget"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/widget-01"))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/widget-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/widget/widget-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "widget-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/toggle"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/toggle-01"))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/toggle-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/toggle/toggle-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "toggle-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/font"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/font-01"))


(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/font-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/font/font-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "font-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/pack"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/pack-01"))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/pack-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/pack/pack-01"
                :serial t
                :components ((:file "package")
                             (:file "commands")
                             (:file "pack-01")))))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/list-box"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui/demos/dialog/list-box-01"))

(asdf:defsystem "mnas-sdl3-gui/demos/dialog/list-box-01"
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui")
  :serial t
  :components ((:module "demos/dialog/list-box/list-box-01"
                :serial t
                :components ((:file "package")
                             (:file "list-box-01")))))


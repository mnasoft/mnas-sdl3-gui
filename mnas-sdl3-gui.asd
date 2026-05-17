(asdf:defsystem #:mnas-sdl3-gui
  :description "mnas-sdl3-gui Common Lisp system"
  :author "mna"
  :license "GPL-3.0"
  :version "0.1.0"
  :depends-on (#:sdl3 #:sdl3-ttf)
  :serial t
  :components ((:file "src/mnas-sdl3-gui")
               (:file "src/menu/model/package")
               (:file "src/menu/model/classes")
               (:file "src/menu/model/functions")
               (:file "src/menu/controller/package")
               (:file "src/menu/controller/functions")
               (:file "src/menu/renderer/package")
               (:file "src/menu/renderer/functions")
               (:file "src/widgets/package")
               (:file "src/widgets/classes")
               (:file "src/widgets/methods/print-object")
               (:file "src/widgets/generics")
               (:file "src/widgets/functions")
               (:file "src/widgets/layout")
               (:file "src/widgets/ttf-render")
               (:file "src/widgets/sdl3-ttf-render")
               (:file "src/widgets/style-functions")
               (:file "src/widgets/rendering-primitives")
               (:file "src/widgets/methods/render")
               (:file "src/widgets/toggle-functions")
               (:file "src/widgets/focus-functions")
               (:file "src/widgets/mouse-functions")
               (:file "src/widgets/edit-box-functions")
               (:file "src/widgets/methods/edit-box-cursor-pixel-offset")
               (:file "src/widgets/methods/compute-text-segment-pixel-width")
               (:file "src/widgets/methods/compute-text-offset-to-position")
               (:file "src/widgets/methods/edit-box-visible-text-width")
               (:file "src/widgets/methods/edit-box-visible-range")
               (:file "src/widgets/methods/render-edit-box-text-and-cursor")
               (:file "src/widgets/methods/clear-edit-box-selection")
               (:file "src/widgets/methods/get-edit-box-selected-text")
               (:file "src/widgets/methods/set-edit-box-selection")
               (:file "src/widgets/methods/edit-box-selection-anchor")
               (:file "src/widgets/methods/edit-box-select-from-anchor")
               (:file "src/widgets/methods/edit-box-select-previous-char")
               (:file "src/widgets/methods/edit-box-select-next-char")
               (:file "src/widgets/methods/edit-box-select-previous-word")
               (:file "src/widgets/methods/edit-box-select-next-word")
               (:file "src/widgets/methods/edit-box-select-to-start")
               (:file "src/widgets/methods/edit-box-select-to-end")
               (:file "src/widgets/methods/edit-box-inner-width")
               (:file "src/widgets/methods/edit-box-text-width-between")
               (:file "src/widgets/methods/normalize-edit-box-scroll-offset")
               (:file "src/widgets/methods/edit-box-ensure-cursor-visible")
               (:file "src/widgets/methods/edit-box-scroll-to-start")
               (:file "src/widgets/methods/edit-box-position-from-pixel")
               (:file "src/widgets/methods/edit-box-scroll-to-end")
               (:file "src/widgets/methods/edit-box-copy-to-clipboard")
               (:file "src/widgets/methods/edit-box-paste-from-clipboard")
               (:file "src/widgets/methods/edit-box-delete-selection")
               (:file "src/widgets/methods/edit-box-move-to-previous-word")
               (:file "src/widgets/methods/edit-box-move-to-next-word")
               (:file "src/widgets/keyboard-functions")
               (:file "src/widgets/methods/initialize-instance")
               (:file "src/widgets/methods/contains-point-p")
               (:file "src/widgets/methods/update-widget-value")
               (:file "src/widgets/methods/widget-min-size")
               (:file "src/widgets/methods/activate-widget")
               (:file "src/widgets/methods/handle-widget-mouse-down")
               (:file "src/widgets/methods/handle-widget-mouse-up")
               (:file "src/widgets/methods/handle-widget-key-press")
               (:file "src/widgets/methods/handle-widget-key-event")))

(asdf:defsystem #:mnas-sdl3-gui/demos
  :description "Demos for mnas-sdl3-gui"
  :depends-on ("mnas-sdl3-gui"
               "mnas-sdl3-gui/demos/dialog/check-box-01"
               "mnas-sdl3-gui/demos/dialog/combo-box-01"
               "mnas-sdl3-gui/demos/dialog/combo-box-02"
               "mnas-sdl3-gui/demos/dialog/edit-box-01"
               "mnas-sdl3-gui/demos/dialog/polyhedron-01"
               "mnas-sdl3-gui/demos/dialog/polyhedron-02"
               "mnas-sdl3-gui/demos/dialog/polyhedron-03"
               "mnas-sdl3-gui/demos/dialog/window-01"
               "mnas-sdl3-gui/demos/dialog/widget-01"
               "mnas-sdl3-gui/demos/dialog/toggle-01"
               "mnas-sdl3-gui/demos/dialog/font-01"
               "mnas-sdl3-gui/demos/dialog/pack-01"
               )
  :serial t
  :components ((:file "demos/package")
               (:file "demos/menu/package")
               (:file "demos/menu/screen-menu-classes")
               (:file "demos/dialog/package")))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/simple-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/simple/simple-01"
                :serial t
                :components ((:file "package")
                             (:file "simple-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/check-box-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/check-box/check-box-01"
                :serial t
                :components ((:file "package")
                             (:file "check-box-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/combo-box-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-01"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/combo-box-02
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/combo-box/combo-box-02"
                :serial t
                :components ((:file "package")
                             (:file "combo-box-02")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/edit-box-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/edit-box/edit-box-01"
                :serial t
                :components ((:file "package")
                             (:file "edit-box-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/polyhedron-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-01"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/polyhedron-02
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-02"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-02")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/polyhedron-03
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/polyhedron/polyhedron-03"
                :serial t
                :components ((:file "package")
                             (:file "polyhedron-03")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/window-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/window/window-01"
                :serial t
                :components ((:file "package")
                             (:file "window-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/widget-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/widget/widget-01"
                :serial t
                :components ((:file "package")
                             (:file "widget-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/toggle-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/toggle/toggle-01"
                :serial t
                :components ((:file "package")
                             (:file "toggle-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/font-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/font/font-01"
                :serial t
                :components ((:file "package")
                             (:file "font-01")))))

(asdf:defsystem #:mnas-sdl3-gui/demos/dialog/pack-01
  :description "Demos for mnas-sdl3-gui"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:module "demos/dialog/pack/pack-01"
                :serial t
                :components ((:file "package")
                             (:file "pack-01")))))



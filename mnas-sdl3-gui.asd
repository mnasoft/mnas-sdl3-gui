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
               (:file "src/widgets/base")
               (:file "src/widgets/ttf-render")
               (:file "src/widgets/sdl3-ttf-render")
               (:file "src/widgets/renderer")
               (:file "src/widgets/events")))

(asdf:defsystem #:mnas-sdl3-gui/demos
  :description "Demos for mnas-sdl3-gui"
  :author "mna"
  :license "GPL-3.0"
  :version "0.1.0"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:file "demos/menu/package")
               (:file "demos/menu/screen-menu-classes")
               (:file "demos/dialog/package")
               (:file "demos/dialog/widgets-demo")
               (:file "demos/dialog/edit-box-ok-dialog-demo")
               (:file "demos/dialog/cyrillic-font-demo")
               (:file "demos/simple-dialog/package")
               (:file "demos/simple-dialog/simple-dialog-demo")))

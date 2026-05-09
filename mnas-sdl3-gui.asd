(asdf:defsystem #:mnas-sdl3-gui
  :description "mnas-sdl3-gui Common Lisp system"
  :author "mna"
  :license "GPL-3.0"
  :version "0.1.0"
  :depends-on (#:sdl3)
  :serial t
  :components ((:file "src/mnas-sdl3-gui")
               (:file "src/menu/model/package")
               (:file "src/menu/model/classes")
               (:file "src/menu/model/functions")
               (:file "src/menu/controller/package")
               (:file "src/menu/controller/functions")
               (:file "src/menu/renderer/package")
               (:file "src/menu/renderer/functions")))

(asdf:defsystem #:mnas-sdl3-gui/demos
  :description "Demos for mnas-sdl3-gui"
  :author "mna"
  :license "GPL-3.0"
  :version "0.1.0"
  :depends-on (#:mnas-sdl3-gui)
  :serial t
  :components ((:file "demos/menu/package")
               (:file "demos/menu/screen-menu-classes")))

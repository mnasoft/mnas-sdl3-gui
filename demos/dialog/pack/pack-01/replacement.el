(setq w-dir "~/quicklisp/local-projects/sdl3/mnas-sdl3-gui/demos/dialog/pack/pack-01/")
(setq w-ext '("lisp"))
(setq w-rpl
      '(("mnas-sdl3-gui/widgets:entry"                       "mnas-sdl3-gui/widgets:<entry>")
        ("mnas-sdl3-gui/widgets:entry-text"                  "mnas-sdl3-gui/widgets:<entry>-text")
        ("mnas-sdl3-gui/widgets:entry-cursor"                "mnas-sdl3-gui/widgets:<entry>-cursor")
        ("mnas-sdl3-gui/widgets:<toolbar-button>"            "mnas-sdl3-gui/widgets:<toolbar-button>")
        ("mnas-sdl3-gui/widgets:toolbar-button-clicked"      "mnas-sdl3-gui/widgets:<toolbar-button>-clicked")
        ("mnas-sdl3-gui/widgets:check-box"                   "mnas-sdl3-gui/widgets:<check-box>")
        ("mnas-sdl3-gui/widgets:check-box-checked"           "mnas-sdl3-gui/widgets:<check-box>-checked")
        ("mnas-sdl3-gui/widgets:toggle"                      "mnas-sdl3-gui/widgets:<toggle>")
        ("mnas-sdl3-gui/widgets:toggle-state"                "mnas-sdl3-gui/widgets:<toggle>-state")
        ("mnas-sdl3-gui/widgets:button"                      "mnas-sdl3-gui/widgets:<button>")
        ("mnas-sdl3-gui/widgets:label"                       "mnas-sdl3-gui/widgets:<label>")
        ("mnas-sdl3-gui/widgets:list-box"                    "mnas-sdl3-gui/widgets:<list-box>")
        ("mnas-sdl3-gui/widgets:toolbar"                     "mnas-sdl3-gui/widgets:<toolbar>")
        ("mnas-sdl3-gui/widgets:<widget-container>-children" "mnas-sdl3-gui/widgets:<widget-container>-children")))

(mapcar
 #'(lambda (el)
            (my/replace-in-files-silently (first el) (second el) w-dir w-ext)))












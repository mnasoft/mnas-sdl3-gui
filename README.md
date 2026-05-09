# mnas-sdl3-gui

Common Lisp ASDF system scaffold.

## Dependency

This system depends on `sdl3`.

## Load

```lisp
(ql:quickload :mnas-sdl3-gui)
```

## Run tests

```lisp
(ql:quickload :mnas-sdl3-gui.tests)
(asdf:test-system :mnas-sdl3-gui.tests)
```

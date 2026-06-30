# AGENTS.md

## Purpose
This file provides project-specific guidance for AI coding agents working on `mnas-sdl3-gui`.

> Use this local workspace guidance together with any global instructions already provided by the environment.

## What this project is
- Common Lisp GUI toolkit built on SDL3.
- Uses ASDF systems: `:mnas-sdl3-gui` and `:mnas-sdl3-gui.tests`.
- Main source tree in `src/`, demos in `demos/`, tests in `tests/`.

## Key conventions
- One package per `.lisp` file.
- Files typically begin with a project-relative header line, e.g. `;;;; ./src/widgets/base.lisp`.
- Package definitions are usually in `package.lisp` files inside subdirectories.
- Renderers and event logic are split by feature area: `menu/`, `widgets/`, etc.
- Tests use FiveAM and are run via `asdf:test-system`.

## Build and test commands
- Load the main system:
  ```lisp
  (ql:quickload :mnas-sdl3-gui)
  ```
- Load demos and run a demo function:
  ```lisp
  (ql:quickload :mnas-sdl3-gui.demos)
  (mnas-sdl3-gui/demos/menu:do-screen-menu-demo)
  ```
- Run the test suite:
  ```lisp
  (ql:quickload :mnas-sdl3-gui.tests)
  (asdf:test-system :mnas-sdl3-gui.tests)
  ```

## Useful files
- `README.md` — project overview, conventions, examples.
- `src/mnas-sdl3-gui.lisp` — main package entry point.
- `src/menu/` — menu models, controller, and renderer.
- `src/widgets/` — widget classes, rendering, and event handling.
- `tests/` — FiveAM tests for the system.
- `.github/skills/common-lisp-project-style.md` — local conventions for Common Lisp naming, packages, and style.

## Notes for agents
- Keep local changes consistent with existing package and file-layout conventions.
- Prefer linking to `README.md` or existing docs for details instead of duplicating long explanations.
- Do not create a conflicting local instructions file if one already exists.

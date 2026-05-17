# mnas-sdl3-gui

Common Lisp GUI toolkit built on top of SDL3 for cross-platform graphical user interface development.

## Features

### Menu Module (`mnas-sdl3-gui/menu`)
- Hierarchical menu bar with dropdown support
- Keyboard and mouse navigation
- Submenu support with proper layout calculation
- Text width and alignment handling

### Widgets Module (`mnas-sdl3-gui/widgets`)
- Base `widget` class with common properties (x, y, width, height, enabled, focused, visible, value)
- Concrete widget types:
  - `label` — static text labels
  - `button` — clickable buttons with callbacks
  - `toggle` — on/off switches
  - `check-box` — checkbox controls
  - `entry` — text input fields with cursor support
  - `list-box` — scrollable item lists with selection
- SDL3-based rendering with color support
- Mouse and keyboard event handling

### Text Rendering
- Built-in SDL3 debug font for clean, readable text
- Consistent rendering across menu and widget components
- Full Unicode support via SDL3

### Demo Applications
- `demos/menu` — Interactive menu bar demonstration
- `demos/dialog` — Widget controls showcase with all element types

## Dependencies

- SDL3 (`:sdl3` ASDF system)
- FiveAM (for tests)

## Installation

Ensure the project is in your Quicklisp `local-projects`:

```bash
cd ~/.quicklisp/local-projects/sdl3
git clone <repository> mnas-sdl3-gui
cd mnas-sdl3-gui
```

## Usage

### Load the system

```lisp
(ql:quickload :mnas-sdl3-gui)
```

### Run menu demo

```lisp
(ql:quickload :mnas-sdl3-gui.demos)
(mnas-sdl3-gui/demos/menu:do-screen-menu-demo)
```

Click menu titles to open dropdowns. Use Escape to close. Mouse and keyboard navigation supported.

### Run widgets demo

```lisp
(ql:quickload :mnas-sdl3-gui.demos)
(mnas-sdl3-gui/demos/dialog:do-dialog-demo)
```

Interact with all widget types: click buttons, toggle switches, type in edit boxes, select list items.

### Run tests

```lisp
(ql:quickload :mnas-sdl3-gui.tests)
(asdf:test-system :mnas-sdl3-gui.tests)
```

## Project Structure

```
src/
  mnas-sdl3-gui.lisp          — Main package and project entry point
  menu/
    model/                    — Menu data structures and algorithms
    controller/               — Mouse event handling
    renderer/                 — SDL3 rendering for menus
  widgets/
    package.lisp              — Widget package definitions
    base.lisp                 — Base widget class and widget types
    renderer.lisp             — SDL3 rendering for widgets
    events.lisp               — Mouse and keyboard event handling

demos/
  menu/                       — Menu bar demonstration
  dialog/                     — Widget controls demonstration

tests/                        — FiveAM test suite

.github/
  skills/                     — (Planned) Common Lisp skill definitions
```

## Code Conventions

- **One package per file**: Each `.lisp` file defines exactly one package
- **File headers**: First line contains project-relative path (e.g., `;;;; ./src/widgets/base.lisp`)
- **Subpackage layout**: Directories organize related functionality
  - `package.lisp` — package declaration with `defpackage` and `in-package`
  - `classes.lisp` — CLOS class definitions
  - `functions.lisp` — functions and algorithms
  - `renderer.lisp` — rendering/display code
  - `events.lisp` — event handling

## Roadmap

- [ ] True Type Font (TTF) text rendering via SDL_ttf
- [ ] Dialog windows (modal and modeless)
- [ ] Menu bar customization (themes, icons)
- [ ] Event system improvements
- [ ] Performance optimization for large widget trees
- [ ] Documentation site (Sphinx or similar)

## License

GPL-3.0

## Authors

- mna

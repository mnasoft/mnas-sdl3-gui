# common-lisp-project-style

A repository-local skill for writing Common Lisp code that follows the general Lisp style guide while preserving this project's naming conventions.

## Purpose
- Use when creating or editing Common Lisp code, packages, classes, accessors, or ASDF systems in this repository.
- Keep new code consistent with the Lisp style guide and with the local conventions below.
- Use as a checklist during reviews and refactors.

## Core rules from the Lisp style guide
- Prefer clear, explicit names over abbreviations.
- Use lowercase names separated by single dashes, for example `make-widget`, `widget-width`.
- Use predicate names ending in `-p` for multi-word predicates, for example `widget-visible-p`.
- Use `when` and `unless` for one-branch conditionals instead of `if` when appropriate.
- Keep conditions short and factor complex logic into helper functions.
- Keep forms readable and well-indented; two-space indentation is the default convention.
- Keep line length reasonable, typically under 100 columns.
- Put a file header with four semicolons at the top of each source file.
- Use docstrings for functions, packages, classes, and slots whenever practical.
- Prefer one package per file and avoid broad `:use` unless it is truly necessary.
- Use hierarchical package names and keep package and system names aligned with the project structure.

## Project-specific conventions
- Class names are written in angle brackets, for example `<widget>`, `<combo-box-popup>`, `<tree-view>`.
- Accessor names follow the pattern `<ClassName>-<slot-name>` using angle brackets around the class name, for example `<widget>-x`, `<combo-box-popup>-owner`.
- Package names match system names and use slash as the separator between parts, for example `:mnas-sdl3-gui/widgets`, not `:mnas.sdl3-gui.widgets`.
- Keep package definitions in dedicated `package.lisp` files, with one package per file when practical.
- For CLOS slots, keep the slot option order readable and documented, and use `:type` and `:documentation` where it helps clarity.

## Examples
```lisp
(defclass <combo-box-popup> (<list-box>)
  ((owner
    :initarg :owner
    :accessor <combo-box-popup>-owner
    :documentation "Owner widget for this popup instance.")
   (window
    :initarg :window
    :initform nil
    :accessor <combo-box-popup>-window
    :documentation "SDL window handle used by this popup.")))
```

```lisp
(defpackage :mnas-sdl3-gui/widgets
  (:use #:cl)
  (:export #:widget
           #:<widget>-x))
```

## Review checklist
- Are package names using `/` separators?
- Are class names enclosed in angle brackets?
- Are accessors named as `<Class>-<slot>`?
- Are exported symbols declared in the package file?
- Does the code stay readable and idiomatic Lisp?

## When to use
- Creating a new subsystem, package, or ASDF system.
- Writing or refactoring widgets, layouts, or event handling code.
- Reviewing code for consistency before committing or submitting changes.

## References
- See [README.md](../../README.md) and [AGENTS.md](../../AGENTS.md) for repository-specific conventions.

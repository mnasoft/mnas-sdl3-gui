# Copilot Instructions

This repository is a Common Lisp GUI toolkit built on SDL3.

## Use this guidance when assisting with code changes
- Prefer project-specific conventions from `README.md` and `AGENTS.md`.
- Keep files aligned with the existing one-package-per-file and package-per-directory style.
- Preserve file header conventions such as `;;;; ./src/widgets/base.lisp`.
- Do not create new top-level instructions files if `.github/copilot-instructions.md` already exists.

## Important paths
- `src/` — main source code
- `demos/` — example/demo applications
- `tests/` — FiveAM test suite
- `mnas-sdl3-gui.asd` — main ASDF system
- `mnas-sdl3-gui.tests.asd` — test system

## Build and test
- Load system:
  ```lisp
  (ql:quickload :mnas-sdl3-gui)
  ```
- Run tests:
  ```lisp
  (ql:quickload :mnas-sdl3-gui.tests)
  (asdf:test-system :mnas-sdl3-gui.tests)
  ```

## Skill and customization workflow
- Add new repo-level agent skills under `.github/skills/`.
- Use `/create-skill` to scaffold or update local chat customization files.
- Keep new skills concise and link to `README.md` or `AGENTS.md` for project conventions.

## Notes
- Link to existing docs instead of repeating them.
- Use `AGENTS.md` for additional local agent guidance.

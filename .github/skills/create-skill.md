# create-skill

A local repository skill for scaffolding or updating agent customization files.

## Purpose
- Use when the repository needs a new chat customization file such as `AGENTS.md`, `.github/copilot-instructions.md`, or a new skill under `.github/skills/`.
- Keep the guidance concise and aligned with existing project conventions.

## When to use
- Adding repo-specific helper skills or prompt customizations.
- Documenting project conventions and build/test commands for AI agents.
- Creating or updating local instruction files in this repository.

## Notes
- Prefer linking to existing docs (`README.md`, `AGENTS.md`) rather than duplicating content.
- Preserve the one-package-per-file Common Lisp convention used in the codebase.
- Do not create a conflicting top-level instructions file if one already exists.

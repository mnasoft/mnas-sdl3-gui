# fix-progress-task

A repo-local skill for updating task lists and progress state in `GUI-ARCHITECTURE.org`.

## Purpose
- Use when the user asks to mark progress, split a task into subtasks, or update the checklist state in the architecture roadmap.
- Keep task descriptions aligned with current repository status and avoid changing unrelated architecture text.

## When to use
- The user wants to reflect completed work in the roadmap.
- The user asks to mark a task as done or partially done.
- The user asks to decompose a task into subitems and preserve progress state.

## Guidance
- Edit `GUI-ARCHITECTURE.org` only.
- Find the relevant checklist item in the "Ближайшие задачи" section.
- Use Org-style checkbox syntax:
  - `- [X]` for completed items
  - `- [ ]` for pending items
  - `- [/]` for work in progress if needed
- If the task needs breakdown, convert it into a nested sublist under the main item with one completed subtask and the rest remaining.
- Preserve surrounding text and list indentation.
- Do not create new top-level sections unless the user explicitly asks for roadmap expansion.

## Example prompts
- "Отрази в перечне задач что сделано и что предстоит в виде подсписка"
- "Поставь задачу контейнеров в состояние прогресса"
- "Обнови roadmap в GUI-ARCHITECTURE.org по текущему прогрессу"

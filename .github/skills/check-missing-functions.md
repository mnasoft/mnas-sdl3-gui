# check-missing-functions

Local repository skill for verifying missing function definitions before running a Common Lisp demo entry point.

## Purpose
- Use when a demo entry point fails or may fail with undefined function errors.
- Confirm symbol availability at three levels: source search, ASDF/package wiring, and runtime bindings.
- Distinguish normal CFFI callback behavior from real missing defun cases.

## When to use
- Calling a demo function like (polyhedron-03) or similar entry points.
- Refactoring demo files where helper functions may be renamed or removed.
- Investigating runtime errors that mention undefined function, unbound symbol, or callback issues.

## Procedure
1. Static search in source:
- Find all calls in the target file.
- For each called symbol, search for defun/defgeneric/defmethod definitions across the workspace.
- If a call has no definition match, mark it as a likely blocker.

2. Package and system wiring check:
- Verify in-package and defpackage for the demo package.
- Verify ASDF includes both package.lisp and the implementation file in correct order.

3. Runtime load check (SBCL):
- Quickload the target ASDF system.
- Check that entry symbols exist in the expected package.
- Use fboundp for ordinary functions.

4. CFFI callback exception:
- Symbols defined through sdl3:def-app-init, sdl3:def-app-iterate, sdl3:def-app-event, sdl3:def-app-quit may not look like regular defun bindings.
- Validate callbacks with cffi:get-callback instead of relying only on fboundp.

5. Report and fix:
- Report exact missing symbol(s).
- Add missing defun with style consistent to neighboring demos.
- Re-run runtime check after the fix.

## Command snippets
- Runtime quickload and symbol check:
  sbcl --non-interactive --eval '(ql:quickload :system-name)' --eval '(let* ((pkg (find-package :target/package)) (sym (find-symbol "ENTRY" pkg))) (format t "~%entry=~a fboundp=~a~%" sym (and sym (fboundp sym))))' --quit

- Callback check for def-app symbols:
  sbcl --non-interactive --eval '(ql:quickload :system-name)' --eval '(let ((sym (find-symbol "CALLBACK-NAME" :target/package))) (format t "~%callback-ok=~a~%" (handler-case (progn (cffi:get-callback sym) t) (error () nil))))' --quit

## Example from this repository
- In polyhedron-03 demo, render-polyhedron-solid-overlay was called in iterate loop but not defined.
- Fix was to add render-polyhedron-solid-overlay in the same file and revalidate via SBCL load + fboundp.

## References
- See README.md and AGENTS.md for project conventions.
- Keep one package per file and preserve existing demo coding style.

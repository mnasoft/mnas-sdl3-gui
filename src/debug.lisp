;;;; ./src/debug.lisp

(in-package #:mnas-sdl3-gui)

;; Compile-time macros / helper for debug logging.
;; These macros expand at macro-expansion time according to the
;; presence of :debug in *features*. To make them active for already
;; compiled files you must add :debug to *features* and recompile the
;; affected ASDF systems (see `enable-debug`).

(defun debug-feature-p ()
  "Return non-nil if `:debug` is present in `*features*`." 
  (member :debug *features* :test #'eq))

(defmacro when-debug (&body body)
  "Expand to BODY at compile/macroexpansion time only when `:debug` is
present in `*features*`. Otherwise expands to NIL.

This mirrors the behaviour of reader conditionals, but uses the
keyword `:debug` which aligns with the helpers below.
" 
  (if (member :debug *features* :test #'eq)
      `(progn ,@body)
      nil))

(defmacro debug-log (&rest args)
  "Compile-time gated logging helper. Expands to a `format` call when
`:debug` is present in `*features*`, otherwise to NIL.
Usage: `(debug-log "fmt~%" arg1 arg2)`" 
  (if (member :debug *features* :test #'eq)
      `(progn (format t ,@args) (finish-output))
      nil))

(defun enable-debug ()
  "Add `:debug` to `*features*`. If SYSTEM is non-nil, recompile and
load SYSTEM via ASDF so files that use compile-time gating are rebuilt
with the new feature present.

SYSTEM may be a symbol naming the ASDF system (e.g. 'mnas-sdl3-gui)."
  (unless (member :debug *features* :test #'eq)
    (push :debug *features*)))

(defun disable-debug ()
  "Remove `:debug` from `*features*`. If SYSTEM is non-nil, recompile and
load SYSTEM via ASDF so files are rebuilt without the debug feature."
  (setf *features* (remove :debug *features* :test #'eq)))

(defun toggle-debug ()
  "Toggle presence of `:debug` in `*features*`. If SYSTEM is non-nil,
recompile/load it after toggling." 
  (if (member :debug *features* :test #'eq)
      (disable-debug)
      (enable-debug)))

;;;; ./src/app/methods/print-object.lisp

(in-package :mnas-sdl3-gui/app)

(defmethod print-object ((app <app>) stream)
  (print-unreadable-object (app stream :type t :identity t)
    (format stream "title=~S width=~A height=~A style=~S open=~A status=~S"
            (<app>-title app)
            (<app>-width app)
            (<app>-height app)
            (<app>-style app)
            (<app>-open-p app)
            (<app>-status app))))

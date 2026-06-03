(progn
  (let ((file "/home/mna/quicklisp/local-projects/sdl3/mnas-sdl3-gui/src/widgets/methods/grid-layout.lisp"))
    (with-open-file (in file)
      (let ((count 0) (lineno 1))
        (loop for line = (read-line in nil nil) while line do
              (let ((opens (count #\( line)) (closes (count #\) line)))
                (incf count opens)
                (decf count closes)
                (format t "~4d: ~4d  opens=~3d closes=~3d  ~A~%" lineno count opens closes line)
                (incf lineno))))
    (sb-ext:quit)))

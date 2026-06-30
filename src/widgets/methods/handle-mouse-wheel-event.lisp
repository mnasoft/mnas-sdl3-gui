;;;; ./src/widgets/methods/handle-mouse-wheel-event.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Enable temporary debug logging for mouse-wheel events when non-NIL.
(defparameter *debug-mouse-wheel-events* nil
  "When T, log mouse-wheel event coords and list-box scroll changes to *error-output*.")

(defmethod handle-mouse-wheel-event :around ((widget <widget>) (ev sdl3:mouse-wheel-event))
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

;; Dispatch wheel events to children in hit-test order; use %mouse-x/%mouse-y
;; when available, otherwise fall back to last-known mouse position.
(defmethod handle-mouse-wheel-event ((widgets cons) (ev sdl3:mouse-wheel-event))
  "Dispatch wheel events to children in hit-test order; return the widget that consumed the event or NIL."
  (let* ((mx (ignore-errors (slot-value ev 'sdl3:%mouse-x)))
         (my (ignore-errors (slot-value ev 'sdl3:%mouse-y)))
         (fallback (and (boundp '*last-mouse-pos*) *last-mouse-pos*))
         (x (cond (mx (round mx)) (fallback (car fallback)) (t (round (slot-value ev 'sdl3:%x)))))
         (y (cond (my (round my)) (fallback (cdr fallback)) (t (round (slot-value ev 'sdl3:%y))))))
    (loop for widget in (widgets-in-hit-test-order widgets)
          when (and (visible-p widget)
                    (enabled-p widget)
                    (contains-point-p widget x y)
                    (handle-mouse-wheel-event widget ev))
            return widget
          finally (return nil))))

(defmethod handle-mouse-wheel-event ((widget <widget>) (ev sdl3:mouse-wheel-event))
  "Default per-widget wheel handler: no-op. Special widgets provide scrolling behavior."
  (declare (ignore ev))
  nil)

(defmethod handle-mouse-wheel-event ((widget <widget>) (ev t))
  "Ignore non-wheel events gracefully so demo event handlers can call this generic without errors."
  (declare (ignore widget ev))
  nil)

(defmethod handle-mouse-wheel-event ((widget <scroll-container>) (ev sdl3:mouse-wheel-event))
  "Try children first; if none consume the event, scroll the container by the vertical delta." 
    (let* ((x (round (slot-value ev 'sdl3:%x)))
      (y (round (slot-value ev 'sdl3:%y)))
      (dy (handler-case (slot-value ev 'sdl3:%yrel) (error ()
                   (handler-case (slot-value ev 'sdl3:%y) (error () 0))))))
    (when (contains-point-p widget x y)
      (loop for child in (widgets-in-hit-test-order (children widget))
            when (handle-mouse-wheel-event child ev)
              return t
            finally (return (and (not (zerop dy))
                                 (let ((old-offset (<scroll-container>-scroll-offset widget)))
                                   (setf (<scroll-container>-scroll-offset widget)
                                         (+ old-offset dy))
                                   (normalize-scroll-container-scroll-offset widget)
                                   (/= old-offset (<scroll-container>-scroll-offset widget)))))))))

(defmethod handle-mouse-wheel-event ((widget <combo-box>) (ev sdl3:mouse-wheel-event))
  "Handle mouse-wheel for combo-box popups: adjust list-box scroll offset." 
  (declare (ignore ev))
  (let* ((raw-dy (handler-case (slot-value ev 'sdl3:%yrel)
                   (error ()
                     (handler-case (slot-value ev 'sdl3:%y)
                       (error () 0)))))
         (dir (ignore-errors (slot-value ev 'sdl3:%direction)))
         (dir-flipped?
          (cond
            ((numberp dir) (= dir 1))
            ((symbolp dir) (string= (string-downcase (symbol-name dir)) "flipped"))
            (t nil)))
         (dy (if dir-flipped? (- raw-dy) raw-dy)))
    (format t "[combo-box] wheel raw=~A dir=~S dy=~A popup-id=~S~%" raw-dy dir dy
            (and (<combo-box>-popup-widget widget)
                 (<combo-box-popup>-window-id (<combo-box>-popup-widget widget))))
    (finish-output)
    (when (not (zerop dy))
      (let* ((popup (<combo-box>-popup-widget widget))
             (item-h (or (and popup (<list-box>-item-height popup)) 24))
             (old-offset (<list-box>-scroll-offset widget))
             (delta-rows (if (< (abs dy) item-h)
                             (if (> dy 0) 1 -1)
                             (round (/ dy item-h)))))
        (format t "[combo-box] old-offset=~A dy=~A item-h=~A delta-rows=~A~%" old-offset dy item-h delta-rows)
        (finish-output)
        (setf (<list-box>-scroll-offset widget)
              (+ old-offset delta-rows))
        (normalize-list-box-scroll-offset widget)
        (format t "[combo-box] new-offset=~A~%" (<list-box>-scroll-offset widget))
        (finish-output)
        (/= old-offset (<list-box>-scroll-offset widget))))))

(defmethod handle-mouse-wheel-event ((widget <list-box>) (ev sdl3:mouse-wheel-event))
  "Handle mouse-wheel for list-box: adjust scroll offset when pointer is over the widget."
  (let* ((mx (ignore-errors (slot-value ev 'sdl3:%mouse-x)))
         (my (ignore-errors (slot-value ev 'sdl3:%mouse-y)))
         (fallback (and (boundp '*last-mouse-pos*) *last-mouse-pos*))
         (x (cond (mx (round mx)) (fallback (car fallback)) (t (round (slot-value ev 'sdl3:%x)))))
         (y (cond (my (round my)) (fallback (cdr fallback)) (t (round (slot-value ev 'sdl3:%y)))))
         (raw-dy (or (ignore-errors (slot-value ev 'sdl3:%yrel))
                     (ignore-errors (slot-value ev 'sdl3:%y))
                     0))
         (dir (ignore-errors (slot-value ev 'sdl3:%direction)))
         (dir-flipped?
          (cond
            ((numberp dir) (= dir 1))
            ((symbolp dir) (string= (string-downcase (symbol-name dir)) "flipped"))
            (t nil)))
         (dy (if dir-flipped? raw-dy (- raw-dy))))
    (let ((inside (contains-point-p widget x y)))
      (when *debug-mouse-wheel-events*
        (format t "[mouse-wheel] widget=~S x=~D y=~D raw-dy=~S dir=~S dy=~S inside=~S~%" widget x y raw-dy dir dy inside))
      (when inside
        (and (not (zerop dy))
             (let* ((item-h (or (and (typep widget '<list-box>) (<list-box>-item-height widget)) 24))
                    (old-offset (<list-box>-scroll-offset widget))
                    (delta-rows (if (< (abs dy) item-h)
                                    (if (> dy 0) 1 -1)
                                    (round (/ dy item-h)))))
               (setf (<list-box>-scroll-offset widget)
                     (+ old-offset delta-rows))
               (normalize-list-box-scroll-offset widget)
               (when *debug-mouse-wheel-events*
                 (format t "[mouse-wheel] widget=~S old-offset=~D new-offset=~D delta-rows=~D~%"
                         widget old-offset (<list-box>-scroll-offset widget) delta-rows))
               (/= old-offset (<list-box>-scroll-offset widget))))))))

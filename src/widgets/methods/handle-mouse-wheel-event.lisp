;;;; ./src/widgets/methods/handle-mouse-wheel-event.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Enable temporary debug logging for mouse-wheel events when non-NIL.
(defparameter *debug-mouse-wheel-events* nil
  "When T, log mouse-wheel event coords and list-box scroll changes to *error-output*.")

(defmethod handle-mouse-wheel-event :around ((widget widget) (ev sdl3:mouse-wheel-event))
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

(defmethod handle-mouse-wheel-event ((widget widget) (ev sdl3:mouse-wheel-event))
  "Default per-widget wheel handler: no-op. Special widgets provide scrolling behavior."
  (declare (ignore ev))
  nil)

(defmethod handle-mouse-wheel-event ((widget scroll-container) (ev sdl3:mouse-wheel-event))
  "Try children first; if none consume the event, scroll the container by the vertical delta." 
  (let* ((x (round (slot-value ev 'sdl3:%x)))
         (y (round (slot-value ev 'sdl3:%y)))
         (dy (handler-case (slot-value ev 'sdl3:%yrel) (error ()
                                                          (handler-case (slot-value ev 'sdl3:%mouse-y) (error () 0))))))
    (when (contains-point-p widget x y)
      (loop for child in (widgets-in-hit-test-order (children widget))
            when (handle-mouse-wheel-event child ev)
              return t
            finally (return (and (not (zerop dy))
                                 (let ((old-offset (scroll-container-scroll-offset widget)))
                                   (setf (scroll-container-scroll-offset widget)
                                         (+ old-offset dy))
                                   (normalize-scroll-container-scroll-offset widget)
                                   (/= old-offset (scroll-container-scroll-offset widget)))))))))

(defmethod handle-mouse-wheel-event ((widget combo-box) (ev sdl3:mouse-wheel-event))
  "Handle mouse-wheel for combo-box popups: adjust list-box scroll offset." 
  (declare (ignore ev))
  (let ((dy (handler-case (slot-value ev 'sdl3:%yrel) (error ()
                                                   (handler-case (slot-value ev 'sdl3:%mouse-y) (error () 0))))))
    (when (not (zerop dy))
      (let ((old-offset (list-box-scroll-offset widget)))
        (setf (list-box-scroll-offset widget)
          (+ old-offset (round (- dy))))
        (normalize-list-box-scroll-offset widget)
        (/= old-offset (list-box-scroll-offset widget))))))

(defmethod handle-mouse-wheel-event ((widget list-box) (ev sdl3:mouse-wheel-event))
  "Handle mouse-wheel for list-box: adjust scroll offset when pointer is over the widget."
  (let* ((mx (ignore-errors (slot-value ev 'sdl3:%mouse-x)))
         (my (ignore-errors (slot-value ev 'sdl3:%mouse-y)))
         (fallback (and (boundp '*last-mouse-pos*) *last-mouse-pos*))
         (x (cond (mx (round mx)) (fallback (car fallback)) (t (round (slot-value ev 'sdl3:%x)))))
         (y (cond (my (round my)) (fallback (cdr fallback)) (t (round (slot-value ev 'sdl3:%y)))))
         (dy (or (ignore-errors (slot-value ev 'sdl3:%yrel))
                 (ignore-errors (slot-value ev 'sdl3:%y))
                 0)))
    (let ((inside (contains-point-p widget x y)))
      (when *debug-mouse-wheel-events*
        (format t "[mouse-wheel] widget=~S x=~D y=~D dy=~S inside=~S~%" widget x y dy inside))
      (when inside
        (and (not (zerop dy))
             (let ((old-offset (list-box-scroll-offset widget)))
               (setf (list-box-scroll-offset widget)
                 (+ old-offset (round (- dy))))
               (normalize-list-box-scroll-offset widget)
               (when *debug-mouse-wheel-events*
                 (format t "[mouse-wheel] widget=~S old-offset=~D new-offset=~D~%"
                         widget old-offset (list-box-scroll-offset widget)))
               (/= old-offset (list-box-scroll-offset widget))))))))

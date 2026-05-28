;;;; ./src/widgets/methods/handle-widget-mouse-wheel.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Handle mouse-wheel events (per-widget specializations live here).

(defmethod handle-widget-mouse-wheel :around ((widget widget) x y dx dy)
  "Guard so only enabled/visible widgets receive wheel events."
  (when (and (enabled-p widget) (visible-p widget))
    (call-next-method)))

(defmethod handle-widget-mouse-wheel ((widgets cons) x y dx dy)
  "Handle mouse-wheel input for a list (CONS) of widgets. Returns the
widget that consumes the event or NIL when none do."
  (loop for widget in (widgets-in-hit-test-order widgets)
        when (and (visible-p widget)
                  (enabled-p widget)
                  (contains-point-p widget x y)
                  (not (zerop dy))
                  (handle-widget-mouse-wheel widget x y dx dy))
          return widget
        finally (return nil)))

(defmethod handle-widget-mouse-wheel ((widget scroll-container) x y dx dy)
  "Try to dispatch wheel to children first; fall back to scrolling the
container itself (via `scroll-by`) when appropriate. Returns T when
the event was consumed."
  (loop for child in (widgets-in-hit-test-order (children widget))
        when (handle-widget-mouse-wheel child x y dx dy)
          return t
        finally (return (and (not (zerop dy))
                             (let ((old-offset (scroll-container-scroll-offset widget)))
                               (setf (scroll-container-scroll-offset widget)
                                     (+ old-offset dy))
                               (normalize-scroll-container-scroll-offset widget)
                               (/= old-offset (scroll-container-scroll-offset widget)))))))

(defmethod handle-widget-mouse-wheel ((widget combo-box) x y dx dy)
  "Handle mouse-wheel for combo-box popups.
When a popup is shown in a separate window the coordinates may be
relative to that popup; the implementation only needs the vertical
wheel delta `dy` to scroll the list." 
  (declare (ignore x y dx))
  (when (not (zerop dy))
    (let ((old-offset (list-box-scroll-offset widget)))
      (setf (list-box-scroll-offset widget)
            (+ old-offset (- dy)))
      (normalize-list-box-scroll-offset widget)
      (/= old-offset (list-box-scroll-offset widget)))))

;;;; ./src/widgets/mouse-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Mouse dispatch helpers

(defun dispatch-widget-mouse-down (widgets x y)
  "Dispatch mouse-down to WIDGETS and focus the widget that consumes it."
  (loop for widget in widgets
        when (and (typep widget 'combo-box)
                  (combo-box-expanded-p widget)
                  (not (contains-point-p widget x y)))
        do (progn
         (sync-combo-box-expanded-state widget nil)
         (setf (list-box-scrollbar-dragging-p widget) nil
           (list-box-scrollbar-drag-offset widget) 0)))
  (loop for widget in (widgets-in-hit-test-order widgets)
        when (handle-widget-mouse-down widget x y)
          do (set-widget-focus widgets widget)
             (return widget)
        finally (return nil)))

(defun dispatch-widget-mouse-up (widgets x y)
  "Dispatch mouse-up to WIDGETS and return the widget that consumes it."
  (loop for widget in (widgets-in-hit-test-order widgets)
        when (handle-widget-mouse-up widget x y)
          return widget
        finally (return nil)))

(defun dispatch-widget-mouse-motion (widgets x y)
  "Compatibility wrapper: dispatch mouse-motion to WIDGETS using the
generic `handle-widget-mouse-motion` method. Prefer calling the generic
directly.
Deprecated: keep for backward compatibility with older code."
  (handle-widget-mouse-motion widgets x y))

(defun dispatch-widget-mouse-wheel (widgets x y dx dy)
  "Dispatch mouse-wheel input to widgets under X/Y and return the widget that consumes it."
  (loop for widget in (widgets-in-hit-test-order widgets)
        when (and (visible-p widget)
          (enabled-p widget)
                  (contains-point-p widget x y)
                  (not (zerop dy))
                  (or (and (typep widget 'scroll-container)
                            (or (dispatch-widget-mouse-wheel
                              (children widget)
                                x y dx dy)
                             (scroll-by widget (- dy))))
                      (and (typep widget 'widget-container)
                        (dispatch-widget-mouse-wheel
                         (children widget)
                         x y dx dy))
                        (and (typep widget 'combo-box)
                          (combo-box-expanded-p widget)
                          (scroll-by widget (- dy)))
                      (and (typep widget 'tree-view)
                        (scroll-by widget (- dy)))
                        (and (typep widget 'list-box)
                          (not (typep widget 'combo-box))
                          (scroll-by widget (- dy)))))
          return widget
        finally (return nil)))


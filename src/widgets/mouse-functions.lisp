;;;; ./src/widgets/mouse-functions.lisp

(in-package :mnas-sdl3-gui/widgets)

;;; Mouse dispatch helpers

;; `dispatch-widget-mouse-down` removed: call `handle-widget-mouse-down` directly.

;; `dispatch-widget-mouse-up` removed: call `handle-widget-mouse-up` directly.

;; `dispatch-widget-mouse-motion` removed: call `handle-widget-mouse-motion` directly.

;; Converted from the old `dispatch-widget-mouse-wheel` free function to a
;; generic method. Use `handle-widget-mouse-wheel` to dispatch wheel events.
(defmethod handle-widget-mouse-wheel ((widgets cons) x y dx dy)
  "Handle mouse-wheel input for a list (CONS) of widgets. Returns the widget that consumes the event."
  (loop for widget in (widgets-in-hit-test-order widgets)
        when (and (visible-p widget)
                  (enabled-p widget)
                  (contains-point-p widget x y)
                  (not (zerop dy))
                  (or (and (typep widget 'scroll-container)
                           (or (handle-widget-mouse-wheel
                                (children widget)
                                x y dx dy)
                              (scroll-by widget (- dy))))
                      (and (typep widget 'widget-container)
                           (handle-widget-mouse-wheel
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


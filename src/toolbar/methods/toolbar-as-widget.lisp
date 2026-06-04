;;;; ./src/toolbar/methods/toolbar-as-widget.lisp

(in-package :mnas-sdl3-gui/widgets)

;; Render toolbar as a widget by delegating to presenter renderer with offset
(defmethod render ((renderer t) (tb mnas-sdl3-gui/toolbar:toolbar) style)
  (mnas-sdl3-gui/toolbar:render-toolbar tb renderer (toolbar-x tb) (toolbar-y tb)))

;; Handle mouse-button-event for toolbar: perform hit-test relative to toolbar position
(defmethod handle-mouse-button-event ((tb mnas-sdl3-gui/toolbar:toolbar) (ev sdl3:mouse-button-event))
  (let ((x (- (round (slot-value ev 'sdl3:%x)) (toolbar-x tb)))
        (y (- (round (slot-value ev 'sdl3:%y)) (toolbar-y tb))))
    (when (and (= (slot-value ev 'sdl3:%button) 1)
               (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position tb x y))
      (when (slot-value ev 'sdl3:%down)
        (mnas-sdl3-gui/toolbar:toolbar-button-clicked tb
                                                       (mnas-sdl3-gui/toolbar:toolbar-buttons-at-position tb x y)
                                                       (list :window-id (slot-value ev 'sdl3:%window-id))))
      t))

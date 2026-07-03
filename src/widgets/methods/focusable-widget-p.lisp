;;;; ./src/widgets/methods/focusable-widget-p.lisp

(in-package :mnas-sdl3-gui/widgets)

(defmethod focusable-p ((widget <widget>))
  nil)

(defmethod focusable-p ((widget <button>))
  (and (enabled-p widget)
       (visible-p widget)
       (<widget>-focusable widget)))

(defmethod focusable-p ((widget <toggle>))
  (and (enabled-p widget)
       (visible-p widget)
       (<widget>-focusable widget)))

(defmethod focusable-p ((widget <check-box>))
  (and (enabled-p widget)
       (visible-p widget)
       (<widget>-focusable widget)))

(defmethod focusable-p ((widget <entry>))
  (and (enabled-p widget)
       (visible-p widget)
       (<widget>-focusable widget)))

(defmethod focusable-p ((widget <list-box>))
  (and (enabled-p widget)
       (visible-p widget)
       (<widget>-focusable widget)))

(defmethod focusable-p ((widget <combo-box>))
  (and (enabled-p widget)
       (visible-p widget)
       (<widget>-focusable widget)))

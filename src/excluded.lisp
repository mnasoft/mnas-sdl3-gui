(in-package :mnas-sdl3-gui/widgets)

(defun combo-box-popup-visible-p (obj)
  "Compatibility accessor: return popup visible flag when OBJ is either a
  combo-box or a combo-box-popup instance. Returns NIL otherwise."
  (cond
    ((typep obj 'combo-box)
     (let ((popup (<combo-box>-popup-widget obj)))
       (and popup (slot-value popup 'visible-p))))
    ((typep obj 'combo-box-popup)
     (slot-value obj 'visible-p))
    (t nil)))

(defun combo-box-popup-renderer (obj)
  "Return popup renderer for OBJ.
If OBJ is a `combo-box`, return renderer stored on its popup; if OBJ is
a `combo-box-popup` return its renderer slot. Returns NIL otherwise."
  (cond
    ((typep obj 'combo-box)
     (let ((popup (<combo-box>-popup-widget obj)))
       (when popup (slot-value popup 'renderer))))
    ((typep obj 'combo-box-popup)
     (slot-value obj 'renderer))
    (t nil)))

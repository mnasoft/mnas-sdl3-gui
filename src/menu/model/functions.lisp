;;;; ./src/menu/model/functions.lisp

(in-package :mnas-sdl3-gui/menu/model)

(defun text-width (text)
  (* (length text) +font-char-width+))

(defun entry-row-height (entry)
  (if (typep entry 'separator-entry)
      +separator-height+
      (+ (* 2 +menu-item-pad-y+) +font-text-height+)))

(defun command-entry-content-width (entry)
  (let* ((label-w  (text-width (entry-label entry)))
         (hotkey   (entry-hotkey entry))
         (hotkey-w (if (plusp (length hotkey)) (text-width hotkey) 0))
         (gap-w    (if (> hotkey-w 0) +menu-item-gap-label-hotkey+ 0)))
    (+ label-w gap-w hotkey-w)))

(defun submenu-entry-content-width (entry)
  (+ (text-width (entry-label entry)) +submenu-arrow-width+))

(defun entry-content-width (entry)
  (cond ((typep entry 'command-entry) (command-entry-content-width entry))
        ((typep entry 'submenu-entry) (submenu-entry-content-width entry))
        ((typep entry 'separator-entry) 0)
        (t (text-width (entry-label entry)))))

(defun dropdown-panel-width (menu)
  (let ((content-max 0))
    (dolist (entry (menu-entries menu))
      (setf content-max (max content-max (entry-content-width entry))))
    (max +submenu-min-width+
         (+ (* 2 +menu-item-pad-x+) content-max))))

(defun dropdown-panel-height (menu)
  (let ((h 0))
    (dolist (entry (menu-entries menu))
      (incf h (entry-row-height entry)))
    h))

(defun layout-dropdown-recursive (menu)
  (setf (menu-title-width menu)
        (+ (* 2 +menu-title-pad-x+) (text-width (menu-title menu)))
        (menu-panel-width menu)  (dropdown-panel-width menu)
        (menu-panel-height menu) (dropdown-panel-height menu))
  (dolist (entry (menu-entries menu))
    (when (typep entry 'submenu-entry)
      (layout-dropdown-recursive (entry-submenu entry)))))

(defun layout-menu-bar (bar)
  (let ((cursor (bar-left bar)))
    (loop for menu in (bar-menus bar)
          do (layout-dropdown-recursive menu)
             (setf (menu-left menu) cursor
                   (menu-top menu)  (bar-top bar))
             (incf cursor (+ (menu-title-width menu) +menu-title-gap+)))))

(defun menu-rect-hit-p (x y left top width height)
  (and (>= x left) (< x (+ left width))
       (>= y top)  (< y (+ top height))))

(defun title-menu-index-at (bar x y)
  (loop for menu in (bar-menus bar)
        for index from 0
        when (menu-rect-hit-p x y
                              (menu-left menu) (menu-top menu)
                              (menu-title-width menu) (bar-height bar))
          do (return index)
        finally (return nil)))

(defun dropdown-item-index-at (menu panel-left panel-top x y)
  (when (menu-rect-hit-p x y panel-left panel-top
                         (menu-panel-width menu) (menu-panel-height menu))
    (let ((cursor-y panel-top))
      (loop for entry in (menu-entries menu)
            for index from 0
            for row-h = (entry-row-height entry)
            do (when (menu-rect-hit-p x y panel-left cursor-y
                                      (menu-panel-width menu) row-h)
                 (return-from dropdown-item-index-at index))
               (incf cursor-y row-h))
      nil)))

(defun submenu-panel-origin (parent-menu parent-panel-left parent-panel-top parent-entry-index)
  "Return (values sub-left sub-top) -- top-left corner of the nested panel."
  (let ((cursor-y parent-panel-top))
    (loop for entry in (menu-entries parent-menu)
          for index from 0
          do (when (= index parent-entry-index)
               (return (values (+ parent-panel-left (menu-panel-width parent-menu) -1)
                               cursor-y)))
             (incf cursor-y (entry-row-height entry)))))

(defun open-menu (bar menu-index)
  (setf (bar-open-menu-index bar)          menu-index
        (bar-hover-item-index bar)         nil
        (bar-open-submenu-entry-index bar) nil
        (bar-hover-sub-item-index bar)     nil))

(defun close-menu (bar)
  (setf (bar-open-menu-index bar)          nil
        (bar-hover-item-index bar)         nil
        (bar-open-submenu-entry-index bar) nil
        (bar-hover-sub-item-index bar)     nil))

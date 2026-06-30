;;;; ./src/events/methods/process-sdl-event/process-sdl-event.lisp

(in-package :mnas-sdl3-gui/events)

(defmethod process-sdl-event ((tracker <event-tracker>) (ev sdl3:mouse-motion-event))
  (let* ((ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (state (slot-value ev 'sdl3:%state))
         (x (slot-value ev 'sdl3:%x))
         (y (slot-value ev 'sdl3:%y))
         (xrel (slot-value ev 'sdl3:%xrel))
         (yrel (slot-value ev 'sdl3:%yrel))
         (info (make-instance '<mouse-motion-info> :timestamp ts :window-id wid
                              :which which :state state :x x :y y :xrel xrel :yrel yrel)))
    (setf (slot-value tracker 'last-type) 'mouse-motion
          (slot-value tracker 'last-motion) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker <event-tracker>) (ev sdl3:mouse-button-event))
  (let* ((button (slot-value ev 'sdl3:%button))
         (down (slot-value ev 'sdl3:%down))
         (ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (clicks (slot-value ev 'sdl3:%clicks))
         (x (slot-value ev 'sdl3:%x))
         (y (slot-value ev 'sdl3:%y))
         (info (make-instance '<mouse-button-info> :timestamp ts :window-id wid
                              :which which :button button :down down :clicks clicks :x x :y y)))
    (when down
      (pushnew button (slot-value tracker 'buttons-down)))
    (unless down
      (setf (slot-value tracker 'buttons-down)
            (remove button (slot-value tracker 'buttons-down))))
    (setf (slot-value tracker 'last-type) 'mouse-button
          (slot-value tracker 'last-button) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker <event-tracker>) (ev sdl3:mouse-wheel-event))
  (let* ((ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (x (slot-value ev 'sdl3:%x))
         (y (slot-value ev 'sdl3:%y))
         (dir (slot-value ev 'sdl3:%direction))
         (mx (slot-value ev 'sdl3:%mouse-x))
         (my (slot-value ev 'sdl3:%mouse-y))
         (info (make-instance '<mouse-wheel-info> :timestamp ts :window-id wid
                              :which which :x x :y y :direction dir :mouse-x mx :mouse-y my)))
    (setf (slot-value tracker 'last-type) 'mouse-wheel
          (slot-value tracker 'last-wheel) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker <event-tracker>) (ev sdl3:keyboard-event))
  (let* ((down (slot-value ev 'sdl3:%down))
         (ts (slot-value ev 'sdl3:%timestamp))
         (wid (slot-value ev 'sdl3:%window-id))
         (which (slot-value ev 'sdl3:%which))
         (sc (slot-value ev 'sdl3:%scancode))
         (k (slot-value ev 'sdl3:%key))
         (modv (slot-value ev 'sdl3:%mod))
         (raw (slot-value ev 'sdl3:%raw))
         (repeat (slot-value ev 'sdl3:%repeat))
         (info (make-instance '<keyboard-info> :timestamp ts :window-id wid :which which
                              :scancode sc :key k :mod modv :raw raw :down down :repeat repeat)))
    (when down
      (pushnew k (slot-value tracker 'keys-down)))
    (unless down
      (setf (slot-value tracker 'keys-down)
            (remove k (slot-value tracker 'keys-down))))
    (setf (slot-value tracker 'last-type) (if down 'key-down 'key-up)
          (slot-value tracker 'last-keyboard) info
          (slot-value tracker 'last-event) info
          (slot-value tracker 'timestamp) ts)))

(defmethod process-sdl-event ((tracker <event-tracker>) (ev t))
  (setf (slot-value tracker 'last-type) 'other))

;;;; ./src/events/methods/log-event/log-event.lisp

(in-package :mnas-sdl3-gui/events)

(defmethod log-event ((ev sdl3:mouse-motion-event))
  (format t "MOTION: ts=~a window=~a which=~a state=~a x=~,2f y=~,2f xrel=~,2f yrel=~,2f~%"
          (slot-value ev 'sdl3:%timestamp)
          (slot-value ev 'sdl3:%window-id)
          (slot-value ev 'sdl3:%which)
          (slot-value ev 'sdl3:%state)
          (slot-value ev 'sdl3:%x)
          (slot-value ev 'sdl3:%y)
          (slot-value ev 'sdl3:%xrel)
          (slot-value ev 'sdl3:%yrel)))

(defmethod log-event ((ev sdl3:mouse-button-event))
  (format t "MOUSE BUTTON: ts=~a window=~a which=~a button=~a down=~a clicks=~a x=~,2f y=~,2f buttons-down=~a~%"
          (slot-value ev 'sdl3:%timestamp)
          (slot-value ev 'sdl3:%window-id)
          (slot-value ev 'sdl3:%which)
          (slot-value ev 'sdl3:%button)
          (slot-value ev 'sdl3:%down)
          (slot-value ev 'sdl3:%clicks)
          (slot-value ev 'sdl3:%x)
          (slot-value ev 'sdl3:%y)
          (slot-value *event-tracker* 'buttons-down)))

(defmethod log-event ((ev sdl3:mouse-wheel-event))
  (format t "MOUSE WHEEL: ts=~a window=~a which=~a x=~,2f y=~,2f dir=~a mouse-x=~,2f mouse-y=~,2f~%"
          (slot-value ev 'sdl3:%timestamp)
          (slot-value ev 'sdl3:%window-id)
          (slot-value ev 'sdl3:%which)
          (slot-value ev 'sdl3:%x)
          (slot-value ev 'sdl3:%y)
          (slot-value ev 'sdl3:%direction)
          (slot-value ev 'sdl3:%mouse-x)
          (slot-value ev 'sdl3:%mouse-y)))

(defmethod log-event ((ev sdl3:keyboard-event))
  (let ((k (slot-value ev 'sdl3:%key))
        (sc (slot-value ev 'sdl3:%scancode))
        (mod (slot-value ev 'sdl3:%mod))
        (down (slot-value ev 'sdl3:%down))
        (raw (slot-value ev 'sdl3:%raw))
        (repeat (slot-value ev 'sdl3:%repeat)))
    (format t "KEY ~a: key=~a scancode=~a raw=~a down=~a repeat=~a mods=~a~%"
            (if down "DOWN" "UP") k sc raw down repeat (modifiers->list mod))))

(defmethod log-event ((ev t))
  (format t "EVENT: ~a~%" ev))

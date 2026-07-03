;;;; ./demos/dialog/combo-box/combo-box-01/application.lisp

(in-package :mnas-sdl3-gui/demos/dialog/combo-box-01)

(defclass <combo-box-01-app> (mnas-sdl3-gui/app:<application>)
  ((small-widget
    :initarg :small-widget
    :initform nil
    :accessor <combo-box-01-app>-small-widget)
   (large-widget
    :initarg :large-widget
    :initform nil
    :accessor combo-box-01-large-widget)
   (demo-status
    :initarg :demo-status
    :initform "Use mouse, arrows, PgUp/PgDown, Return and Escape."
    :accessor <combo-box-01-app>-demo-status))
  (:documentation "Application object for the combo-box demo."))

(defmethod mnas-sdl3-gui/app:initialize-application ((application <combo-box-01-app>))
  (call-next-method)
  (setf (mnas-sdl3-gui/app:app-status application)
        (or (<combo-box-01-app>-demo-status application)
            "Use mouse, arrows, PgUp/PgDown, Return and Escape."))
  application)

(defmethod mnas-sdl3-gui/app:render-application ((application <combo-box-01-app>))
  (when (and (mnas-sdl3-gui/app:app-open-p application)
             (mnas-sdl3-gui/app:app-renderer application)
             (mnas-sdl3-gui/app:app-window application))
    (sdl3:set-render-draw-color (mnas-sdl3-gui/app:app-renderer application) 240 240 240 255)
    (sdl3:render-clear (mnas-sdl3-gui/app:app-renderer application))
    (sync-command-state)
    (when (mnas-sdl3-gui/app:app-toolbar application)
      (mnas-sdl3-gui/widgets:render
       (mnas-sdl3-gui/app:app-renderer application)
       (mnas-sdl3-gui/app:app-toolbar application)
       mnas-sdl3-gui/widgets:*widget-style*))
    (let ((widgets (mnas-sdl3-gui/widgets:widgets-for-window (mnas-sdl3-gui/app:app-window application))))
      (when widgets
        (loop for widget in (mnas-sdl3-gui/widgets:widgets-in-render-order widgets)
              do (mnas-sdl3-gui/widgets:render
                  (mnas-sdl3-gui/app:app-renderer application)
                  widget
                  mnas-sdl3-gui/widgets:*widget-style*))))
    (mnas-sdl3-gui/widgets:render-text
     (mnas-sdl3-gui/app:app-renderer application)
     (mnas-sdl3-gui/app:app-status application)
     20.0 252.0 '(40 40 40 255))
    (sdl3:render-present (mnas-sdl3-gui/app:app-renderer application)))
  :continue)

(defmethod mnas-sdl3-gui/app:finalize-application ((application <combo-box-01-app>) &optional result)
  (declare (ignore result))
  (when (<combo-box-01-app>-small-widget application)
    (mnas-sdl3-gui/widgets:combo-box-disable-popup-window (<combo-box-01-app>-small-widget application)))
  (when (combo-box-01-large-widget application)
    (mnas-sdl3-gui/widgets:combo-box-disable-popup-window (combo-box-01-large-widget application)))
  (when (mnas-sdl3-gui/app:app-renderer application)
    (sdl3:destroy-renderer (mnas-sdl3-gui/app:app-renderer application)))
  (when (mnas-sdl3-gui/app:app-window application)
    (mnas-sdl3-gui/widgets:destroy-window-and-unregister (mnas-sdl3-gui/app:app-window application)))
  (mnas-sdl3-gui/widgets:cleanup-ttf)
  application)

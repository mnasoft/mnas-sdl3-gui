;;;; ./src/window-manager/classes.lisp

(in-package :mnas-sdl3-gui/window-manager)

(defclass managed-window ()
  ((id :initarg :id :accessor managed-window-id
       :documentation "SDL window id.")
   (role :initarg :role :initform :modeless :accessor managed-window-role
         :documentation "Window role: :main, :popup-menu, :tooltip, :modal, :modeless.")
   (parent-id :initarg :parent-id :initform nil :accessor managed-window-parent-id
              :documentation "Parent SDL window id for transient windows.")
   (open-p :initarg :open-p :initform t :accessor managed-window-open-p
           :documentation "Whether window is currently visible/active.")
   (z-index :initarg :z-index :initform 0 :accessor managed-window-z-index
            :documentation "Layer ordering key.")
   (payload :initarg :payload :initform nil :accessor managed-window-payload
            :documentation "Optional user payload for adapters/demos.")))

(defclass window-layer-manager ()
  ((windows :initarg :windows :initform (make-hash-table :test #'eql)
            :accessor manager-windows
            :documentation "Registry of managed-window by SDL window id.")
   (z-counter :initarg :z-counter :initform 0 :accessor manager-z-counter
              :documentation "Monotonic counter for front-most layering.")
   (modal-stack :initarg :modal-stack :initform '() :accessor manager-modal-stack
                :documentation "Modal window ids from top to bottom.")))

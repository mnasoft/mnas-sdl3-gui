;;;; ./src/window-manager/functions.lisp

(in-package :mnas-sdl3-gui/window-manager)

(defun transient-role-p (role)
  "Return T if ROLE is transient (popup/tooltip/modal/dropdown-host)."
  (member role '(:popup-menu :tooltip :modal :dropdown-host) :test #'eq))

(defun %window-descends-from-p (manager window-id ancestor-id)
  "Return T if WINDOW-ID is descendant of ANCESTOR-ID via parent-id chain."
  (loop with current = (find-window manager window-id)
        while current
        for parent-id = (managed-window-parent-id current)
        do (cond
             ((null parent-id)
              (return nil))
             ((eql parent-id ancestor-id)
              (return t))
             (t
              (setf current (find-window manager parent-id))))))

(defun %modal-stack-push (manager window-id)
  "Push WINDOW-ID to top of modal stack, ensuring uniqueness."
  (setf (manager-modal-stack manager)
        (cons window-id
              (remove window-id (manager-modal-stack manager) :test #'eql)))
  (manager-modal-stack manager))

(defun %modal-stack-remove (manager window-id)
  "Remove WINDOW-ID from modal stack if present."
  (setf (manager-modal-stack manager)
        (remove window-id (manager-modal-stack manager) :test #'eql))
  (manager-modal-stack manager))

(defun %focus-fallback-candidate (manager closing-window)
  "Pick focus fallback after CLOSING-WINDOW is closed.
Priority: active modal -> top sibling -> parent -> top-most open." 
  (let* ((closing-id (managed-window-id closing-window))
         (parent-id (managed-window-parent-id closing-window))
         (modal-id (active-modal-id manager))
         (open-ids (remove closing-id (top-open-window-ids manager) :test #'eql)))
    (or modal-id
        (when parent-id
          (loop for candidate-id in open-ids
                for candidate = (find-window manager candidate-id)
                when (and candidate
                          (eql (managed-window-parent-id candidate) parent-id))
                  do (return candidate-id)))
        (when parent-id
          (let ((parent-window (find-window manager parent-id)))
            (when (and parent-window (managed-window-open-p parent-window))
              parent-id)))
        (first open-ids))))

(defun modal-trap-active-p (manager)
  "Return T when modal stack has more than one open modal." 
  (> (length
      (loop for window-id in (manager-modal-stack manager)
            for window = (find-window manager window-id)
            when (and window
                      (managed-window-open-p window)
                      (eq (managed-window-role window) :modal))
              collect window-id))
     1))

(defun active-modal-id (manager)
  "Return current top modal window id, or NIL if none is open."
  (loop for window-id in (manager-modal-stack manager)
        for window = (find-window manager window-id)
        when (and window
                  (managed-window-open-p window)
                  (eq (managed-window-role window) :modal))
          do (return window-id)
        finally (return nil)))

(defun active-modal-window (manager)
  "Return current top modal managed window, or NIL."
  (let ((window-id (active-modal-id manager)))
    (and window-id (find-window manager window-id))))

(defun focused-window-id (manager)
  "Return focused window id if it is still registered and open." 
  (let ((window-id (manager-focused-window-id manager)))
    (when window-id
      (let ((window (find-window manager window-id)))
        (and window
             (managed-window-open-p window)
             window-id)))))

(defun focused-window (manager)
  "Return focused managed window, or NIL." 
  (let ((window-id (focused-window-id manager)))
    (and window-id (find-window manager window-id))))

(defun set-focused-window (manager window-id)
  "Set focused window with modal-aware policy.
Returns effective focused window id, or NIL if focus cannot be set." 
  (let* ((window (find-window manager window-id))
         (modal-id (active-modal-id manager))
         (effective-id (cond
                         ((or (null window)
                              (not (managed-window-open-p window)))
                          nil)
                         ((null modal-id)
                          window-id)
                         ((or (eql window-id modal-id)
                              (%window-descends-from-p manager window-id modal-id))
                          window-id)
                         (t modal-id))))
    (setf (manager-focused-window-id manager) effective-id)
    effective-id))

(defun clear-focused-window (manager)
  "Clear focused window id." 
  (setf (manager-focused-window-id manager) nil)
  nil)

(defun close-tooltips (manager &key parent-id)
  "Close open tooltip windows globally or only for PARENT-ID."
  (maphash (lambda (id window)
             (when (and (managed-window-open-p window)
                        (eq (managed-window-role window) :tooltip)
                        (or (null parent-id)
                            (eql (managed-window-parent-id window) parent-id)))
               (close-window manager id :close-children t)))
           (manager-windows manager))
  t)

(defun open-transient-window (manager window-id role parent-id &key payload)
  "Register and open a transient window of ROLE attached to PARENT-ID." 
  (register-window manager window-id role :parent-id parent-id :payload payload)
  (open-window manager window-id))

(defun open-popup (manager window-id parent-id &key payload)
  "Open a popup-menu transient window attached to PARENT-ID." 
  (open-transient-window manager window-id :popup-menu parent-id :payload payload))

(defun open-tooltip (manager window-id parent-id &key payload)
  "Open a tooltip transient window attached to PARENT-ID." 
  (open-transient-window manager window-id :tooltip parent-id :payload payload))

(defun open-dropdown-host (manager window-id parent-id &key payload)
  "Open a dropdown-host transient window attached to PARENT-ID." 
  (open-transient-window manager window-id :dropdown-host parent-id :payload payload))

(defun close-popup-tree (manager root-popup-id)
  "Close transient popup tree rooted at ROOT-POPUP-ID." 
  (close-window manager root-popup-id :close-children t))

(defun open-modal-window (manager window-id)
  "Open modal WINDOW-ID and enforce tooltip policy." 
  (close-tooltips manager)
  (open-window manager window-id))

(defun close-modal-window (manager window-id)
  "Close modal WINDOW-ID and update modal stack." 
  (close-window manager window-id :close-children t))

(defun event-target-window-id (manager requested-window-id)
  "Return effective target window id considering active modal blocking.
If REQUESTED-WINDOW-ID is blocked by active modal, route to active modal.
Returns NIL when requested window is unknown or closed." 
  (let* ((requested (find-window manager requested-window-id))
         (modal-id (active-modal-id manager)))
    (cond
      ((or (null requested)
           (not (managed-window-open-p requested)))
       nil)
      ((null modal-id)
       requested-window-id)
      ((or (eql requested-window-id modal-id)
           (%window-descends-from-p manager requested-window-id modal-id))
       requested-window-id)
      (t modal-id))))

(defun keyboard-target-window-id (manager &optional requested-window-id)
  "Return effective keyboard target window id.
When REQUESTED-WINDOW-ID is NIL, use focused window.
Modal policy always has priority over non-modal targets." 
  (let ((candidate (or requested-window-id
                       (focused-window-id manager))))
    (cond
      ((and (null candidate)
            (modal-trap-active-p manager))
       (active-modal-id manager))
      (t
       (event-target-window-id manager candidate)))))

(defun make-window-layer-manager ()
  "Create an empty window/layer manager instance."
  (make-instance 'window-layer-manager))

(defun clear-window-layer-manager (manager)
  "Clear all managed windows in MANAGER."
  (clrhash (manager-windows manager))
  (setf (manager-z-counter manager) 0
    (manager-modal-stack manager) '()
    (manager-focused-window-id manager) nil)
  manager)

(defun find-window (manager window-id)
  "Return managed window for WINDOW-ID, or NIL."
  (gethash window-id (manager-windows manager)))

(defun register-window (manager window-id role &key parent-id (open-p t) payload)
  "Register or replace managed window metadata."
  (let* ((z (incf (manager-z-counter manager)))
         (window (make-instance 'managed-window
                                :id window-id
                                :role role
                                :parent-id parent-id
                                :open-p open-p
                                :z-index z
                                :payload payload)))
    (setf (gethash window-id (manager-windows manager)) window)
    (if (and open-p (eq role :modal))
        (%modal-stack-push manager window-id)
        (%modal-stack-remove manager window-id))
    (when open-p
      (set-focused-window manager window-id))
    window))

(defun unregister-window (manager window-id)
  "Remove WINDOW-ID from manager registry."
  (%modal-stack-remove manager window-id)
  (when (eql window-id (manager-focused-window-id manager))
    (clear-focused-window manager))
  (remhash window-id (manager-windows manager)))

(defun host-window-p (manager window-id)
  "Return T when WINDOW-ID is a host or main window surface." 
  (let ((window (find-window manager window-id)))
    (and window
         (member (managed-window-role window) '(:main :host) :test #'eq))))

(defun window-root-widget (manager window-id)
  "Return the widget root payload for WINDOW-ID, or NIL." 
  (let ((window (find-window manager window-id)))
    (and window (managed-window-payload window))))

(defun window-root-widgets (manager window-id)
  "Return the root widget list for WINDOW-ID.
If payload is a single widget, wrap it in a list." 
  (let ((root (window-root-widget manager window-id)))
    (cond
      ((null root) nil)
      ((listp root) root)
      (t (list root)))))

(defun window-root-container (manager window-id)
  "Return the root container widget payload for WINDOW-ID, or NIL." 
  (window-root-widget manager window-id))

(defun window-open-p (manager window-id)
  "Return T if window exists and is marked open."
  (let ((window (find-window manager window-id)))
    (and window (managed-window-open-p window))))

(defun open-window (manager window-id)
  "Mark window as open and bring it to front."
  (let ((window (find-window manager window-id)))
    (when window
      (setf (managed-window-open-p window) t
            (managed-window-z-index window) (incf (manager-z-counter manager)))
      (when (eq (managed-window-role window) :modal)
        (%modal-stack-push manager window-id))
      (set-focused-window manager window-id)
      window)))

(defun window-children (manager parent-id &key only-open)
  "Return managed children for PARENT-ID."
  (let (result)
    (maphash (lambda (id window)
               (declare (ignore id))
               (when (eql (managed-window-parent-id window) parent-id)
                 (when (or (not only-open)
                           (managed-window-open-p window))
                   (push window result))))
             (manager-windows manager))
    (nreverse result)))

(defun close-window (manager window-id &key (close-children t))
  "Mark window as closed. Optionally close direct/recursive children."
  (let ((window (find-window manager window-id)))
    (when window
      (setf (managed-window-open-p window) nil)
      (%modal-stack-remove manager window-id)
      (when close-children
        (dolist (child (window-children manager window-id))
          (close-window manager (managed-window-id child) :close-children t)))
      (when (eql window-id (manager-focused-window-id manager))
        (let ((fallback (%focus-fallback-candidate manager window)))
          (if fallback
              (set-focused-window manager fallback)
              (clear-focused-window manager))))
      window)))

(defun close-transients-for-parent (manager parent-id)
  "Close all open transient windows attached to PARENT-ID."
  (dolist (child (window-children manager parent-id :only-open t))
    (when (or (transient-role-p (managed-window-role child))
              (eq (managed-window-role child) :modeless))
      (close-window manager (managed-window-id child) :close-children t)))
  t)

(defun top-open-window-ids (manager)
  "Return open window ids sorted from top-most to bottom-most."
  (mapcar #'managed-window-id
          (sort (loop for window being the hash-values of (manager-windows manager)
                      when (managed-window-open-p window)
                        collect window)
                #'>
                :key #'managed-window-z-index)))

(defun close-action (manager window-id)
  "Classify close behavior for WINDOW-ID based on role and parenting." 
  (let ((window (find-window manager window-id)))
    (cond
      ((null window) :unknown-window)
      ((member (managed-window-role window) '(:main :host) :test #'eq) :close-root)
      ((or (managed-window-parent-id window)
           (member (managed-window-role window)
                   '(:popup-menu :tooltip :modal)
                   :test #'eq))
       :close-transient)
      (t :close-window))))

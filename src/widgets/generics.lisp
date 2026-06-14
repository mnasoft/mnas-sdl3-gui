;;;; ./src/widgets/generics.lisp

(in-package :mnas-sdl3-gui/widgets)

(defgeneric widget-min-size (widget)
  (:documentation "Return minimal width and height for WIDGET as two values."))

(defgeneric activate-widget (widget)
  (:documentation "Activate WIDGET from keyboard focus. Returns T when handled."))

(defgeneric contains-point-p (widget x y)
  (:documentation "Return true when point X/Y is inside WIDGET bounds."))

(defgeneric visible-p (widget)
  (:documentation "Return non-NIL when WIDGET should be considered visible."))

(defgeneric enabled-p (widget)
  (:documentation "Return non-NIL when WIDGET is enabled for interaction."))

(defgeneric update-<widget>-value (widget new-value)
  (:documentation "Update WIDGET with NEW-VALUE and trigger change callbacks when needed."))

(defgeneric clear-entry-selection (widget)
  (:documentation "Clear the text selection in entry WIDGET."))

(defgeneric get-entry-selected-text (widget)
  (:documentation "Return the selected text from entry WIDGET."))

(defgeneric set-entry-selection (widget start end)
  (:documentation "Set the selection in entry WIDGET from START to END."))

(defgeneric entry-selection-anchor (widget)
  (:documentation "Return the fixed side of the current selection for WIDGET."))

(defgeneric entry-select-from-anchor (widget anchor)
  (:documentation "Update selection in WIDGET between ANCHOR and current cursor."))

(defgeneric entry-select-previous-char (widget)
  (:documentation "Extend selection in WIDGET one character to the left."))

(defgeneric entry-select-next-char (widget)
  (:documentation "Extend selection in WIDGET one character to the right."))

(defgeneric entry-select-previous-word (widget)
  (:documentation "Extend selection in WIDGET to the previous word boundary."))

(defgeneric entry-select-next-word (widget)
  (:documentation "Extend selection in WIDGET to the next word boundary."))

(defgeneric entry-select-to-start (widget)
  (:documentation "Extend selection in WIDGET to the start of the text."))

(defgeneric entry-select-to-end (widget)
  (:documentation "Extend selection in WIDGET to the end of the text."))

(defgeneric entry-inner-width (widget)
  (:documentation "Return the available pixel width for entry text content."))

(defgeneric entry-text-width-between (widget start end)
  (:documentation "Return pixel width between START and END character positions in WIDGET."))

(defgeneric entry-show-text (widget)
  (:documentation "Return display text for entry WIDGET, applying its show mask if any."))

(defgeneric entry-valid-text-p (widget text)
  (:documentation "Return T when TEXT is accepted by entry WIDGET validation or no validator is set."))

(defgeneric normalize-entry-scroll-offset (widget)
  (:documentation "Clamp and backfill WIDGET scroll offset to maximize visible text."))

(defgeneric entry-ensure-cursor-visible (widget)
  (:documentation "Adjust WIDGET scroll offset so the cursor remains visible."))

(defgeneric entry-scroll-to-start (widget)
  (:documentation "Scroll WIDGET so the beginning of the text is visible."))

(defgeneric entry-position-from-pixel (widget x)
  (:documentation "Return character position in WIDGET nearest to pixel coordinate X."))

(defgeneric entry-scroll-to-end (widget)
  (:documentation "Scroll WIDGET so the end of the text is visible."))

(defgeneric entry-copy-to-clipboard (widget)
  (:documentation "Copy selected text from entry WIDGET to the system clipboard."))

(defgeneric entry-paste-from-clipboard (widget)
  (:documentation "Paste system clipboard text into entry WIDGET."))

(defgeneric entry-delete-selection (widget)
  (:documentation "Delete selected text from entry WIDGET."))

(defgeneric entry-move-to-previous-word (widget)
  (:documentation "Move cursor to the start of the previous word in WIDGET."))

(defgeneric entry-move-to-next-word (widget)
  (:documentation "Move cursor to the start of the next word in WIDGET."))

(defgeneric entry-cursor-pixel-offset (widget)
  (:documentation "Return cursor offset in pixels for entry WIDGET."))

(defgeneric compute-text-segment-pixel-width (widget text-start text-end)
  (:documentation "Compute pixel width in WIDGET for text between TEXT-START and TEXT-END."))

(defgeneric compute-text-offset-to-position (widget text-pos)
  (:documentation "Compute pixel offset in WIDGET for TEXT-POS."))

(defgeneric entry-visible-text-width (widget)
  (:documentation "Return the available pixel width for entry WIDGET text content."))

(defgeneric entry-visible-range (widget)
  (:documentation "Return visible character range for entry WIDGET."))

;; `render-entry-text-and-cursor` removed: logic is inlined into `render` methods.

(defgeneric widget-measure (widget &optional constraints)
  (:documentation "Return preferred or minimal size for WIDGET.
Optional CONSTRAINTS can influence measurement behavior."))

(defgeneric widget-arrange (widget x y width height)
  (:documentation "Arrange WIDGET inside the rectangle defined by X/Y/WIDTH/HEIGHT."))

;; `widget-paint` removed. Call `render` directly: (render renderer widget style).

(defgeneric widget-hit-test (widget x y)
  (:documentation "Return T when point X/Y hits WIDGET.
Default behavior is based on widget bounds."))

(defgeneric set-scene (widget scene)
  (:documentation "Assign SCENE model to a canvas widget and request redraw."))

(defgeneric request-redraw (widget)
  (:documentation "Mark WIDGET to be redrawn on the next frame."))

(defgeneric set-widget-focus (widgets target)
  (:documentation "Assign keyboard focus to TARGET and clear it from the other WIDGETS."))

(defgeneric world-to-screen (widget x y &optional z)
  (:documentation "Convert world coordinates to screen coordinates for WIDGET."))

(defgeneric screen-to-world (widget x y &optional z)
  (:documentation "Convert screen coordinates to world coordinates for WIDGET."))

(defgeneric handle-viewport-resize (widget width height)
  (:documentation "Handle viewport resize events for WIDGET."))

(defmethod widget-arrange ((widget widget) x y width height)
  (place-widget widget :x x :y y :width width :height height))

(defmethod widget-arrange ((widget scroll-container) x y width height)
  (place-widget widget :x x :y y :width width :height height)
  (let ((offset (scroll-container-scroll-offset widget))
        (current-y (<widget>-y widget)))
    (dolist (child (children widget))
      (widget-arrange child (<widget>-x widget)
                     (- current-y offset)
                     (<widget>-width widget)
                     (<widget>-height child))
      (incf current-y (<widget>-height child)))))

(defmethod widget-min-size ((widget scroll-container))
  (values (<widget>-width widget)
          (max 1 (min (<widget>-height widget)
                      (scroll-container-content-height widget)))))

(defmethod widget-arrange ((widget row-stack) x y width height)
  (place-widget widget :x x :y y :width width :height height)
  (let* ((padding (row-stack-padding widget))
         (spacing (row-stack-spacing widget))
         (inner-x (+ (<widget>-x widget) padding))
         (inner-y (+ (<widget>-y widget) padding))
         (inner-w (max 1 (- width (* 2 padding))))
         (inner-h (max 1 (- height (* 2 padding))))
         (current-x inner-x))
    (dolist (child (children widget))
      (multiple-value-bind (min-w min-h) (widget-min-size child)
        (let* ((child-w (max 1 (min min-w (- (+ inner-x inner-w) current-x))))
               (child-h inner-h))
          (place-widget child :x current-x :y inner-y :width child-w :height child-h)
          (incf current-x (+ child-w spacing)))))))

(defmethod widget-min-size ((widget row-stack))
  (let ((spacing (row-stack-spacing widget))
        (padding (row-stack-padding widget))
        (total-width 0)
        (max-height 0)
        (firstp t))
    (dolist (child (children widget))
      (multiple-value-bind (child-w child-h) (widget-min-size child)
        (unless firstp
          (incf total-width spacing))
        (incf total-width child-w)
        (setf max-height (max max-height child-h))
        (setf firstp nil)))
    (values (max 1 (+ total-width (* 2 padding)))
            (max 1 (+ max-height (* 2 padding))))))

(defmethod widget-arrange ((widget column-stack) x y width height)
  (place-widget widget :x x :y y :width width :height height)
  (let* ((padding (column-stack-padding widget))
         (spacing (column-stack-spacing widget))
         (inner-x (+ (<widget>-x widget) padding))
         (inner-y (+ (<widget>-y widget) padding))
         (inner-w (max 1 (- width (* 2 padding))))
         (inner-h (max 1 (- height (* 2 padding))))
         (current-y inner-y))
    (dolist (child (children widget))
      (multiple-value-bind (min-w min-h) (widget-min-size child)
        (let ((child-w inner-w)
              (child-h (max 1 min-h)))
          (place-widget child :x inner-x :y current-y :width child-w :height child-h)
          (incf current-y (+ child-h spacing)))))))

(defmethod widget-min-size ((widget column-stack))
  (let ((spacing (column-stack-spacing widget))
        (padding (column-stack-padding widget))
        (max-width 0)
        (total-height 0)
        (firstp t))
      (dolist (child (children widget))
      (multiple-value-bind (child-w child-h) (widget-min-size child)
        (unless firstp
          (incf total-height spacing))
        (incf total-height child-h)
        (setf max-width (max max-width child-w))
        (setf firstp nil)))
    (values (max 1 (+ max-width (* 2 padding)))
            (max 1 (+ total-height (* 2 padding))))))

;; `widget-paint` method removed. Rendering is performed via `render` generic.

(defmethod widget-hit-test ((widget widget) x y)
  (contains-point-p widget x y))

(defgeneric render (renderer widget style)
  (:documentation "Render WIDGET on RENDERER using STYLE for widget-specific dispatch."))

;; Skip rendering for invisible widgets globally via an :around method.
(defmethod render :around ((renderer t) (widget widget) style)
  (when (visible-p widget)
    (call-next-method)))


(defgeneric children (widget)
  (:documentation "Return a list of child widgets for WIDGET."))

(defgeneric (setf children) (newlist widget)
  (:documentation "Set the children list for WIDGET to NEWLIST and return NEWLIST."))

(defgeneric handle-widget-click (widget x y)
  (:documentation "Compatibility helper: emulate click as mouse-down followed by mouse-up."))

;; Per-widget low-level mouse handlers removed: use event-level
;; `handle-mouse-button-event`, `handle-mouse-motion-event`,
;; `handle-mouse-wheel-event` and `handle-mouse-device-event` instead.

(defgeneric handle-widget-key-press (widget key char)
  (:documentation "Handle keyboard input for a widget. Returns T if key was handled."))

(defgeneric handle-widget-key-event (widget key char &key mods ctrl shift alt on-escape on-return)
  (:documentation
   "Handle keyboard input for WIDGET including modifier-aware bindings.
For top-level widget lists provide :mods (raw modifier mask) and optional
:on-escape/:on-return callbacks.") )

(defgeneric handle-mouse-button-event (widgets ev)
  (:documentation
   "Handle an sdl3:mouse-button-event and dispatch to widget handlers."))

(defgeneric handle-mouse-wheel-event (widgets ev)
  (:documentation
   "Handle an sdl3:mouse-wheel-event and dispatch to widget handlers."))

(defgeneric handle-mouse-motion-event (widgets ev)
  (:documentation
   "Handle an sdl3:mouse-motion-event and dispatch to widget handlers."))

(defgeneric handle-mouse-device-event (widgets ev)
  (:documentation
   "Handle an sdl3:mouse-device-event and dispatch to widget handlers.") )

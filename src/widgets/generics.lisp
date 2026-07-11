;;;; ./src/widgets/generics.lisp

(in-package :mnas-sdl3-gui/widgets)

(defgeneric widget-min-size (widget)
  (:documentation "Return minimal width and height for WIDGET as two values."))

(defgeneric activate-widget (widget)
  (:documentation "Activate WIDGET from keyboard focus. Returns T when handled."))

(defgeneric register-toggle-group-member (widget)
  (:documentation "Register WIDGET in the <toggle> group registry when it belongs to a group."))

(defgeneric select-toggle-in-group (widget)
  (:documentation "Select WIDGET and clear all other <toggle>s from the same group."))

(defgeneric contains-point-p (widget x y)
  (:documentation "Return true when point X/Y is inside WIDGET bounds."))

(defgeneric widget-content-box (widget)
  (:documentation "Return the content-box rectangle as X Y WIDTH HEIGHT for WIDGET."))

(defgeneric visible-p (widget)
  (:documentation "Return non-NIL when WIDGET should be considered visible."))

(defgeneric enabled-p (widget)
  (:documentation "Return non-NIL when WIDGET is enabled for interaction."))

(defgeneric focusable-p (widget)
  (:documentation "Return non-NIL when WIDGET participates in keyboard focus traversal."))

(defgeneric focused (widget)
  (:documentation "Return non-NIL when WIDGET currently has keyboard focus."))

(defgeneric update-<widget>-value (widget new-value)
  (:documentation "Update WIDGET with NEW-VALUE and trigger change callbacks when needed."))

(defgeneric clear-<entry>-selection (widget)
  (:documentation "Clear the text selection in <entry> WIDGET."))

(defgeneric get-<entry>-selected-text (widget)
  (:documentation "Return the selected text from <entry> WIDGET."))

(defgeneric set-<entry>-selection (widget start end)
  (:documentation "Set the selection in <entry> WIDGET from START to END."))

(defgeneric <entry>-selection-anchor (widget)
  (:documentation "Return the fixed side of the current selection for WIDGET."))

(defgeneric <entry>-select-from-anchor (widget anchor)
  (:documentation "Update selection in WIDGET between ANCHOR and current cursor."))

(defgeneric <entry>-select-previous-char (widget)
  (:documentation "Extend selection in WIDGET one character to the left."))

(defgeneric <entry>-select-next-char (widget)
  (:documentation "Extend selection in WIDGET one character to the right."))

(defgeneric <entry>-select-previous-word (widget)
  (:documentation "Extend selection in WIDGET to the previous word boundary."))

(defgeneric <entry>-select-next-word (widget)
  (:documentation "Extend selection in WIDGET to the next word boundary."))

(defgeneric <entry>-select-to-start (widget)
  (:documentation "Extend selection in WIDGET to the start of the text."))

(defgeneric <entry>-select-to-end (widget)
  (:documentation "Extend selection in WIDGET to the end of the text."))

(defgeneric <entry>-inner-width (widget)
  (:documentation "Return the available pixel width for <entry> text content."))

(defgeneric <entry>-text-width-between (widget start end)
  (:documentation "Return pixel width between START and END character positions in WIDGET."))

(defgeneric <entry>-show-text (widget)
  (:documentation "Return display text for <entry> WIDGET, applying its show mask if any."))

(defgeneric <entry>-valid-text-p (widget text)
  (:documentation "Return T when TEXT is accepted by <entry> WIDGET validation or no validator is set."))

(defgeneric normalize-<entry>-scroll-offset (widget)
  (:documentation "Clamp and backfill WIDGET scroll offset to maximize visible text."))

(defgeneric <entry>-ensure-cursor-visible (widget)
  (:documentation "Adjust WIDGET scroll offset so the cursor remains visible."))

(defgeneric <entry>-scroll-to-start (widget)
  (:documentation "Scroll WIDGET so the beginning of the text is visible."))

(defgeneric <entry>-position-from-pixel (widget x)
  (:documentation "Return character position in WIDGET nearest to pixel coordinate X."))

(defgeneric <entry>-scroll-to-end (widget)
  (:documentation "Scroll WIDGET so the end of the text is visible."))

(defgeneric <entry>-copy-to-clipboard (widget)
  (:documentation "Copy selected text from <entry> WIDGET to the system clipboard."))

(defgeneric <entry>-paste-from-clipboard (widget)
  (:documentation "Paste system clipboard text into <entry> WIDGET."))

(defgeneric <entry>-delete-selection (widget)
  (:documentation "Delete selected text from <entry> WIDGET."))

(defgeneric <entry>-move-to-previous-word (widget)
  (:documentation "Move cursor to the start of the previous word in WIDGET."))

(defgeneric <entry>-move-to-next-word (widget)
  (:documentation "Move cursor to the start of the next word in WIDGET."))

(defgeneric <entry>-cursor-pixel-offset (widget)
  (:documentation "Return cursor offset in pixels for <entry> WIDGET."))

(defgeneric compute-text-segment-pixel-width (widget text-start text-end)
  (:documentation "Compute pixel width in WIDGET for text between TEXT-START and TEXT-END."))

(defgeneric compute-text-offset-to-position (widget text-pos)
  (:documentation "Compute pixel offset in WIDGET for TEXT-POS."))

(defgeneric <entry>-visible-text-width (widget)
  (:documentation "Return the available pixel width for <entry> WIDGET text content."))

(defgeneric <entry>-visible-range (widget)
  (:documentation "Return visible character range for <entry> WIDGET."))

;; `render-<entry>-text-and-cursor` removed: logic is inlined into `render` methods.

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

(defgeneric render (renderer widget style)
  (:documentation "Render WIDGET on RENDERER using STYLE for widget-specific dispatch."))

(defgeneric children (widget)
  (:documentation "Return a list of child widgets for WIDGET."))

(defgeneric (setf children) (newlist widget)
  (:documentation "Set the children list for WIDGET to NEWLIST and return NEWLIST."))

(defgeneric handle-widget-click (widget x y)
  (:documentation "Compatibility helper: emulate click as mouse-down followed by mouse-up."))
 
;; Per-widget low-level mouse handlers removed: use event-level
;; `handle-mouse-button-event`, `handle-mouse-motion-event`,
;; `handle-mouse-wheel-event` and `handle-mouse-device-event` instead.

(defgeneric handle-keyboard-event (widget ev)
  (:documentation "Handle keyboard input for WIDGET using a normalized event object."))

(defgeneric handle-text-input-event (widget ev)
  (:documentation "Handle text input for WIDGET using the provided text payload."))

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

(defgeneric item-height (widget)
  (:documentation
   "Return per-item height for LIST-BOX or combo-box via its popup."))

;;;;

(defgeneric scrollbar-dragging-p (widget)
  (:documentation
   "Return scrollbar dragging flag for <list-box> or <combo-box> via its <popup>."))

(defgeneric scrollbar-drag-offset (widget)
  (:documentation
   "Return scrollbar drag offset for <list-box> or <combo-box> via its <popup>."))

(defgeneric (setf selected-index) (new-value widget)
  (:documentation "Set selected index for <list-box> or <combo-box> via its <popup>."))

(defgeneric (setf scrollbar-dragging-p) (new-value widget)
  (:documentation "Set scrollbar dragging flag for LIST-BOX or combo-box via its popup."))

(defgeneric (setf scrollbar-drag-offset) (new-value widget)
  (:documentation "Set scrollbar drag offset for LIST-BOX or combo-box via its popup."))

(defgeneric <combo-box-popup>-y (widget))

(defgeneric popup-width (widget))

(defgeneric popup-height (widget))

(defgeneric popup-renderer (widget))

(defgeneric popup-visible-p (widget))

(defgeneric scrollbar-geometry (widget popup-x popup-y)
  (:documentation "Return popup scrollbar geometry for WIDGET at POPUP-X/POPUP-Y."))

(defgeneric scroll-offset-from-thumb-top (widget popup-x popup-y thumb-top)
  (:documentation "Update popup scroll offset from a scrollbar thumb drag for WIDGET."))

(defgeneric host-window (widget))

(defgeneric (setf host-window) (new-value widget))

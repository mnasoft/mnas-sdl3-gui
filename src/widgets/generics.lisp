;;;; ./src/widgets/generics.lisp

(in-package :mnas-sdl3-gui/widgets)

(defgeneric widget-min-size (widget)
  (:documentation "Return minimal width and height for WIDGET as two values."))

(defgeneric activate-widget (widget)
  (:documentation "Activate WIDGET from keyboard focus. Returns T when handled."))

(defgeneric contains-point-p (widget x y)
  (:documentation "Return true when point X/Y is inside WIDGET bounds."))

(defgeneric update-widget-value (widget new-value)
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

(defgeneric render-entry-text-and-cursor (renderer widget)
  (:documentation "Render entry text, selection highlight, and cursor."))

(defgeneric widget-measure (widget &optional constraints)
  (:documentation "Return preferred or minimal size for WIDGET.
Optional CONSTRAINTS can influence measurement behavior."))

(defgeneric widget-arrange (widget x y width height)
  (:documentation "Arrange WIDGET inside the rectangle defined by X/Y/WIDTH/HEIGHT."))

(defgeneric widget-paint (renderer widget style)
  (:documentation "Paint WIDGET using RENDERER and STYLE."))

(defgeneric widget-hit-test (widget x y)
  (:documentation "Return T when point X/Y hits WIDGET.
Default behavior is based on widget bounds."))

(defmethod widget-measure ((widget widget) &optional constraints)
  (declare (ignore constraints))
  (widget-min-size widget))

(defmethod widget-arrange ((widget widget) x y width height)
  (place-widget widget :x x :y y :width width :height height))

(defmethod widget-paint ((renderer t) (widget widget) style)
  (render renderer widget style))

(defmethod widget-hit-test ((widget widget) x y)
  (contains-point-p widget x y))

(defgeneric render (renderer widget style)
  (:documentation "Render WIDGET on RENDERER using STYLE for widget-specific dispatch."))

(defgeneric handle-widget-mouse-down (widget x y)
  (:documentation "Handle mouse button press. Returns T if event was consumed."))

(defgeneric handle-widget-mouse-up (widget x y)
  (:documentation "Handle mouse button release. Returns T if event was consumed."))

(defgeneric handle-widget-key-press (widget key char)
  (:documentation "Handle keyboard input for a widget. Returns T if key was handled."))

(defgeneric handle-widget-key-event (widget key char &key ctrl shift alt)
  (:documentation "Handle keyboard input for WIDGET including modifier-aware bindings."))

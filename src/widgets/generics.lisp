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

(defgeneric clear-edit-box-selection (widget)
  (:documentation "Clear the text selection in edit-box WIDGET."))

(defgeneric get-edit-box-selected-text (widget)
  (:documentation "Return the selected text from edit-box WIDGET."))

(defgeneric set-edit-box-selection (widget start end)
  (:documentation "Set the selection in edit-box WIDGET from START to END."))

(defgeneric edit-box-selection-anchor (widget)
  (:documentation "Return the fixed side of the current selection for WIDGET."))

(defgeneric edit-box-select-from-anchor (widget anchor)
  (:documentation "Update selection in WIDGET between ANCHOR and current cursor."))

(defgeneric edit-box-select-previous-char (widget)
  (:documentation "Extend selection in WIDGET one character to the left."))

(defgeneric edit-box-select-next-char (widget)
  (:documentation "Extend selection in WIDGET one character to the right."))

(defgeneric edit-box-select-previous-word (widget)
  (:documentation "Extend selection in WIDGET to the previous word boundary."))

(defgeneric edit-box-select-next-word (widget)
  (:documentation "Extend selection in WIDGET to the next word boundary."))

(defgeneric edit-box-select-to-start (widget)
  (:documentation "Extend selection in WIDGET to the start of the text."))

(defgeneric edit-box-select-to-end (widget)
  (:documentation "Extend selection in WIDGET to the end of the text."))

(defgeneric edit-box-inner-width (widget)
  (:documentation "Return the available pixel width for edit-box text content."))

(defgeneric edit-box-text-width-between (widget start end)
  (:documentation "Return pixel width between START and END character positions in WIDGET."))

(defgeneric normalize-edit-box-scroll-offset (widget)
  (:documentation "Clamp and backfill WIDGET scroll offset to maximize visible text."))

(defgeneric edit-box-ensure-cursor-visible (widget)
  (:documentation "Adjust WIDGET scroll offset so the cursor remains visible."))

(defgeneric edit-box-scroll-to-start (widget)
  (:documentation "Scroll WIDGET so the beginning of the text is visible."))

(defgeneric edit-box-position-from-pixel (widget x)
  (:documentation "Return character position in WIDGET nearest to pixel coordinate X."))

(defgeneric edit-box-scroll-to-end (widget)
  (:documentation "Scroll WIDGET so the end of the text is visible."))

(defgeneric edit-box-copy-to-clipboard (widget)
  (:documentation "Copy selected text from edit-box WIDGET to the system clipboard."))

(defgeneric edit-box-paste-from-clipboard (widget)
  (:documentation "Paste system clipboard text into edit-box WIDGET."))

(defgeneric edit-box-delete-selection (widget)
  (:documentation "Delete selected text from edit-box WIDGET."))

(defgeneric edit-box-move-to-previous-word (widget)
  (:documentation "Move cursor to the start of the previous word in WIDGET."))

(defgeneric edit-box-move-to-next-word (widget)
  (:documentation "Move cursor to the start of the next word in WIDGET."))

(defgeneric edit-box-cursor-pixel-offset (widget)
  (:documentation "Return cursor offset in pixels for edit-box WIDGET."))

(defgeneric compute-text-segment-pixel-width (widget text-start text-end)
  (:documentation "Compute pixel width in WIDGET for text between TEXT-START and TEXT-END."))

(defgeneric compute-text-offset-to-position (widget text-pos)
  (:documentation "Compute pixel offset in WIDGET for TEXT-POS."))

(defgeneric edit-box-visible-text-width (widget)
  (:documentation "Return the available pixel width for edit-box WIDGET text content."))

(defgeneric edit-box-visible-range (widget)
  (:documentation "Return visible character range for edit-box WIDGET."))

(defgeneric render-edit-box-text-and-cursor (renderer widget)
  (:documentation "Render edit-box text, selection highlight, and cursor."))

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

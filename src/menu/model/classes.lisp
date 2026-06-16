;;;; ./src/menu/model/classes.lisp

(in-package :mnas-sdl3-gui/menu/model)

(defconstant +font-char-width+          8)
(defconstant +font-text-height+         8)
(defconstant +menu-bar-height+         30)
(defconstant +menu-title-pad-x+        16)
(defconstant +menu-title-gap+           4)
(defconstant +menu-item-pad-x+         12)
(defconstant +menu-item-pad-y+          8)
(defconstant +menu-item-gap-<label>-hotkey+ 26)
(defconstant +submenu-arrow-width+     12)
(defconstant +separator-height+        12)
(defconstant +submenu-min-width+      140)

(defclass menu-<entry> ()
  ((<label> :initarg :<label> :initform "" :accessor <entry>-<label>)))

(defclass command-<entry> (menu-<entry>)
  ((hotkey :initarg :hotkey :initform "" :accessor <entry>-hotkey)
   ;; Legacy action id, kept for backward compatibility.
   (action :initarg :action :initform :none :accessor <entry>-action)
   ;; Preferred command id used by command dispatcher.
   (command-id :initarg :command-id :initform nil :accessor <entry>-command-id)))

(defclass separator-<entry> (menu-<entry>) ())

(defclass submenu-<entry> (menu-<entry>)
  ((submenu :initarg :submenu :accessor <entry>-submenu)))

(defclass dropdown-menu ()
  ((title        :initarg :title   :accessor menu-title)
   (entries      :initarg :entries :accessor menu-entries)
   (left         :initform 0       :accessor menu-left)
   (top          :initform 0       :accessor menu-top)
   (title-width  :initform 0       :accessor menu-title-width)
   (panel-width  :initform 0       :accessor menu-panel-width)
   (panel-height :initform 0       :accessor menu-panel-height)))

(defclass menu-bar ()
  ((menus                    :initarg :menus  :accessor bar-menus)
   (left                     :initarg :left   :initform 0                :accessor bar-left)
   (top                      :initarg :top    :initform 0                :accessor bar-top)
   (width                    :initarg :width  :initform 760              :accessor bar-width)
   (height                   :initarg :height :initform +menu-bar-height+ :accessor bar-height)
   (open-menu-index          :initform nil    :accessor bar-open-menu-index)
   (hover-menu-index         :initform nil    :accessor bar-hover-menu-index)
   (hover-item-index         :initform nil    :accessor bar-hover-item-index)
   (open-submenu-<entry>-index :initform nil    :accessor bar-open-submenu-<entry>-index)
   (hover-sub-item-index     :initform nil    :accessor bar-hover-sub-item-index)))

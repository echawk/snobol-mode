;;; snobol-mode.el --- A snobol4 mode -*- lexical-binding: t -*-

;; Copyright (C) 2022-2023  Ethan Hawk
;; Copyright (C) 2012  Shae Erisson

;; Author: Ethan Hawk <ethan.hawk@valpo.edu>
;; Author: Shae Erisson <shae@ScannedInAvian.com>
;; Homepage: https://github.com/ehawkvu/snobol-mode
;; Keywords: languages
;; Package-Requires: ((emacs "24.1"))
;; Version: 1.0.0
;; License: GPLv3

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A pretty barebones snobol4 mode for Emacs.
;; Just enough to make it suck a little less.

;; developed from https://hub.darcs.net/shapr/snobolcs410w/browse/snobol-mode.el
;; who adapted it from http://claystuart.blogspot.com/2012/09/a-snobol4-major-mode-for-emacs.html
;; who got it from http://emacs-fu.blogspot.com/2010/04/creating-custom-modes-easy-way-with.html

;;; Code:

(eval-when-compile
  (require 'generic-x)
  (require 'comint))

(defconst snobol-snobol4-cmd "snobol4")
(defconst snobol-spitbol-cmd "spitbol")

(defcustom snobol-prefer-spitbol-p nil)

(defun snobol-run ()
  "Start `snobol-snobol4-cmd' via `comint-run`."
  (interactive)
  (make-comint "snobol4" snobol-snobol4-cmd))

(defun snobol-send-buffer ()
  "Sends the current buffer to *snobol4* buffer."
  (interactive)
  (let ((buff (buffer-substring-no-properties (point-min) (point-max))))
    (with-current-buffer "*snobol4*"
      (goto-char (point-max))
      (comint-send-string "*snobol4*" buff)
      (let ((pos (point)))
        (comint-send-input)
        (save-excursion
          (goto-char pos)
          (insert buff)))
      (display-buffer "*snobol4*"))))

(defvar snobol-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [?\C-c?\C-p] 'snobol-run)
    (define-key map [?\C-c?\C-b] 'snobol-send-buffer)
    (define-key map [?\C-c?\C-c] 'compile)
    map))

;;;###autoload
(define-generic-mode snobol-mode
  (list "*")                                       ;; comments
  ;; keywords
  (list "OUTPUT" "INPUT" "ANY" "ARBNO" "BREAK" "LEN" "NOTANY" "POS" "RPOS"
        "RTAB" "SPAN" "APPLY" "ARG" "ARRAY" "BACKSPACE" "CHOP" "CODE"
        "COLLECT" "CONVERT" "COPY" "DATATYPE" "DATE" "DEFINE" "DETACH"
        "DIFFER" "DUMP" "DUPL" "ENDFILE" "EQ" "EVAL" "EXP" "FIELD" "GE"
        "GT" "IDENT" "INTEGER" "ITEM" "LE" "LEQ" "LGE" "LGT" "LLE" "LLT"
        "LN" "LNE" "LOAD" "LOCAL" "LPAD" "LT" "NE" "OPSYN" "PROTOTYPE"
        "REMDR" "REPLACE" "REVERSE" "REWIND" "RPAD" "RSORT" "SEEK" "SIZE"
        "SORT" "STATEMENTS" "STOPTR" "SUBSTR" "TELL" "TRACE" "TRIM" "UNLOAD"
        "VALUE")

  '(("^\\w\\{1,8\\}"  . font-lock-warning-face)    ;; highlights labels
    (":.?[(].*[)]"    . font-lock-constant-face))  ;; highlights gotos
  '("\\.SNO$")                                     ;; file endings
  nil                                              ;; other function calls
  "A mode for Snobol4 files."                      ;; doc string
  )

;; sets the local map to 'snobol-mode-map'
;; sets compile to call snobol4 with the file-name, assuming snobol4 is in your path
(add-hook 'snobol-mode-hook
          (lambda ()
            (use-local-map snobol-mode-map)
            (set (make-local-variable 'compile-command)
                 (concat
                  ;; Check for spitbol & snobol; prefer spitbol to snobol4.
                  (if snobol-prefer-spitbol-p
                      snobol-spitbol-cmd
                    snobol-snobol4-cmd)
                  " "
                  buffer-file-name))))

(provide 'snobol-mode)
;;; snobol-mode.el ends here

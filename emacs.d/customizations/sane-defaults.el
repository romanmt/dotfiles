(require 'uniquify)

(auto-compression-mode t)
(delete-selection-mode 1)
(eldoc-mode)
(global-auto-revert-mode 1)
(global-font-lock-mode t)
(pending-delete-mode t)

;; disable some prompts
(setq confirm-nonexistent-file-or-buffer nil)
(setq kill-buffer-query-functions
  (remq 'process-kill-buffer-query-function
         kill-buffer-query-functions))

;; smooth scroll
(require 'smooth-scrolling)

;; move thru camelCaseWords
(global-subword-mode 1)

;; cycle window layouts [C-c <- / C-c ->]
(when (fboundp 'winner-mode) (winner-mode 1))

;; saner windows
(setq split-height-threshold 0)
(setq split-width-threshold 0)

(setq auto-revert-verbose nil
      delete-selection-mode 1
      echo-keystrokes 0.1
      eval-expression-print-level nil
      global-auto-revert-non-file-buffers t
      shift-select-mode nil
      uniquify-buffer-name-style 'forward
      x-select-enable-clipboard t)

(put 'downcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

;; message buffer size
(setq message-log-max 10000)

;; utf-8
(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; show active region
(transient-mark-mode 1)
(make-variable-buffer-local 'transient-mark-mode)
(put 'transient-mark-mode 'permanent-local t)
(setq-default transient-mark-mode t)

;; ediff
(setq ediff-diff-options "-w")
(setq ediff-split-window-function 'split-window-horizontally)
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

(put 'erase-buffer 'disabled nil)

;; when popping the mark, continue popping until the cursor actually moves
;; if the last command was a copy - skip past expand-region
(defadvice pop-to-mark-command (around ensure-new-position activate)
  (let ((p (point)))
    (when (eq last-command 'save-region-or-current-line)
      ad-do-it
      ad-do-it
      ad-do-it)
    (dotimes (i 10)
      (when (= p (point)) ad-do-it))))

(provide 'sane-defaults)

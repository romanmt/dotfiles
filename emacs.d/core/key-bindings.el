(defun prefix-key (key)
  (global-unset-key (read-kbd-macro key))
  (define-prefix-command (intern (concat key "-map")))
  (global-set-key (read-kbd-macro key) (intern (concat key "-map"))))

;; Search
(global-set-key (kbd "C-c s") 'ag-project)
(global-set-key (kbd "C-c S") 'isearch-forward)
(global-set-key (kbd "C-c f") 'fiplr-find-file)
(global-set-key (kbd "C-c F") 'find-file)
(global-set-key (kbd "C-c -") 'fiplr-clear-cache)

;; buffers
(global-set-key (kbd "C-c w") 'clean-and-save-buffer)
(global-set-key (kbd "C-c b") 'ibuffer)
(global-set-key (kbd "C-c C-c") 'switch-to-previous-buffer)

;; windows
(global-set-key (kbd "C-c o") 'switch-window)
(global-set-key (kbd "C-c m") (make-repeatable-command 'shrink-window-horizontally))
(global-set-key (kbd "C-c ,") (make-repeatable-command 'enlarge-window-horizontally))
(global-set-key (kbd "C-c .") (make-repeatable-command 'shrink-window))
(global-set-key (kbd "C-c /") (make-repeatable-command 'enlarge-window))

;; editing
(global-set-key (kbd "C-c C-u") (make-repeatable-command 'undo))
(global-set-key (kbd "C-c C-r") (make-repeatable-command 'redo))
(global-set-key (kbd "C-c i") 'change-inner)
(global-set-key (kbd "C-c C-i") 'change-outer)
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)
(global-set-key (kbd "C-c C-m") 'mc/edit-lines)

(global-set-key (kbd "C-c [") (make-repeatable-command 'er/expand-region))
(global-set-key (kbd "C-c ]") (make-repeatable-command 'er/contract-region))

;; terminal
(global-set-key (kbd "C-c t") 'multi-term)
(global-set-key (kbd "C-c T") 'multi-term-next)

;; movement
(global-set-key (kbd "C-c l") 'goto-line-with-feedback)
(global-set-key [remap goto-line] 'goto-line-with-feedback)

;; git
(global-set-key (kbd "C-c g") 'magit-status)

;; project drawer
(global-set-key (kbd "C-c n") 'sr-speedbar-toggle)

;; docs
(global-set-key (kbd "C-c d") 'dash-at-point)

;; org-pomodoro
(global-set-key (kbd "C-c p") 'org-pomodoro)

(provide 'key-bindings)

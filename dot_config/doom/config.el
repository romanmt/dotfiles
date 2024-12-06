(setq doom-theme 'doom-solarized-light
      doom-font (font-spec :famly "Victor Mono" :size 16 )
      doom-big-font (font-spec :family "Victor Mono" :size 24))

(setq display-line-numbers-type t)

(setq
 projectile-project-search-path '("~/Workspace/"))

(after! org

  (add-hook 'org-after-refile-insert-hook #'org-save-all-org-buffers)

  (setq org-log-done 'time)

  (setq org-agenda-block-separator 8411)

  (setq org-agenda-hide-tags-regexp ".*")



;; Custom styles for dates in agenda
(custom-set-faces!
  '(org-agenda-date :inherit outline-1 :height 1.15)
  '(org-agenda-date-today :inherit outline-2 :height 1.15)
  '(org-agenda-date-weekend :inherit outline-1 :height 1.15)
  '(org-agenda-date-weekend-today :inherit outline-2 :height 1.15)
  '(org-super-agenda-header :inherit custom-button :weight bold :height 1.05)
  `(link :foreground unspecified :underline nil :background ,(nth 1 (nth 7 doom-themes--colors)))
  '(org-link :foreground unspecified))

  ;; Enable org-modern mode for Org buffers
  (use-package! org-modern
    :hook
    (org-mode . org-modern-mode)
    :config
    ;; Optional: Customize appearance
    (setq org-modern-star ["◉" "○" "●" "◆" "▶"]
          org-modern-list '((?- . "•") (?+ . "‣") (?* . "◦"))
          org-modern-priority '((?A . "[A]") (?B . "[B]") (?C . "[C]"))
          org-modern-todo-faces
          '(("TODO" . "red")
            ("DONE" . "green")
            ("IN-PROGRESS" . "yellow"))))

  (setq org-agenda-category-icon-alist
      `(
        ("home" ,(list (all-the-icons-faicon "home" :height 0.9 :v-adjust 0.005)) nil nil :ascent center)
        ("work" ,(list (all-the-icons-faicon "building" :height 0.9 :v-adjust 0.005)) nil nil :ascent center)
        ("computer" ,(list (all-the-icons-faicon "laptop" :v-adjust 0.01)) nil nil :ascent center)
        ("errands" ,(list (all-the-icons-faicon "car" :height 0.9 :v-adjust 0.005)) nil nil :ascent center)
        ("phone" ,(list (all-the-icons-faicon "phone" :height 0.9 :v-adjust 0.005)) nil nil :ascent center)
   ))


  (setq org-agenda-prefix-format '(
 (agenda . "  %?-2i %s %t")
 (todo . " %?-3i  ")
 (tags . " %i %-12:c")
 (search . " %i %-12:c")))

;; Optional: Enable for agenda
(add-hook 'org-agenda-finalize-hook #'org-modern-agenda)

  (setq org-agenda-files
      '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org"
        "~/Library/Mobile Documents/com~apple~CloudDocs/org/someday.org"
        "~/Library/Mobile Documents/com~apple~CloudDocs/org/projects.org"))

  (setq org-refile-targets
      '(("~/Library/Mobile Documents/com~apple~CloudDocs/org/projects.org" :maxlevel . 2)  ;; Refile to headings up to level 2 in projects.org
        ("~/Library/Mobile Documents/com~apple~CloudDocs/org/someday.org" :maxlevel . 2)
        ("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org" :level . 1)
        ("~/Library/Mobile Documents/com~apple~CloudDocs/org/inbox.org" :level . 1)))    ;; Refile to level 1 headings in someday.org

(setq org-capture-templates
      '(("t" "Todo" entry
         (file+headline "~/Library/Mobile Documents/com~apple~CloudDocs/org/inbox.org" "Tasks")
         "* TODO %?\n  %i\n  %a")

        ("o" "One-on-One Meeting Topic" entry
         (file+headline "~/Library/Mobile Documents/com~apple~CloudDocs/org/one-on-ones.org" "Topics")
         "* [ ] %?\n  %i\n  Added: %U")

        ("p" "Project" entry
         (file+headline "~/Library/Mobile Documents/com~apple~CloudDocs/org/projects.org" "Active Projects")
         "* %? :project:\n  %i\n  Created: %U")))

  (setq org-agenda-custom-commands
      '(("i" "Inbox"
         todo ""
         ((org-agenda-files
           '("~/Library/Mobile Documents/com~apple~CloudDocs/org/inbox.org"))
          (org-agenda-overriding-header "Inbox Items")))

        ("n" "Next Items"
         todo ""
         ((org-agenda-files
           '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org"))
          (org-agenda-overriding-header "Next Actions")))

        ("W" "Next @work"
         ((agenda ""
                  ((org-agenda-span 'week)
                   (org-agenda-overriding-header "Weekly Agenda")))

         (tags-todo "@work"
         ((org-agenda-files '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org"))
          (org-agenda-override-header "Next Actions @Work")))))

        ("d" "Daily Agenda"
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-files '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org")
                      (org-agenda-override-header "Next Actions @Work")
                      (org-deadline-warning-days 7))))
          (todo ""
                     ((org-agenda-overriding-header "Tasks Without Due or Scheduled Dates")
                      (org-agenda-files '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org")
                  agenda-sorting-strategy '(priority-down)
                      (org-agenda-skip-function
                       '(org-agenda-skip-entry-if 'scheduled 'deadline)))))))

        ("w" "Weekly Agenda"
         ((agenda "" ((org-agenda-span 'week)
                      (org-agenda-files '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org")
                (org-agenda-override-header "Next Actions @Work")
                      (org-deadline-warning-days 7))))
          (todo ""
                     ((org-agenda-overriding-header "Tasks Without Due or Scheduled Dates")
                      (org-agenda-files '("~/Library/Mobile Documents/com~apple~CloudDocs/org/next.org")
                      (org-agenda-sorting-strategy '(priority-down)
                      (org-agenda-skip-function
                       '(org-agenda-skip-entry-if 'scheduled 'deadline))))))))

        ("o" "One-on-Ones"
         ((tags-todo ""
                     ((org-agenda-files
                       '("~/Library/Mobile Documents/com~apple~CloudDocs/org/one-on-ones.org"))
                      (org-agenda-overriding-header "Open Topics")
                      ))

          (tags ""
                ((org-agenda-files
                  '("~/Library/Mobile Documents/com~apple~CloudDocs/org/one-on-ones.org"))
                 (org-agenda-overriding-header "Completed Topics")
                 (org-agenda-skip-function
                  '(org-agenda-skip-entry-if 'notregexp "\\[X\\]"))
                 ))))


        ("p" "Planning"
         ((todo ""
         ((org-agenda-files
           '("~/Library/Mobile Documents/com~apple~CloudDocs/org/projects.org"))
          (org-agenda-overriding-header "Projects")))
         (todo ""
         ((org-agenda-files
           '("~/Library/Mobile Documents/com~apple~CloudDocs/org/someday.org"))
          (org-agenda-overriding-header "Someday")))
    (tags-todo "-{.*}"
                     ((org-agenda-overriding-header "Untagged Tasks")))
    (todo "" ((org-agenda-files '("~/Library/Mobile Documents/com~apple~CloudDocs/org/inbox.org"))
                      (org-agenda-overriding-header "Unprocessed Inbox Items")))))

        ("s" "Someday"
         todo ""
         ((org-agenda-files
           '("~/Library/Mobile Documents/com~apple~CloudDocs/org/someday.org"))
          (org-agenda-overriding-header "Someday Maybe")))))

)

(after! org-roam
  (setq org-roam-directory (file-truename "~/Library/Mobile Documents/com~apple~CloudDocs/.hidden/roamnotes"))

  (setq org-roam-dailies-directory (file-truename "~/Library/Mobile Documents/com~apple~CloudDocs/.hidden/daily"))

  ;; If you're using a vertical completion framework, you might want a more informative completion interface
  (setq org-roam-node-display-template
        (concat "${title:*} "
                (propertize "${tags:10}" 'face 'org-tag)))

    ;; Define the capture templates
  (setq org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+date: %U\n")
           :unnarrowed t)
          ("p" "project" plain
           "* Goals\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Notes\n\n"
           :if-new (file+head "projects/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: Projects\n")
           :unnarrowed t)
          ("o" "opportunity" plain
           "* Challenge\n\n%?\n\n* Proposal\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Notes\n\n"
           :if-new (file+head "opportunites/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: Opportunities\n")
           :unnarrowed t)
          ("m" "meeting" plain
           "* Meeting\n\n%?\n\n* Description\n\n%?\n\n* Tasks\n\n** TODO Add initial tasks\n\n* Notes\n\n"
           :if-new (file+head "meeting/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+category: Meetings\n")
           :unnarrowed t)
          ("r" "reference" plain
           "* ${title}\n\n%?"
           :if-new (file+head "references/%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n")
           :unnarrowed t)))

  (setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "* Today's Items\n\n** TODO %?\n\n* Today's Notes\n\n**\n"
         :if-new (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d>\n"))))
  (map! :leader
        :prefix "n"
        :desc "Toggle Org-roam buffer" "l" #'org-roam-buffer-toggle
        :desc "Find Org-roam node" "f" #'org-roam-node-find
        :desc "Show Org-roam graph" "g" #'org-roam-graph
        :desc "Insert Org-roam node" "i" #'org-roam-node-insert
        :desc "Capture a project note" "p" (lambda () (interactive) (org-roam-capture nil "p"))
        :desc "Capture an opportunity note" "o" (lambda () (interactive) (org-roam-capture nil "o"))
        :desc "Capture to Org-roam" "c" #'org-roam-capture
        :desc "Capture today's daily note" "j" #'org-roam-dailies-capture-today)

  (org-roam-db-autosync-mode))

(use-package! org-auto-tangle
  :defer t
  :hook (org-mode . org-auto-tangle-mode)
  :config
  (setq org-auto-tangle-default t))

(use-package! copilot
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)))

;; Set the initial frame size and position
(setq initial-frame-alist
      '((width . 140)  ;; Width in characters
        (height . 48)  ;; Height in characters
        (left . 50)    ;; Distance from left edge of the screen in pixels
        (top . 50)))   ;; Distance from top edge of the screen in pixels

;; Set the default frame size and position for new frames
(setq default-frame-alist
      '((width . 140)
        (height . 48)
        (left . 50)
        (top . 50)))



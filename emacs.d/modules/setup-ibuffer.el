(require 'ibuf-ext)

(autoload 'ibuffer "ibuffer" "List buffers." t)

(setq ibuffer-saved-filter-groups
      '(("home"
         ("rb" (mode . ruby-mode))
         ("js" (mode . js2-mode))
         ("web" (or (mode . jade-mode)
                    (mode . sws-mode)
                    (mode . haml-mode)))
         ("clj" (mode . clojure-mode))
         ("org" (or (mode . org-mode)
                    (filename . "OrgMode")))
         ("dired" (mode . dired-mode))
         ("magit" (name . "\*magit"))
         ("term" (name . "terminal"))
         ("emacs" (or
                   (name . "^\\*scratch\\*$")
                   (name . "^\\*Messages\\*$")))
         ("emacs-config" (or (filename . ".emacs.d")
                             (filename . "emacs-config")))
         ("help" (or (name . "\*Help\*")
                     (name . "\*Apropos\*")
                     (name . "\*info\*"))))))

(add-hook 'ibuffer-mode-hook
          '(lambda ()
             (ibuffer-auto-mode 1)
             (ibuffer-switch-to-saved-filter-groups "home")))

(provide 'setup-ibuffer)

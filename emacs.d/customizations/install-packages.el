
(defun init--install-packages ()
  (packages-install
   (cons 'paredit melpa)
   (cons 'clojure-mode melpa)
   (cons 'clojure-mode-extra-font-locking melpa)
   (cons 'cider melpa)
   (cons 'ido-ubiquitous melpa)
   (cons 'smex melpa)
   (cons 'all-the-icons melpa)
   (cons 'neotree melpa)
   (cons 'rainbow-delimiters melpa)
   (cons 'tagedit melpa)
   (cons 'magit melpa)
   (cons 'smooth-scrolling melpa)))

(condition-case nil
    (init--install-packages)
  (error
   (package-refresh-contents)
   (init--install-packages)))

(provide 'install-packages)

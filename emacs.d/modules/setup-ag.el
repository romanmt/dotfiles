(setq ag-highlight-search t)
(setq ag-reuse-window 't)
(setq ag-reuse-buffers 't)

(setq ag-arguments
      (list "--ignore" "bower_components" "--ignore" "node_modules" "--ignore" "vendor" "--ignore" "public"
            "--color" "--smart-case" "--nogroup" "--column" "--"))

(provide 'setup-ag)

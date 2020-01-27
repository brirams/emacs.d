(require 'init-company)

;; Things you're going to need:
;; go get -u github.com/rogpeppe/godef
;; go get -u golang.org/x/lint/golint
;; go get -u golang.org/x/tools/cmd/godoc

(when (maybe-require-package 'go-mode)
  (add-hook 'before-save-hook #'gofmt-before-save)
  (add-hook 'go-mode-hook 'flycheck-mode)
  (setq compile-command "go test -v ./...")
  (local-set-key (kbd "M-.") 'godef-jump)
  (local-set-key (kbd "M-*") 'pop-tag-mark)

  (require-package `company-go)
  (global-set-key (kbd "\C-c\C-c") 'compile)
  (add-hook 'go-mode-hook 'company-mode))

(provide 'init-go)

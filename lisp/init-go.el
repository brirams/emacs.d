;; Things you're going to need:
;; go get github.com/rogpeppe/godef
;; go get -u github.com/golang/lint/golint
;; go get -u golang.org/x/tools/cmd/godoc

;; (when (maybe-require-package 'go-mode)
;;   (add-hook 'before-save-hook #'gofmt-before-save)
;;   (add-hook 'go-mode-hook 'flycheck-mode)
;;   (setq compile-command "go test -v ./...")

;;   (require-package `company-go)
;;   (global-set-key (kbd "\C-c\C-c") 'compile)
;;   (add-hook 'go-mode-hook 'company-mode))

;; (after-load 'go-mode
;;   (define-key go-mode-map (kbd "M-.") 'godef-jump)
;;   (define-key go-mode-map (kbd "M-*") 'pop-tag-mark))

(provide 'init-go)

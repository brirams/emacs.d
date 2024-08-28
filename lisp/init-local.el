;; copy shit into osx clipboard
;; TODO: maybe we should only do this for macosx(yes -- we should)
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

(setq interprogram-cut-function 'paste-to-osx)
(setq interprogram-paste-function 'copy-from-osx)

(global-set-key (kbd "M-j") 'windmove-left)
(global-set-key (kbd "M-k") 'windmove-right)

;; jury's still out on whether this is a good idea
(setq make-backup-files nil)
(setq-default fill-column 100)

(require 'init-go)
(require 'init-treemacs)
(require-package 'jsonnet-mode)

(require-package 'smooth-scrolling)
(smooth-scrolling-mode 1)
(setq smooth-scroll-margin 5)

(require-package 'nerd-icons)

(require-package 'doom-modeline)
(doom-modeline-mode 1)
(setq doom-modeline-buffer-file-name-style 'relative-from-project)

(require-package 'doom-themes)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled
(load-theme 'doom-tomorrow-night t)
;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)
;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

(provide 'init-local)
;;; init-local.el ends here

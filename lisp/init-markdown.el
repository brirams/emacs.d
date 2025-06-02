;;; init-markdown.el --- Markdown support -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'markdown-mode)
  (add-auto-mode 'markdown-mode "\\.md\\.html\\'")
  (add-hook 'markdown-mode-hook 'turn-on-auto-fill))

(provide 'init-markdown)
;;; init-markdown.el ends here

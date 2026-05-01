;;; init-graphql.el --- GraphQL mode config -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'graphql-mode)
  (add-to-list 'auto-mode-alist '("\\.graphqls?\\'" . graphql-mode)))

(provide 'init-graphql)
;;; init-graphql.el ends here

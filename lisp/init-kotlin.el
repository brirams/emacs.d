;;; init-kotlin.el --- Kotlin support -*- lexical-binding: t -*-
;;; Commentary:

;; `kotlin-ts-mode' rather than `kotlin-mode'.  The tree-sitter mode is the one
;; still being worked on (2026-08 vs 2023-01 for kotlin-mode), and the kotlin
;; grammar is already installed here.
;;
;; Unlike `bazel', this package registers no `auto-mode-alist' entries of its
;; own, so the extensions are wired up below.
;;
;; The mode wraps its whole body in `(treesit-ready-p 'kotlin)'.  On a machine
;; without the grammar a .kt file therefore opens as a plain `prog-mode' buffer
;; -- no font-lock or indentation, but no error either.  Install the grammar
;; there with `M-x treesit-install-language-grammar'.

;;; Code:

(when (maybe-require-package 'kotlin-ts-mode)
  (add-to-list 'auto-mode-alist '("\\.kts?\\'" . kotlin-ts-mode)))

(provide 'init-kotlin)
;;; init-kotlin.el ends here

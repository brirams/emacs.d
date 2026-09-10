;;; init-corfu.el --- Interactive completion in buffers -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; WAITING: haskell-mode sets tags-table-list globally, breaks tags-completion-at-point-function
;; TODO Default sort order should place [a-z] before punctuation

(setq tab-always-indent 'complete)
(when (maybe-require-package 'orderless)
  (with-eval-after-load 'vertico
    (require 'orderless)
    (setq completion-styles '(orderless basic))))
(setq completion-category-defaults nil
      completion-category-overrides nil)
(setq completion-cycle-threshold 4)

(when (maybe-require-package 'corfu)
  (setq-default corfu-auto t)
  (with-eval-after-load 'eshell
    (add-hook 'eshell-mode-hook (lambda () (setq-local corfu-auto nil))))
  (setq-default corfu-quit-no-match 'separator)

  ;; Keep what I typed unless I pick a candidate on purpose.  The defaults are
  ;; `corfu-preselect' = valid and `corfu-preview-current' = insert: together
  ;; they select the *first candidate* whenever the typed prefix is not itself a
  ;; candidate, and write it into the buffer on further input.  So RET commits a
  ;; word you never chose, which bites hardest in prose where every word is a
  ;; prefix of something.  `prompt' selects your own input instead; M-n or the
  ;; down arrow picks a real candidate.
  (setq-default corfu-preselect 'prompt)
  (setq-default corfu-preview-current nil)
  (add-hook 'after-init-hook 'global-corfu-mode)



  (with-eval-after-load 'corfu
    (corfu-popupinfo-mode))

  ;; Make Corfu also work in terminals, without disturbing usual behaviour in GUI.
  ;; Emacs 31 does this natively and corfu-terminal warns that it is not needed.
  (when (and (< emacs-major-version 31)
             (maybe-require-package 'corfu-terminal))
    (with-eval-after-load 'corfu
      (corfu-terminal-mode)))

  ;; TODO: https://github.com/jdtsmith/kind-icon
  )


(provide 'init-corfu)
;;; init-corfu.el ends here

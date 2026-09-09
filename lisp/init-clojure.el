;;; init-clojure.el --- Clojure support -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; See also init-clojure-cider.el

(when (or (maybe-require-package 'clojure-ts-mode)
          (maybe-require-package 'clojure-mode))
  (require-package 'cljsbuild-mode)
  ;; elein is no longer in any configured archive; soft-fail rather than
  ;; aborting the rest of init.
  (maybe-require-package 'elein)

  (with-eval-after-load 'clojure-mode
    (dolist (m '(clojure-mode-hook clojure-ts-mode-hook))
      (add-hook m 'sanityinc/lisp-setup))))


(provide 'init-clojure)
;;; init-clojure.el ends here

;;; init-projectile.el --- Use Projectile for navigation within projects -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'projectile)
  (add-hook 'after-init-hook 'projectile-mode)

  ;; Shorter modeline
  (setq-default projectile-mode-line-prefix " Proj")

  (when (executable-find "rg")
    (setq-default projectile-generic-command "rg --files --hidden -0"))

  ;; Cache the project file list.  Caching defaults to
  ;; `(eq projectile-indexing-method 'native)', and the method is `alien' on
  ;; macOS, so out of the box nothing is cached and every fuzzy-find re-runs the
  ;; indexing command.  In treehouse that command is a ~680k-file `fd' walk
  ;; costing about 7s, paid on every invocation.  Cached, the repeat cost is 0s.
  ;;
  ;; Expire hourly rather than never.  A stale list is a silent failure: a file
  ;; exists and simply cannot be found.  An hour bounds that to one re-index,
  ;; and `projectile-invalidate-cache' (C-c p i) still forces a refresh after a
  ;; pull that adds files.
  ;;
  ;; Deliberately `t' and not `persistent': `projectile-cache-file' is relative
  ;; to the project root, so persistent caching would drop a
  ;; .projectile-cache.eld inside every repo it touches.
  (setq-default projectile-enable-caching t)
  (setq-default projectile-files-cache-expire 3600)

  (with-eval-after-load 'projectile
    (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

  (maybe-require-package 'ibuffer-projectile))


(provide 'init-projectile)
;;; init-projectile.el ends here

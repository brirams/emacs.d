;;; init-treemacs.el --- Setup treemacs  -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

(when (maybe-require-package 'treemacs)
  (require-package 'treemacs-projectile)
  (require-package 'treemacs-nerd-icons)
  (use-package treemacs-nerd-icons
    :config
    (treemacs-load-theme "nerd-icons"))

  )

(provide 'init-treemacs)
;;; init-treemacs.el ends here

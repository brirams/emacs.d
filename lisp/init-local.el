;;; init-local.el --- Machine-local overrides  -*- lexical-binding: t; -*-
;; copy shit into osx clipboard
;; TODO: maybe we should only do this for macosx(yes -- we should)
(defun copy-from-osx ()
  (shell-command-to-string "pbpaste"))

(defun paste-to-osx (text &optional push)
  (let ((process-connection-type nil))
    (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
      (process-send-string proc text)
      (process-send-eof proc))))

;; Only hijack the clipboard when both helpers exist.  Some Linux hosts ship a
;; pbcopy shim without a matching pbpaste, which is the worse of the two
;; failures: the cut direction appears to work, while the paste direction hands
;; Emacs the shell's "command not found" text on every yank.
(when (and (executable-find "pbcopy") (executable-find "pbpaste"))
  (setq interprogram-cut-function 'paste-to-osx)
  (setq interprogram-paste-function 'copy-from-osx))

(global-set-key (kbd "M-j") 'windmove-left)
(global-set-key (kbd "M-k") 'windmove-right)

;; Free C-\ for herdr's prefix.  Emacs binds it to `toggle-input-method', which
;; is a bad key to hit by accident: it changes what your keystrokes insert and
;; the only hint is a mode-line indicator.  herdr is a terminal workspace
;; manager running outside Emacs, so it takes the key first -- this is for the
;; stray keystroke that leaks through, and for an Emacs started outside a herdr
;; session.
(global-unset-key (kbd "C-\\"))

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

;; The theme itself is declared in init-themes.el as `bramos/theme'; loading it
;; here as well is what left two themes enabled at once.
;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)
;; Corrects (and improves) org-mode's native fontification.
(doom-themes-org-config)

;; Brighten comments: doom-tomorrow-night's default comment colour is too dim
;; against the dark background. Override via the high-priority `user' theme so
;; it wins over whatever theme is active, and reattach it after theme reloads
;; (the `dark'/`light' toggles call `reapply-themes', which would otherwise
;; clobber it). Dial brighter toward "#bcc4d2" or back toward "#8a92a3" to taste.
(defun bramos/brighten-comments ()
  "Raise the contrast of comment faces against the dark background."
  (custom-set-faces
   '(font-lock-comment-face ((t (:foreground "#aab3c5"))))
   '(font-lock-comment-delimiter-face ((t (:foreground "#aab3c5"))))))
(bramos/brighten-comments)
(advice-add 'reapply-themes :after #'bramos/brighten-comments)

(defun ask-before-closing ()
  "Useful to be used in emacsclient to avoid accident exit of Emacs like 'Save desktop?'.
This is tested in terminal Emacs!"
  (interactive)
  (if (y-or-n-p (format "You sure, bruh? "))
      (message "Canceled frame close!")
    (save-buffers-kill-terminal)))

(when (daemonp)
  (global-set-key (kbd "C-x C-c") 'ask-before-closing))
(provide 'init-local)
;;; init-local.el ends here

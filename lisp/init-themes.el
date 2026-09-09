;;; init-themes.el --- Defaults for themes -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(require-package 'color-theme-sanityinc-solarized)
(require-package 'color-theme-sanityinc-tomorrow)
(require-package 'doom-themes)

;; Don't prompt to confirm theme safety. This avoids problems with
;; first-time startup on Emacs > 26.3.
(setq custom-safe-themes t)

;; doom-themes reads these while the theme loads, so set them before
;; `reapply-themes' runs.
(setq doom-themes-enable-bold t
      doom-themes-enable-italic t)

(defvar bramos/theme 'doom-tomorrow-night
  "The single custom theme this config enables.
This is the one place the theme is chosen.  `reapply-themes' deliberately
does not read `custom-enabled-themes' to decide what to enable: that
variable is also written by `custom.el' and by every `load-theme' call, so
reading it back is how a second theme creeps in.")

;; Ensure the theme is applied even if it has not been customized
(defun reapply-themes ()
  "Enable `bramos/theme', and disable every other theme.
Exactly one theme stays enabled.  Two complete themes enabled at once have
their face specs merged, and doom-themes together with
color-theme-sanityinc-tomorrow close an inheritance cycle: doom gives
`whitespace-trailing' `:inherit trailing-whitespace', while sanityinc gives
`trailing-whitespace' `:inherit whitespace-trailing'.  Emacs signals on that
cycle while realising faces and abandons the rest of the theme, which looks
like a half-applied hybrid of the two colour schemes."
  (interactive)
  (mapc #'disable-theme (copy-sequence custom-enabled-themes))
  (unless (custom-theme-p bramos/theme)
    (load-theme bramos/theme t t))
  (custom-set-variables `(custom-enabled-themes '(,bramos/theme))))

(add-hook 'after-init-hook 'reapply-themes)



;; Toggle between light and dark.  Both stay in the doom family on purpose:
;; mixing two vendors' themes is what closes the face cycle described above.

(defun light ()
  "Activate a light color theme."
  (interactive)
  (setq bramos/theme 'doom-tomorrow-day)
  (reapply-themes))

(defun dark ()
  "Activate a dark color theme."
  (interactive)
  (setq bramos/theme 'doom-tomorrow-night)
  (reapply-themes))


;; (when (maybe-require-package 'dimmer)
;;   (setq-default dimmer-fraction 0.15)
;;   (add-hook 'after-init-hook 'dimmer-mode)
;;   ;; (with-eval-after-load 'dimmer
;;   ;;   ;; TODO: file upstream as a PR
;;   ;;   (advice-add 'frame-set-background-mode :after (lambda (&rest args) (dimmer-process-all))))
;;   (with-eval-after-load 'dimmer
;;     ;; Don't dim in terminal windows. Even with 256 colours it can
;;     ;; lead to poor contrast.  Better would be to vary dimmer-fraction
;;     ;; according to frame type.
;;     (defun sanityinc/display-non-graphic-p ()
;;       (not (display-graphic-p)))
;;     (add-to-list 'dimmer-exclusion-predicates 'sanityinc/display-non-graphic-p)))


(provide 'init-themes)
;;; init-themes.el ends here

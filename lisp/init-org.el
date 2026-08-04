;;; init-org.el --- Org-mode config -*- lexical-binding: t -*-
;;; Commentary:

;; Among settings for many aspects of `org-mode', this code includes
;; an opinionated setup for the Getting Things Done (GTD) system based
;; around the Org Agenda.  I have an "inbox.org" file with a header
;; including

;;     #+CATEGORY: Inbox
;;     #+FILETAGS: INBOX

;; and then set this file as `org-default-notes-file'.  Captured org
;; items will then go into this file with the file-level tag, and can
;; be refiled to other locations as necessary.

;; Those other locations are generally other org files, which should
;; be added to `org-agenda-files-list' (along with "inbox.org" org).
;; With that done, there's then an agenda view, accessible via the
;; `org-agenda' command, which gives a convenient overview.
;; `org-todo-keywords' is customised here to provide corresponding
;; TODO states, which should make sense to GTD adherents.

;;; Code:

(when *is-a-mac*
  (maybe-require-package 'grab-mac-link))

(maybe-require-package 'org-cliplink)

(define-key global-map (kbd "C-c l") 'org-store-link)
(define-key global-map (kbd "C-c a") 'org-agenda)

(defvar sanityinc/org-global-prefix-map (make-sparse-keymap)
  "A keymap for handy global access to org helpers, particularly clocking.")

(define-key sanityinc/org-global-prefix-map (kbd "j") 'org-clock-goto)
(define-key sanityinc/org-global-prefix-map (kbd "l") 'org-clock-in-last)
(define-key sanityinc/org-global-prefix-map (kbd "i") 'org-clock-in)
(define-key sanityinc/org-global-prefix-map (kbd "o") 'org-clock-out)
(define-key global-map (kbd "C-c o") sanityinc/org-global-prefix-map)


;; Various preferences
(setq org-log-done t
      org-edit-timestamp-down-means-later t
      org-hide-emphasis-markers t
      org-catch-invisible-edits 'show
      org-export-coding-system 'utf-8
      org-fast-tag-selection-single-key 'expert
      org-html-validation-link nil
      org-export-kill-product-buffer-when-displayed t
      org-tags-column 80)


;; Lots of stuff from http://doc.norang.ca/org-mode.html

;; Re-align tags when window shape changes
(with-eval-after-load 'org-agenda
  (add-hook 'org-agenda-mode-hook
            (lambda () (add-hook 'window-configuration-change-hook 'org-agenda-align-tags nil t))))




(maybe-require-package 'writeroom-mode)

(define-minor-mode prose-mode
  "Set up a buffer for prose editing.
This enables or modifies a number of settings so that the
experience of editing prose is a little more like that of a
typical word processor."
  :init-value nil :lighter " Prose" :keymap nil
  (if prose-mode
      (progn
        (when (fboundp 'writeroom-mode)
          (writeroom-mode 1))
        (setq truncate-lines nil)
        (setq word-wrap t)
        (setq cursor-type 'bar)
        (when (eq major-mode 'org)
          (kill-local-variable 'buffer-face-mode-face))
        (buffer-face-mode 1)
        ;;(delete-selection-mode 1)
        (setq-local blink-cursor-interval 0.6)
        (setq-local show-trailing-whitespace nil)
        (setq-local line-spacing 0.2)
        (setq-local electric-pair-mode nil)
        (ignore-errors (flyspell-mode 1))
        (visual-line-mode 1))
    (kill-local-variable 'truncate-lines)
    (kill-local-variable 'word-wrap)
    (kill-local-variable 'cursor-type)
    (kill-local-variable 'blink-cursor-interval)
    (kill-local-variable 'show-trailing-whitespace)
    (kill-local-variable 'line-spacing)
    (kill-local-variable 'electric-pair-mode)
    (buffer-face-mode -1)
    ;; (delete-selection-mode -1)
    (flyspell-mode -1)
    (visual-line-mode -1)
    (when (fboundp 'writeroom-mode)
      (writeroom-mode 0))))

;;(add-hook 'org-mode-hook 'buffer-face-mode)
(when (maybe-require-package 'org-modern)
  (add-hook 'org-mode-hook 'org-modern-mode))

(add-hook 'org-mode-hook (lambda ()
                           (setq fill-column 100)
                           (auto-fill-mode 1)))

;; Org's default completion offers dictionary spellings via
;; `ispell-completion-at-point', whose suggestions are noisy and rarely
;; relevant.  Prefer completing words already present in open buffers and
;; drop the ispell source.  Use `cape-dabbrev' rather than the built-in
;; `dabbrev-capf': the latter can return nil candidates that crash Corfu's
;; auto-completion timer ("wrong type argument stringp nil").
(when (maybe-require-package 'cape)
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local completion-at-point-functions
                          (cons #'cape-dabbrev
                                (remq #'ispell-completion-at-point
                                      completion-at-point-functions))))))

(setq org-support-shift-select t)

;;; Capturing

(global-set-key (kbd "C-c c") 'org-capture)

(setq org-default-notes-file (expand-file-name "~/data/notes/gtd/inbox.org"))
(setq org-agenda-files (directory-files (expand-file-name "~/data/notes/gtd/") t "\\.org$"))

(setq org-capture-templates
      `(("t" "todo" entry (file "")  ; "" => `org-default-notes-file'
         "* NEXT %?\n%U\n" :clock-resume t)
        ("n" "note" entry (file "")
         "* %? :NOTE:\n%U\n%a\n" :clock-resume t)
        ))



;;; Refiling

(setq org-refile-use-cache nil)

;; Targets include this file and any file contributing to the agenda - up to 5 levels deep
(setq org-refile-targets '((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5)))

(with-eval-after-load 'org-agenda
  (add-to-list 'org-agenda-after-show-hook 'org-show-entry))

(advice-add 'org-refile :after (lambda (&rest _) (org-save-all-org-buffers)))

;; Exclude DONE state tasks from refile targets
(defun sanityinc/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets."
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))
(setq org-refile-target-verify-function 'sanityinc/verify-refile-target)

(defun sanityinc/org-refile-anywhere (&optional goto default-buffer rfloc msg)
  "A version of `org-refile' which allows refiling to any subtree."
  (interactive "P")
  (let ((org-refile-target-verify-function))
    (org-refile goto default-buffer rfloc msg)))

(defun sanityinc/org-agenda-refile-anywhere (&optional goto rfloc no-update)
  "A version of `org-agenda-refile' which allows refiling to any subtree."
  (interactive "P")
  (let ((org-refile-target-verify-function))
    (org-agenda-refile goto rfloc no-update)))

;; Targets start with the file name - allows creating level 1 tasks, and keeps
;; same-named headings in different files (required-reading, nice-to-read,
;; Archive) distinguishable in the completion list.
(setq org-refile-use-outline-path 'file)
(setq org-outline-path-complete-in-steps nil)

;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes 'confirm)


;;; To-do settings

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
              (sequence "PROJECT(p)" "|" "DONE(d!/!)" "CANCELLED(c@/!)")
              (sequence "WAITING(w@/!)" "DELEGATED(e!)" "HOLD(h)" "|" "CANCELLED(c@/!)")))
      org-todo-repeat-to-state "NEXT")

(setq org-todo-keyword-faces
      (quote (("NEXT" :inherit warning)
              ("PROJECT" :inherit font-lock-string-face))))



;;; Agenda views

(setq-default org-agenda-clockreport-parameter-plist '(:link t :maxlevel 3))

(defvar bramos/org-agenda-gutter-width 16
  "Width of the leading gutter shared by agenda blocks.
Sized to the longest value displayed there.  Widen this when a longer
category or file tag is added, or the column will break silently.")

(defvar bramos/org-agenda-gutter-separator "│"
  "Glyph drawn between the agenda gutter and the task text.
Defined once because `bramos/org-agenda-gutter-prefix' emits it and
`bramos/org-agenda-style-gutter' locates it to decide what to fontify.")

(defface bramos/org-agenda-gutter-label
  '((t :inherit font-lock-string-face))
  "Face for the category label in the agenda gutter.
Inherits the face `org-todo-keyword-faces' gives PROJECT, so the gutter
matches how project headings already read, and tracks theme changes rather
than pinning a colour.")

(defface bramos/org-agenda-gutter-rule
  '((t :inherit org-tag))
  "Face for the rule between the agenda gutter and the task text.
Inherits `org-tag', which this theme renders in a muted grey, so the rule
reads as a drawn column rather than a character.")

(defun bramos/org-agenda-gutter-prefix (spec)
  "Return an `org-agenda-prefix-format' alist for a gutter filled by SPEC.
SPEC is a prefix-format letter: \"c\" for the category, \"T\" for the last
tag.  Prefer \"c\": the last tag is displaced by any local tag on the entry.
Pair with `bramos/org-agenda-gutter-line' so the keyword and trailing tags
do not repeat what the gutter already says, and so the gutter gets faced."
  (let ((fmt (format "  %%-%d%s %s "
                     bramos/org-agenda-gutter-width spec
                     bramos/org-agenda-gutter-separator)))
    `((agenda . ,fmt) (todo . ,fmt) (tags . ,fmt) (search . ,fmt))))

(defvar bramos/org-agenda-context-property 'bramos-agenda-context
  "Text property marking the context suffix appended to agenda lines.
`bramos/org-agenda-align-context' searches for it to find what to align.
A property rather than a regexp, because the suffix embeds arbitrary
project titles and so cannot be matched reliably.")

(defvar bramos/org-agenda-context-max-width 34
  "Maximum display width of the CATEGORY/PROJECT context suffix.
Bounding it leaves enough of each line free that the right-aligned suffix
reads as a column instead of collapsing to the one-space fallback.  Set to
nil to never truncate.")

(defun bramos/org-nearest-project-title ()
  "Return the title of the nearest ancestor heading in the PROJECT state.
Returns nil when the entry has no PROJECT ancestor.  Point must already be
on the entry in its own Org buffer."
  (save-excursion
    (let (title)
      (while (and (not title) (org-up-heading-safe))
        (when (equal (org-get-todo-state) "PROJECT")
          (setq title (org-get-heading t t t t))))
      title)))

(defun bramos/org-agenda-context-string ()
  "Return \"CATEGORY/PROJECT\" for the entry at point.
Falls back to the bare category when the entry has no PROJECT ancestor, and
truncates to `bramos/org-agenda-context-max-width'."
  (let* ((category (org-get-category))
         (project (bramos/org-nearest-project-title))
         (context (if project (concat category "/" project) category)))
    (if bramos/org-agenda-context-max-width
        (truncate-string-to-width
         context bramos/org-agenda-context-max-width nil nil t)
      context)))

(defun bramos/org-agenda-strip-keyword-and-tags (line)
  "Return agenda LINE with its TODO keyword and trailing tag group removed.
Both are redundant in a block that selects a single keyword and already
shows the file tag in the prefix.  Suitable on its own as an
`org-agenda-before-sorting-filter-function'.  The keyword is matched at a
symbol boundary rather than anchored to the start of the string, so this
works whether or not `org-agenda-prefix-format' placed a gutter ahead of
it.  Only `substring' is used, so the text properties the agenda relies on
for navigation survive intact."
  (let ((marker (or (get-text-property 0 'org-hd-marker line)
                    (get-text-property 0 'org-marker line))))
    (if (not marker)
        line
      (let ((task line)
            (keyword (org-with-point-at marker (org-get-todo-state)))
            (case-fold-search nil))
        (when (string-match org-tag-group-re task)
          (setq task (substring task 0 (match-beginning 0))))
        (when (and keyword
                   (string-match (concat "\\_<" (regexp-quote keyword) " ") task))
          (setq task (concat (substring task 0 (match-beginning 0))
                             (substring task (match-end 0)))))
        task))))

(defun bramos/org-agenda-style-gutter (line)
  "Fontify the gutter of agenda LINE up to and including the rule glyph.
Must run after `org-scan-tags' has applied its property list, which sets
`face' to `default' across the whole line (see `org.el') and so flattens any
face applied while the prefix was being formatted.  `add-face-text-property'
is used rather than `propertize' so the gutter faces merge ahead of that
`default' instead of replacing it.  The region is found by locating
`bramos/org-agenda-gutter-separator' rather than by offset, since stripping
the keyword shifts the line and the gutter width is configurable."
  (let ((rule (string-search bramos/org-agenda-gutter-separator line)))
    (when rule
      (add-face-text-property 0 rule 'bramos/org-agenda-gutter-label nil line)
      (add-face-text-property rule (1+ rule)
                              'bramos/org-agenda-gutter-rule nil line)))
  line)

(defun bramos/org-agenda-gutter-line (line)
  "Strip the TODO keyword and tags from agenda LINE, then fontify its gutter.
The `org-agenda-before-sorting-filter-function' for gutter blocks."
  (bramos/org-agenda-style-gutter
   (bramos/org-agenda-strip-keyword-and-tags line)))

(defun bramos/org-agenda-task-then-context (line)
  "Rewrite agenda LINE as \"TASK  CATEGORY/PROJECT\".
An alternative to using `bramos/org-agenda-strip-keyword-and-tags' alone:
appends the context, marked with `bramos/org-agenda-context-property' so
`bramos/org-agenda-align-context' can right-align it.

Unused by default; the blocks lead with a category gutter instead.  To put a
block back on this layout: give it an empty `org-agenda-prefix-format' so the
task text leads the line, set this as its
`org-agenda-before-sorting-filter-function', and hook
`bramos/org-agenda-align-context' onto `org-agenda-finalize-hook' plus the
buffer-local `window-configuration-change-hook' beside
`org-agenda-align-tags' so the column survives a resize."
  (let ((marker (or (get-text-property 0 'org-hd-marker line)
                    (get-text-property 0 'org-marker line))))
    (if (not marker)
        line
      (concat (bramos/org-agenda-strip-keyword-and-tags line) " "
              (propertize (org-with-point-at marker
                           (bramos/org-agenda-context-string))
                          bramos/org-agenda-context-property t
                          'face 'org-tag)))))

(defun bramos/org-agenda-align-context (&optional line)
  "Right-align context suffixes to `org-agenda-tags-column'.
Modelled on `org-agenda-align-tags'.  With LINE non-nil, align only the
current line.  Idempotent: whitespace already preceding a suffix is removed
before fresh padding is inserted, so repeated runs are a fixed point.

Deliberately not hooked anywhere: no block currently produces the suffix it
aligns, so it would scan for nothing on every agenda build.  See
`bramos/org-agenda-task-then-context' for how to switch a block over."
  (let ((inhibit-read-only t)
        (column (if (eq 'auto org-agenda-tags-column)
                    (- (window-max-chars-per-line))
                  org-agenda-tags-column))
        (end (and line (line-end-position))))
    (save-excursion
      (goto-char (if line (line-beginning-position) (point-min)))
      (while (let ((match (text-property-search-forward
                           bramos/org-agenda-context-property t t)))
               (when (and match
                          (or (null end) (<= (prop-match-beginning match) end)))
                 (let* ((start (prop-match-beginning match))
                        (width (string-width
                                (buffer-substring start (prop-match-end match))))
                        (target (if (< column 0) (- (abs column) width) column)))
                   (goto-char start)
                   (delete-region
                    (save-excursion (skip-chars-backward " \t") (point)) (point))
                   (insert (make-string (max 1 (- target (current-column))) ?\s))
                   (goto-char (line-end-position))
                   t)))))))

(defun bramos/org-agenda-format-date-aligned (date)
  "Format DATE for the agenda without the ISO week number.
Identical to `org-agenda-format-date-aligned', including its alignment, but
omitting the \" W%02d\" that upstream appends on Mondays."
  (let ((dayname (calendar-day-name date))
        (day (cadr date))
        (monthname (calendar-month-name (car date)))
        (year (nth 2 date)))
    (format "%-10s %2d %s %4d" dayname day monthname year)))

(setq org-agenda-format-date 'bramos/org-agenda-format-date-aligned)


(let ((active-project-match "-INBOX/PROJECT"))

  (setq org-stuck-projects
        `(,active-project-match ("NEXT")))

  (setq org-agenda-compact-blocks t
        org-agenda-sticky t
        org-agenda-start-on-weekday nil
        org-agenda-span 'day
        org-agenda-include-diary nil
        org-agenda-sorting-strategy
        '((agenda habit-down time-up user-defined-up effort-up category-keep)
          (todo category-up effort-up)
          (tags category-up effort-up)
          (search category-up))
        org-agenda-window-setup 'current-window
        org-agenda-custom-commands
        `(("N" "Notes" tags "NOTE"
           ((org-agenda-overriding-header "Notes")
            (org-tags-match-list-sublevels t)))
          ("g" "GTD"
           ((agenda "" nil)
            (tags "INBOX"
                  ((org-agenda-overriding-header "Inbox")
                   (org-tags-match-list-sublevels nil)))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "Next Actions")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        ;; Category gutter, a rule, then the task text
                        ;; left-justified in a fixed column.  For the
                        ;; right-aligned CATEGORY/PROJECT layout instead, use an
                        ;; empty prefix with
                        ;; `bramos/org-agenda-task-then-context' as the filter.
                        (org-agenda-prefix-format
                         (bramos/org-agenda-gutter-prefix "c"))
                        (org-agenda-before-sorting-filter-function
                         'bramos/org-agenda-gutter-line)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("HOLD" "WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("NEXT")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(todo-state-down effort-up category-keep))))
            (tags-todo "-INBOX/-NEXT"
                       ((org-agenda-overriding-header "Loose Tasks")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("PROJECT" "HOLD" "WAITING" "DELEGATED"))
                                (org-agenda-skip-subtree-if 'nottodo '("TODO")))))
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/WAITING"
                       ((org-agenda-overriding-header "Waiting")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/DELEGATED"
                       ((org-agenda-overriding-header "Delegated")
                        (org-agenda-tags-todo-honor-ignore-options t)
                        (org-agenda-todo-ignore-scheduled 'future)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "-INBOX"
                       ((org-agenda-overriding-header "On Hold")
                        (org-agenda-skip-function
                         '(lambda ()
                            (or (org-agenda-skip-subtree-if 'todo '("WAITING"))
                                (org-agenda-skip-entry-if 'nottodo '("HOLD")))))
                        (org-tags-match-list-sublevels nil)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            ;; (tags-todo "-NEXT"
            ;;            ((org-agenda-overriding-header "All other TODOs")
            ;;             (org-match-list-sublevels t)))
            ))
          ;; Mirrors the weekly review checklist in ~/data/notes/README.org.
          ;; Stuck projects live here rather than in "g": a project without a
          ;; NEXT is a review-time problem, and in the daily view the block
          ;; duplicated "Projects" whenever project hygiene had lapsed.
          ("w" "Weekly review"
           ((tags "INBOX"
                  ((org-agenda-overriding-header "1. Inbox (refile or delete every item)")
                   (org-tags-match-list-sublevels nil)))
            (stuck ""
                   ((org-agenda-overriding-header "2. Stuck projects (give each a NEXT, or mark HOLD/CANCELLED)")
                    (org-tags-match-list-sublevels t)))
            (tags-todo ,active-project-match
                       ((org-agenda-overriding-header "2b. All active projects")
                        (org-agenda-prefix-format
                         (bramos/org-agenda-gutter-prefix "c"))
                        (org-agenda-before-sorting-filter-function
                         'bramos/org-agenda-gutter-line)
                        (org-tags-match-list-sublevels t)
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/WAITING"
                       ((org-agenda-overriding-header "3. Waiting (anything to chase?)")
                        (org-agenda-sorting-strategy
                         '(category-keep))))
            (tags-todo "/DELEGATED"
                       ((org-agenda-overriding-header "3b. Delegated (anything to chase?)")
                        (org-agenda-sorting-strategy
                         '(category-keep))))))
          )))


(add-hook 'org-agenda-mode-hook 'hl-line-mode)


;;; Org clock

;; Save the running clock and all clock history when exiting Emacs, load it on startup
(with-eval-after-load 'org
  (org-clock-persistence-insinuate))
(setq org-clock-persist t)
(setq org-clock-in-resume t)

;; Save clock data and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Save state changes in the LOGBOOK drawer
(setq org-log-into-drawer t)
;; Removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Show clock sums as hours and minutes, not "n days" etc.
(setq org-time-clocksum-format
      '(:hours "%d" :require-hours t :minutes ":%02d" :require-minutes t))



;;; Show the clocked-in task - if any - in the header line
(defun sanityinc/show-org-clock-in-header-line ()
  (setq-default header-line-format '((" " org-mode-line-string " "))))

(defun sanityinc/hide-org-clock-from-header-line ()
  (setq-default header-line-format nil))

(add-hook 'org-clock-in-hook 'sanityinc/show-org-clock-in-header-line)
(add-hook 'org-clock-out-hook 'sanityinc/hide-org-clock-from-header-line)
(add-hook 'org-clock-cancel-hook 'sanityinc/hide-org-clock-from-header-line)

(with-eval-after-load 'org-clock
  (define-key org-clock-mode-line-map [header-line mouse-2] 'org-clock-goto)
  (define-key org-clock-mode-line-map [header-line mouse-1] 'org-clock-menu))



(when (and *is-a-mac* (file-directory-p "/Applications/org-clock-statusbar.app"))
  (add-hook 'org-clock-in-hook
            (lambda () (call-process "/usr/bin/osascript" nil 0 nil "-e"
                                (concat "tell application \"org-clock-statusbar\" to clock in \"" org-clock-current-task "\""))))
  (add-hook 'org-clock-out-hook
            (lambda () (call-process "/usr/bin/osascript" nil 0 nil "-e"
                                "tell application \"org-clock-statusbar\" to clock out"))))



;; TODO: warn about inconsistent items, e.g. TODO inside non-PROJECT
;; TODO: nested projects!



;;; Archiving

(setq org-archive-mark-done nil)
(setq org-archive-location "%s_archive::* Archive")





(require-package 'org-pomodoro)
(setq org-pomodoro-keep-killed-pomodoro-time t)
(with-eval-after-load 'org-agenda
  (define-key org-agenda-mode-map (kbd "P") 'org-pomodoro))


;; ;; Show iCal calendars in the org agenda
;; (when (and *is-a-mac* (require 'org-mac-iCal nil t))
;;   (setq org-agenda-include-diary t
;;         org-agenda-custom-commands
;;         '(("I" "Import diary from iCal" agenda ""
;;            ((org-agenda-mode-hook #'org-mac-iCal)))))

;;   (add-hook 'org-agenda-cleanup-fancy-diary-hook
;;             (lambda ()
;;               (goto-char (point-min))
;;               (save-excursion
;;                 (while (re-search-forward "^[a-z]" nil t)
;;                   (goto-char (match-beginning 0))
;;                   (insert "0:00-24:00 ")))
;;               (while (re-search-forward "^ [a-z]" nil t)
;;                 (goto-char (match-beginning 0))
;;                 (save-excursion
;;                   (re-search-backward "^[0-9]+:[0-9]+-[0-9]+:[0-9]+ " nil t))
;;                 (insert (match-string 0))))))


(defun bramos/org-region-to-markdown ()
  "Convert selected org region to markdown and copy to clipboard."
  (interactive)
  (unless (region-active-p)
    (user-error "No region selected"))
  (let* ((org-text (buffer-substring-no-properties (region-beginning) (region-end)))
         (md-text (with-temp-buffer
                    (insert org-text)
                    (shell-command-on-region (point-min) (point-max)
                                             "pandoc -f org -t markdown"
                                             t t)
                    (buffer-string))))
    (kill-new md-text)
    (message "Markdown copied to clipboard")))

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-M-<up>") 'org-up-element)
  (when *is-a-mac*
    (define-key org-mode-map (kbd "M-h") nil)
    (define-key org-mode-map (kbd "C-c g") 'grab-mac-link)))

(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   (seq-filter
    (lambda (pair)
      (locate-library (concat "ob-" (symbol-name (car pair)))))
    '((R . t)
      (ditaa . t)
      (dot . t)
      (emacs-lisp . t)
      (gnuplot . t)
      (haskell . nil)
      (latex . t)
      (ledger . t)
      (ocaml . nil)
      (octave . t)
      (plantuml . t)
      (python . t)
      (ruby . t)
      (screen . nil)
      (sh . t) ;; obsolete
      (shell . t)
      (sql . t)
      (sqlite . t)))))


;;; Org-roam

(when (maybe-require-package 'org-roam)
  (setq org-roam-directory (file-truename (expand-file-name "~/data/notes/roam/")))
  (setq org-roam-dailies-directory "daily/")

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "${slug}.org"
                              "#+TITLE: ${title}\n#+ROAM_TAGS:\n\n")
           :unnarrowed t)))

  (setq org-roam-dailies-capture-templates
        '(("d" "daily" entry "* %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+TITLE: %<%Y-%m-%d>\n#+CATEGORY: Daily\n\n* Morning\n\n* Notes\n\n* EOD\n")
           :unnarrowed t)))

  (org-roam-db-autosync-mode)

  (define-key global-map (kbd "C-c n f") 'org-roam-node-find)
  (define-key global-map (kbd "C-c n i") 'org-roam-node-insert)
  (define-key global-map (kbd "C-c n d") 'org-roam-dailies-goto-today)
  (define-key global-map (kbd "C-c n D") 'org-roam-dailies-goto-date)
  (define-key global-map (kbd "C-c n b") 'org-roam-buffer-toggle))

(provide 'init-org)
;;; init-org.el ends here

;;; init-bazel.el --- Bazel support -*- lexical-binding: t -*-
;;; Commentary:

;; The `bazel' package registers its own `auto-mode-alist' entries via
;; autoloads -- BUILD, WORKSPACE, MODULE.bazel, *.bzl, .bazelrc and friends --
;; so installing it is all this needs to do.

;;; Code:

(maybe-require-package 'bazel)

(provide 'init-bazel)
;;; init-bazel.el ends here

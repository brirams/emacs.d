;;; init-thrift.el --- Thrift support -*- lexical-binding: t -*-
;;; Commentary:

;; The `thrift' package (from the fbthrift repo, covers Apache Thrift too)
;; registers its own `.thrift' entry in `auto-mode-alist' via autoloads, so
;; installing it is all this needs to do.  Indentation is 2 by default; see
;; `thrift-indent-level'.

;;; Code:

(maybe-require-package 'thrift)

(provide 'init-thrift)
;;; init-thrift.el ends here

;;; package org-pm2 --- Org-mode export of files and sections to PDF and LaTeX

;;; Commentary
;; Trying to make things easy
;; Needs https://github.com/iani/tiddlywiki-render-template
;; Clones it automatically at export time, if required.

;;; Code
(eval-and-compile
  (let ((load-path
         (if (and (boundp 'byte-compile-dest-file)
                  (stringp byte-compile-dest-file))
             (cons (file-name-directory byte-compile-dest-file) load-path)
           load-path)))
    ;; (message "THE LOAD PATH IS %s" load-path)
    (require 'org-pm-util)
    (require 'org-pm-tw)
    (require 'org-pm-latex)
    (require 'ox-tw)))
(provide 'org-pm2)
;;; org-pm2.el ends here

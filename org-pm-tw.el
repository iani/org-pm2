;;; org-pm-tw --- Export org-mode files to TiddlyWiki, render, and upload to github

;;; Commentary:
;; Can export both entire file and individual subsections
;; Stores  created TiddlyWikis in WIKIS subdir,
;; in the same subdirectory as the source file.

;; Needs https://github.com/iani/tiddlywiki-render-template
;; Clones it automatically at export time, if required.

;;; Code:

(defun org-pm-tw-deploy (section-p)
  "Export, render, and upload the wiki of this section/file to github."
  (interactive "P")
  (org-pm-tw-render section-p)
  (org-pm-tw-upload))

(defun org-pm-tw-render (section-p)
  "Export file or section to TiddlyWiki as tiddlers, then render to html."
  (interactive "P")
  (let ((render-path (org-pm-tw-export (section-p))))
    (call-process-shell-command
     (concat
      ))))

(defun org-pm-tw-export (section-p)
  "Export file or section to TiddlyWiki as tiddlers.
Install template if required."
  (interactive "P")
  (let (()))
  )

(defun org-pm-tw-upload ()
  "Upload entire site to github using git."
  )

;;; Clone tiddlywiki-render-template from github.
(defun org-pm-tw-install-wiki-template-folder-if-needed ()
  "Clone wiki template from github if needed."
  (let ((path (concat (file-name-directory (buffer-file-name)) "WIKIS")))
    (unless (file-exists-p path)
      (call-process-shell-command
       (concat "git clone https://github.com/iani/tiddlywiki-render-template.git  "
               (shell-quote-argument path))))))

(provide 'org-pm-tw)
;;; org-pm-tw.el ends here

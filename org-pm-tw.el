;;; org-pm-tw --- Export org-mode files to TiddlyWiki, render, and upload to github

;;; Commentary:
;; Can export both entire file and individual subsections
;; Stores  created TiddlyWikis in WIKIS subdir,
;; in the same subdirectory as the source file.

;; Needs https://github.com/iani/tiddlywiki-render-template
;; Clones it automatically at export time, if required.

;;; Code:

(defcustom org-pm-tw-tiddlywiki-command-path
  "/usr/local/bin/tiddlywiki"
  )
(defun org-pm-tw-deploy (section-p)
  "Export, render, and upload the wiki of this section/file to github.
If SECTION-P is not nil, then export current sectio.
Else export the entire file."
  (interactive "P")
  (org-pm-tw-render section-p)
  (org-pm-tw-upload))

(defun org-pm-tw-render (section-p)
  "Export file or section to TiddlyWiki as tiddlers, then render to html.
If SECTION-P is not nil, then export current sectio.
Else export the entire file."
  (interactive "P")
  ;; We need:
  ;; 1. WIKI-PATH: path of source tiddly wiki folder.
  ;; 2. EXPORT-PATH: path of target export html file.
  ;; Both of these are constructed from the filename of the WIKI-PATH.
  ;; Therefore we need WIKI-NAME.
  ;; org-pm-tw-export provides WIKI-NAME as return value.
  (let ((wiki-name (shell-quote-argument (org-pm-tw-export section-p))))
    (call-process-shell-command
     (concat
      org-pm-tw-tiddlywiki-command-path
      "tiddlywiki ./WIKIS/template/"
      wiki-name
      " --rendertiddler $:/core/save/all ../../../../rendered/"
      wiki-name
      ".html text/plain"))))

(defun org-pm-tw-export (section-p)
  "Export file or section to TiddlyWiki as tiddlers.
Install template if required.
If SECTION-P is not nil, then export current sectio.
Else export the entire file."
  (interactive "P")
  (let ((wiki-name (org-pm-tw-query-wiki-name section-p)))
    
    wiki-name))

(defun org-pm-tw-query-wiki-name (section-p)
  "Query the user for the wiki-name.
Provide default extracted from name of file or session,
or last name saved in property.
If SECTION-P is nil, then get name for file, else get name for section,"
  
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

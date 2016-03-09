;; tests


;;; Clone 
(defun org-pm-tw-install-wiki-template-folder-if-needed ()
  (let ((path (concat (file-name-directory (buffer-file-name)) "WIKIS")))
    (unless (file-exists-p path)
      (call-process-shell-command
       (concat "git clone https://github.com/iani/tiddlywiki-render-template.git  "
               (shell-quote-argument path))))))





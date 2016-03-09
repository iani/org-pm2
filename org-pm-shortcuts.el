;;; org-pm-shortcuts --- Keyboard shortcuts for org-pm2

;;; Commentary:

;; I use the keyboard combination =Meta-p= (Alt-p, Opt-p or Esc-p) as prefix
;; for the 3 interactive commands of the org-pm-tw library.  This is because
;; (a) p is a mnemonic for "publish" and
;; (b) it is not occupied by any other commands in Org mode or in emacs-lisp mode
;; (which are the two main modes concerned here).
;; Thus, the keyboard shortcuts are:

;; Meta-p p org-pm-tw-deploy
;; Meta-p d org-pm-tw-deploy (alternative)
;; Meta-p r org-pm-tw-render
;; Meta-p e org-pm-tw-export
;; Meta-p u org-pm-tw-upload
;; Meta-p l org-pm-export-latex

;;; Code:

(eval-after-load 'org
  '(progn
     (define-key org-mode-map (kbd "M-p p") 'org-pm-tw-deploy)
     (define-key org-mode-map (kbd "M-p d") 'org-pm-tw-deploy)
     (define-key org-mode-map (kbd "M-p r") 'org-pm-tw-render)
     (define-key org-mode-map (kbd "M-p e") 'org-pm-tw-export)
     (define-key org-mode-map (kbd "M-p u") 'org-pm-tw-upload)
     (define-key org-mode-map (kbd "M-p l") 'org-pm-latex-export)))

(provide 'org-pm-shortcuts)
;;; org-pm-shortcuts.el ends here
